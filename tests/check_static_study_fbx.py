"""Check the real display FBX after reimport, independently of the source scene."""
from pathlib import Path
import math
import bpy
root = Path(__file__).resolve().parents[1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=str(root / 'art/roblox/estudo/MUBlox_Estudo_Mapa.fbx'))
objects = list(bpy.context.scene.objects)
assert {o.name for o in objects} == {'Estudo_' + name for name in
    ['Body', 'Face', 'Hair', 'StarterShirt', 'StarterGloves', 'StarterBoots', 'StarterPants']}
points = []
for obj in objects:
    assert obj.type == 'MESH' and obj.data.uv_layers.active, obj.name
    obj.data.calc_loop_triangles()
    assert 0 < len(obj.data.loop_triangles) <= 10000, obj.name
    points.extend(obj.matrix_world @ vertex.co for vertex in obj.data.vertices)
    assert obj.data.materials
    material = obj.data.materials[0]
    textures = [node.image for node in material.node_tree.nodes if node.type == 'TEX_IMAGE' and node.image]
    assert textures and all(tuple(image.size) == (128, 128) for image in textures), obj.name
assert all(math.isfinite(value) for point in points for value in point)
height = max(p.z for p in points) - min(p.z for p in points)
# Five and a half studs, at .28 metres per stud, in Blender's default metre scene.
assert abs(height - 5.5 * .28) < .02, height
print('PASS static study: seven meshes; color atlas/UVs; triangle limits; height', round(height, 4), 'metres')
