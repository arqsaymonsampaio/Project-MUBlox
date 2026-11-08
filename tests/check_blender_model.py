"""Integration checks executed inside Blender, not a mock of bpy."""
import math
from pathlib import Path
import runpy

import bpy
import bmesh

script = Path(__file__).resolve().parents[1] / 'art/blender/criar_guerreiro.py'
original_scene = bpy.context.scene
original_objects = set(original_scene.objects)
before_scenes = set(bpy.data.scenes)
required = {'Body', 'Helmet', 'Armor', 'Gloves', 'Pants', 'Boots', 'Sword', 'Wings'}

for iteration in range(2):
    runpy.run_path(str(script))
    scene = bpy.context.scene
    assert scene != original_scene
    assert len(bpy.data.scenes) == len(before_scenes) + iteration + 1
    assert set(original_scene.objects) == original_objects, 'Changed original scene'
    assert required <= {obj.get('equipment_slot') for obj in scene.objects}
    assert scene.camera and len(scene.collection.children) == 9
    vertices = triangles = 0
    for obj in scene.objects:
        if obj.type != 'MESH':
            continue
        assert obj.data.materials, obj.name
        assert len(obj.data.polygons), obj.name
        assert all(math.isfinite(c) for v in obj.data.vertices for c in v.co), obj.name
        assert all(p.area > 1e-9 for p in obj.data.polygons), 'Degenerate face: ' + obj.name
        if not obj.name.startswith(('Membrana_', 'Chao_')):
            bm = bmesh.new()
            bm.from_mesh(obj.data)
            assert all(e.is_manifold for e in bm.edges), 'Open shell: ' + obj.name
            bm.free()
        obj.data.calc_loop_triangles()
        vertices += len(obj.data.vertices)
        triangles += len(obj.data.loop_triangles)
    print(f'PASS generation {iteration+1}: {vertices} vertices, {triangles} base triangles; scene preserved')
    if iteration == 0:
        first_scene, first_objects = scene, set(scene.objects)
    else:
        assert set(first_scene.objects) == first_objects, 'Changed first generated model'

print('PASS all Blender model integration checks')
