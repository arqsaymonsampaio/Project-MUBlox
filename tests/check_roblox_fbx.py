"""Real FBX roundtrip validation in Blender; Studio import still requires verification."""
from pathlib import Path
import math
import bpy
from mathutils import Vector
root=Path(__file__).resolve().parents[1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=str(root/'art/roblox/Guerreiro_Visual_R15.fbx'))
objects={o.name:o for o in bpy.context.scene.objects}
assert len(objects)==33, len(objects)
visuals=[o for o in objects.values() if o.name.startswith('Visual_')]
assert len(visuals)==15
for obj in visuals:
    assert obj.type=='MESH' and obj.data.uv_layers.active
    assert obj.data.materials
    obj.data.calc_loop_triangles()
    assert len(obj.data.loop_triangles)<=10000
    bind=objects[obj.name.replace('Visual_','Bind_')]
    # Catches incorrect segment assignment, e.g. a hand accidentally containing leg triangles.
    for vert in obj.data.vertices:
        local=bind.matrix_world.inverted() @ (obj.matrix_world @ vert.co)
        assert all(math.isfinite(c) for c in local)
        assert all(abs(local[i]) < 3*bind.dimensions[i] for i in range(3)), obj.name
images=[n.image for m in bpy.data.materials if m.use_nodes for n in m.node_tree.nodes if n.type=='TEX_IMAGE' and n.image]
assert images and any(image.size[0]==128 for image in images)
print('PASS FBX roundtrip: 15 meshes, binding/orientation markers, UVs, texture, segment bounds and per-part triangle budget')
