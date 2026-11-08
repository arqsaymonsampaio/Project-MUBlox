"""Real FBX roundtrip validation in Blender; Studio import still requires verification."""
from pathlib import Path
import math
import bpy
from mathutils import Vector
root=Path(__file__).resolve().parents[1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=str(root/'art/roblox/Guerreiro_Visual_R15.fbx'))
objects={o.name:o for o in bpy.context.scene.objects}
assert len(objects)==49, len(objects)
assert "FormatV2" in objects and "FormatV3" in objects
visuals=[o for o in objects.values() if o.name.startswith('Visual_')]
assert len(visuals)==15
wear=[o for o in objects.values() if o.name.startswith('Wear_')]
assert len(wear)==14
assert 'Wear_Armor_LowerTorso' in objects and 'Wear_Helmet_Head' in objects
for obj in visuals+wear:
    assert obj.type=='MESH' and obj.data.uv_layers.active
    assert obj.data.materials
    obj.data.calc_loop_triangles()
    assert len(obj.data.loop_triangles)<=10000
    bind=objects['Bind_'+obj.name.split('_')[-1]]
    # Catches incorrect segment assignment, e.g. a hand accidentally containing leg triangles.
    for vert in obj.data.vertices:
        local=bind.matrix_world.inverted() @ (obj.matrix_world @ vert.co)
        assert all(math.isfinite(c) for c in local)
        assert all(abs(local[i]) < 3*bind.dimensions[i] for i in range(3)), obj.name
images=[n.image for m in bpy.data.materials if m.use_nodes for n in m.node_tree.nodes if n.type=='TEX_IMAGE' and n.image]
assert images and any(image.size[0]==128 for image in images)
print('PASS V3 FBX: 15 body meshes, 14 clothing meshes, markers, UVs, texture, segment bounds and triangle budgets')

# A cross-section below the palm must keep four separate fingertips.
origin=objects['AxisOrigin'].matrix_world.translation
up=objects['AxisUp'].matrix_world.translation-origin
for side in ['Left','Right']:
    hand=objects['Visual_'+side+'Hand']
    ids={v.index for v in hand.data.vertices if ((hand.matrix_world@v.co)-origin).dot(up.normalized())/up.length < 1.58}
    adjacency={i:set() for i in ids}
    for edge in hand.data.edges:
        a,b=edge.vertices
        if a in ids and b in ids: adjacency[a].add(b); adjacency[b].add(a)
    count=0
    while ids:
        count+=1; stack=[ids.pop()]
        while stack:
            for other in adjacency[stack.pop()]:
                if other in ids: ids.remove(other); stack.append(other)
    assert count==4,(side,count)
print('PASS V3 hands: four separated fingertips survive FBX export/import')
