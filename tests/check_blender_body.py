"""Run in Blender: generation, modularity and scene-preservation integration check."""
from pathlib import Path
import math
import runpy
import bpy

script=Path(__file__).resolve().parents[1]/'art/blender/criar_corpo_base.py'
original=bpy.context.scene
original_objects=set(original.objects)
scenes=len(bpy.data.scenes)
for i in range(2):
    runpy.run_path(str(script))
    generated=bpy.context.scene
    assert len(bpy.data.scenes)==scenes+i+1
    assert set(original.objects)==original_objects
    assert len(generated.collection.children)==8
    slots={o.get('equipment_slot') for o in generated.objects}
    assert {'Body','Face','Hair','StarterShirt','StarterPants','StarterGloves','StarterBoots'} <= slots
    assert not slots.intersection({'Sword','Wings','Helmet'})
    assert generated.camera
    for obj in generated.objects:
        if obj.type=='MESH':
            assert obj.data.materials and obj.data.polygons, obj.name
            assert all(math.isfinite(n) for v in obj.data.vertices for n in v.co),obj.name
    if i==0:
        first=generated; first_objects=set(first.objects)
    else:
        assert set(first.objects)==first_objects
    print('PASS body generation',i+1,': preserved previous scenes; separate clothing; finite geometry')
