"""Reimport the actual FBX and test skin weights, joints and deformation."""
from pathlib import Path
import math
import bpy
from mathutils import Quaternion, Vector
root = Path(__file__).resolve().parents[1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=str(root / 'art/roblox/articulado/MUBlox_Guerreiro_Articulado.fbx'))
rigs = [o for o in bpy.context.scene.objects if o.type == 'ARMATURE']
assert len(rigs) == 1
rig = rigs[0]
assert len(rig.data.bones) == 15
meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
assert len(meshes) == 7
for obj in meshes:
    assert any(m.type == 'ARMATURE' and m.object == rig for m in obj.modifiers)
    assert obj.data.uv_layers.active
    obj.data.calc_loop_triangles()
    assert len(obj.data.loop_triangles) <= 10000
    for v in obj.data.vertices:
        weights = [g.weight for g in v.groups if g.weight > 0]
        assert 1 <= len(weights) <= 4, (obj.name, v.index)
        assert abs(sum(weights) - 1) < .001, (obj.name, v.index, weights)
    assert any(n.type == 'TEX_IMAGE' and n.image and n.image.size[0] == 128
        for material in obj.data.materials for n in material.node_tree.nodes)
body = next(o for o in meshes if o.name == 'Skin_Body')
groups = {g.name: g.index for g in body.vertex_groups}
for side in ['Left', 'Right']:
    for top, bottom in [('UpperArm', 'LowerArm'), ('UpperLeg', 'LowerLeg')]:
        pair = {groups[side+top], groups[side+bottom]}
        shared = [v for v in body.data.vertices if pair.issubset({g.group for g in v.groups if g.weight > .03})]
        assert len(shared) >= 5, (side, top, len(shared))
def positions(obj):
    evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
    mesh = evaluated.to_mesh()
    result = [obj.matrix_world @ v.co for v in mesh.vertices]
    evaluated.to_mesh_clear()
    return result
before = positions(body)
for name, degrees in [('LeftLowerArm', -70), ('RightLowerArm', -70), ('LeftLowerLeg', 65)]:
    bone = rig.pose.bones[name]
    axis = rig.data.bones[name].matrix_local.to_3x3().inverted() @ Vector((1,0,0))
    bone.rotation_mode = 'QUATERNION'
    bone.rotation_quaternion = Quaternion(axis, math.radians(degrees))
bpy.context.view_layer.update()
after = positions(body)
assert all(math.isfinite(c) for p in after for c in p)
assert max((a-b).length for a,b in zip(before,after)) > .05
head_ids = [v.index for v in body.data.vertices if any(g.group == groups['Head'] and g.weight > .999 for g in v.groups)]
assert head_ids and max((before[i]-after[i]).length for i in head_ids) < .00001
for side in ['Left', 'Right']:
    hand_ids = [v.index for v in body.data.vertices if any(g.group == groups[side+'Hand'] and g.weight > .95 for g in v.groups)]
    assert hand_ids and max((before[i]-after[i]).length for i in hand_ids) > .05
print('PASS skinned FBX: 15 bones, seven meshes, normalized weights, joint blends, moving hands and stationary head.')
