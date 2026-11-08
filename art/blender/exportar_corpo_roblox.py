"""Build a rigid 15-part visual skin + color atlas for Studio, from our body generator.
Run using Blender in background. Does not create or publish Roblox asset IDs.
"""
from pathlib import Path
import runpy
import math
import bpy
import bmesh
from mathutils import Vector, Matrix

folder=Path(__file__).resolve().parent
ns=runpy.run_path(str(folder/'criar_corpo_base.py'))
scene=bpy.context.scene
out=folder.parent/'roblox'; out.mkdir(exist_ok=True)
# Blender convention: X lateral, -Y front, Z up. Each exported binding is upright.
profiles={
 'Head':((0,0,3.84),(.95,.80,1.15)),
 'UpperTorso':((0,0,2.62),(1.12,.66,.84)),
 'LowerTorso':((0,0,2.02),(.94,.60,.36)),
}
for side,s in [('Left',1),('Right',-1)]:
    for part,center,size in [
      ('UpperArm',(s*.75,0,2.62),(.44,.44,.62)),
      ('LowerArm',(s*1.02,0,2.12),(.44,.44,.42)),
      ('Hand',(s*1.15,0,1.73),(.44,.44,.38)),
      ('UpperLeg',(s*.29,0,1.55),(.52,.55,.58)),
      ('LowerLeg',(s*.32,0,.96),(.48,.50,.60)),
      ('Foot',(s*.32,-.15,.43),(.56,.85,.46)),
    ]: profiles[side+part]=(center,size)

materials=[]
for obj in scene.objects:
    if obj.parent and obj.type in {'MESH','CURVE'}:
        for mat in obj.data.materials:
            if mat not in materials: materials.append(mat)
assert len(materials)<=16
# Palette atlas: explicit UVs and PNG instead of relying on Blender shaders.
image=bpy.data.images.new('MUBlox_StarterColors',width=128,height=128,alpha=True)
def srgb(v): return 12.92*v if v<=.0031308 else 1.055*v**(1/2.4)-.055
colors=[tuple(srgb(v) for v in m.diffuse_color[:3])+(1,) for m in materials]
pixels=[]
for y in range(128):
    for x in range(128): pixels.extend(colors[min((y//32)*4+x//32,len(colors)-1)])
image.pixels=pixels; image.filepath_raw=str(out/'Guerreiro_Cores.png'); image.file_format='PNG'; image.save()
texmat=bpy.data.materials.new('MUBlox_StarterAtlas'); texmat.use_nodes=True
node=texmat.node_tree.nodes.new('ShaderNodeTexImage'); node.image=image
texmat.node_tree.links.new(node.outputs['Color'],texmat.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
texmat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.65

# Collect evaluated, capped cuts. Plane normal points toward the discarded side.
buckets={}
current_layer='Body'
def clip(bm,point,normal):
    first_face=next(iter(bm.faces),None)
    fill_material=first_face.material_index if first_face else 0
    result=bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.00001,
        plane_co=Vector(point),plane_no=Vector(normal),clear_outer=True,clear_inner=False)
    boundary=[e for e in result['geom_cut'] if isinstance(e,bmesh.types.BMEdge) and e.is_boundary]
    if boundary:
        filled=bmesh.ops.holes_fill(bm,edges=boundary,sides=0)
        for face in filled['faces']: face.material_index=fill_material

def put(source,name,planes):
    bm=source.copy()
    for point,normal in planes: clip(bm,point,normal)
    if bm.faces:
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        buckets.setdefault((name,current_layer),[]).append(bm)
    else: bm.free()

def upper(z): return ((0,0,z),(0,0,-1))
def lower(z): return ((0,0,z),(0,0,1))
def side_clip(s,x=0): return ((x,0,0),(-s,0,0))

deps=bpy.context.evaluated_depsgraph_get()
for obj in list(scene.objects):
    if not obj.parent or obj.type not in {'MESH','CURVE'}: continue
    ev=obj.evaluated_get(deps); data=ev.to_mesh()
    bm=bmesh.new(); bm.from_mesh(data); bm.transform(obj.matrix_world)
    for f in bm.faces:
        m=obj.data.materials[min(f.material_index,len(obj.data.materials)-1)]
        f.material_index=materials.index(m)
    slot=obj.parent.get('equipment_slot')
    current_layer={'Hair':'Helmet','StarterShirt':'Armor','StarterGloves':'Gloves','StarterBoots':'Boots','StarterPants':'Pants'}.get(slot,'Body')
    if slot in {'Face','Hair'} or obj.name.startswith('Cabeca'):
        put(bm,'Head',[])
    elif slot=='StarterShirt':
        if obj.name.startswith(('Cinto','Fivela','Acabamento_Frontal')):
            put(bm,'LowerTorso',[])
        else:
            put(bm,'UpperTorso',[upper(2.20)]); put(bm,'LowerTorso',[lower(2.20)])
    elif slot=='StarterGloves':
        for side,s in [('Left',1),('Right',-1)]: put(bm,side+'Hand',[side_clip(s)])
    elif slot=='StarterBoots':
        for side,s in [('Left',1),('Right',-1)]:
            put(bm,side+'LowerLeg',[side_clip(s),upper(.66)])
            put(bm,side+'Foot',[side_clip(s),lower(.66)])
    else:
        # Core and upper limbs, then split the lower body into two legs.
        if slot=='Body':
            for side,s in [('Left',1),('Right',-1)]:
                outer=side_clip(s,s*.60)
                for suffix,planes in [('UpperArm',[upper(2.32)]),('LowerArm',[lower(2.32),upper(1.94)]),('Hand',[lower(1.94)])]:
                    put(bm,side+suffix,[outer]+planes)
            core=[((-.60,0,0),(-1,0,0)),((.60,0,0),(1,0,0))]
            put(bm,'UpperTorso',core+[upper(2.20)])
            put(bm,'LowerTorso',core+[upper(1.84),lower(2.20)])
        else:
            core=[]; put(bm,'LowerTorso',[upper(1.84)])
        for side,s in [('Left',1),('Right',-1)]:
            for suffix,planes in [('UpperLeg',[upper(1.26),lower(1.84)]),('LowerLeg',[upper(.66),lower(1.26)]),('Foot',[lower(.66)])]:
                put(bm,side+suffix,core+[side_clip(s)]+planes)
    bm.free(); ev.to_mesh_clear()

# Round joints overlap the adjacent rigid segments, softening guillotine cuts.
for side,sign in [('Left',1),('Right',-1)]:
    for suffix,position,radii,layer,mat in [
        ('LowerArm',(sign*.91,0,2.32),(.18,.19,.19),'Body',ns['skin']),
        ('Hand',(sign*1.13,0,1.94),(.155,.15,.14),'Body',ns['skin']),
        ('LowerLeg',(sign*.30,0,1.26),(.195,.215,.18),'Body',ns['skin']),
        ('LowerLeg',(sign*.30,0,1.26),(.218,.238,.20),'Pants',ns['pants_mat']),
    ]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,location=position)
        obj=bpy.context.object; obj.scale=radii
        bpy.context.view_layer.update()
        bm=bmesh.new(); bm.from_mesh(obj.data); bm.transform(obj.matrix_world)
        for face in bm.faces: face.material_index=materials.index(mat)
        current_layer=layer; put(bm,side+suffix,[]); bm.free()
        bpy.data.objects.remove(obj,do_unlink=True)

def arm_center(z):
    points=[(1.40,1.15),(1.94,1.13),(2.32,.91),(2.90,.59),(3.3,.59)]
    for (a,x),(b,y) in zip(points,points[1:]):
        if z<=b:
            t=max(0,min(1,(z-a)/(b-a)))
            return x+(y-x)*t
    return points[-1][1]

export=bpy.data.collections.new('Export_R15_Visual_V2'); scene.collection.children.link(export)
objects=[]
for (name,layer),parts in buckets.items():
    verts=[]; faces=[]; palette=[]
    for bm in parts:
        bm.verts.ensure_lookup_table(); bm.verts.index_update()
        offset=len(verts); verts += [tuple(v.co) for v in bm.verts]
        faces += [tuple(offset+v.index for v in f.verts) for f in bm.faces]
        palette += [f.material_index for f in bm.faces]
        bm.free()
    # Remove the A-pose's lateral slope before attaching to upright R15 limbs.
    if name.endswith(('UpperArm','LowerArm','Hand')):
        sign=1 if name.startswith('Left') else -1
        center=abs(profiles[name][0][0])
        verts=[(x-sign*(arm_center(z)-center),y,z) for x,y,z in verts]
    mesh_name='Visual_'+name if layer=='Body' else 'Wear_'+layer+'_'+name
    data=bpy.data.meshes.new(mesh_name); data.from_pydata(verts,[],faces); data.update()
    obj=bpy.data.objects.new(mesh_name,data); export.objects.link(obj); data.materials.append(texmat)
    uv=data.uv_layers.new(name='UVMap')
    for poly,idx in zip(data.polygons,palette):
        poly.use_smooth=True
        for loop in poly.loop_indices: uv.data[loop].uv=((idx%4+.5)/4,(idx//4+.5)/4)
    if len(data.polygons)>3000:
        bpy.context.view_layer.objects.active=obj
        mod=obj.modifiers.new('Simplificar','DECIMATE'); mod.ratio=min(1,2500/len(data.polygons))
        bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=obj.modifiers.new('Triangulos','TRIANGULATE')
    bpy.context.view_layer.objects.active=obj; bpy.ops.object.modifier_apply(modifier=mod.name)
    assert len(obj.data.polygons)<=10000,(name,len(obj.data.polygons))
    objects.append(obj)
for name,(center,size) in profiles.items():
    assert (name,'Body') in buckets,name
    bpy.ops.mesh.primitive_cube_add(size=1,location=center)
    marker=bpy.context.object; marker.name='Bind_'+name; marker.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    for col in list(marker.users_collection): col.objects.unlink(marker)
    export.objects.link(marker); objects.append(marker)
for name,pos in [('AxisOrigin',(0,0,0)),('AxisUp',(0,0,1)),('AxisFront',(0,-1,0)),('FormatV2',(0,1,0))]:
    bpy.ops.mesh.primitive_cube_add(size=.05,location=pos); obj=bpy.context.object; obj.name=name
    for col in list(obj.users_collection): col.objects.unlink(obj)
    export.objects.link(obj); objects.append(obj)
bpy.ops.object.select_all(action='DESELECT')
for obj in objects: obj.select_set(True)
bpy.context.view_layer.objects.active=objects[0]
bpy.ops.export_scene.fbx(filepath=str(out/'Guerreiro_Visual_R15.fbx'),use_selection=True,
    object_types={'MESH'},use_mesh_modifiers=True,add_leaf_bones=False,bake_anim=False,
    axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
print('PASS V2 export:',len(objects),'objects; independent clothing and binding markers')
for obj in objects:
    if obj.name.startswith(('Visual_','Wear_')): print(obj.name,len(obj.data.polygons),'triangles')
