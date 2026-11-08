"""Novo estudo visual; nao substitui o FBX jogavel. Executar ao lado de criar_corpo_base.py."""
from pathlib import Path
import runpy
import math
import bpy
from mathutils import Vector
ns=runpy.run_path(str(Path(__file__).with_name('criar_corpo_base.py')))
scene=bpy.context.scene; scene.name='MUBlox_Estudo_Referencia'
scene['stage']='Estudo visual de proporcoes; sem rig/UV. Nao exportar como substituto do personagem atual.'
# Continuous tapered arm profiles, avoiding stacked spherical muscle volumes.
for side,sign in [('Left',1),('Right',-1)]:
    old=next(o for o in scene.objects if o.get('R15Chain')==side)
    bpy.data.objects.remove(old,do_unlink=True)
    points=[]; radii=[]
    control=[Vector((sign*.59,0,2.91)),Vector((sign*.72,0,2.65)),Vector((sign*1.0,0,2.25)),Vector((sign*1.15,0,1.94))]
    for i in range(33):
        t=i/32
        p=(1-t)**3*control[0]+3*(1-t)**2*t*control[1]+3*(1-t)*t*t*control[2]+t**3*control[3]
        radius=.20-.085*t+.016*math.sin(math.pi*t)
        points.append(tuple(p)); radii.append(radius)
    arm=ns['tube']('Braco_Continuo_'+side,points,radii,ns['skin'],ns['cols']['body'],ns['roots']['body'],24)
    ns['ball']('Braco_Continuo_Ombro_'+side,(sign*.48,0,2.84),(.29,.225,.265),ns['skin'],'body')
# Convert cloth trims to editable geometry before transforming proportions.
for obj in list(scene.objects):
    if obj.parent and obj.type=='CURVE':
        bpy.ops.object.select_all(action='DESELECT'); obj.select_set(True)
        bpy.context.view_layer.objects.active=obj; bpy.ops.object.convert(target='MESH')
for obj in scene.objects:
    if obj.type!='MESH' or not obj.parent: continue
    slot=obj.parent.get('equipment_slot')
    head=slot in {'Hair','Face'} or obj.name.startswith('Cabeca')
    hand=obj.get('R15Part') in {'LeftHand','RightHand'} or slot=='StarterGloves'
    world=obj.matrix_world.copy(); inverse=world.inverted()
    for vert in obj.data.vertices:
        p=world@vert.co
        if head:
            p=Vector((p.x*1.20,p.y*1.20,3.84+(p.z-3.84)*1.15))
        if hand:
            center=Vector((1.15 if p.x>0 else -1.15,-.015,1.83))
            p=center+(p-center)*1.12
        p.z=.20+(p.z-.20)*.90 if p.z<1.65 else p.z-.145
        vert.co=inverse@p
    obj.data.update()
# Unify torso and arms into a continuous shoulder surface for the visual study.
skin_parts=[o for o in scene.objects if o.type=='MESH' and (o.name.startswith('Corpo_Organico') or o.name.startswith('Braco_Continuo'))]
ns['merge_skin'](skin_parts,'Corpo_Continuo_Estudo',ns['cols']['body'],ns['roots']['body'],voxel=.018,smooth_iterations=3)
for mat in [ns['hair'],ns['hair_light']]:
    mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.58
scene.camera.location=(4,-19,7); ns['look_at'](scene.camera,(0,0,2.5))
scene.camera.data.ortho_scale=5.8
print('Estudo de referencia criado: cabeca ampliada, pernas compactas e ombros/bracos continuos. Sem rig.')
