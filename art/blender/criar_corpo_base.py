"""MUBlox: corpo-base do Guerreiro. Blender 4.2+; testado em 4.3.2.
Scripting > Text > Open > Run Script. Cria nova cena; nao apaga nem salva arquivos.
Base visual sem rig/UV, sem encaixe R15. Frente -Y, vertical Z.
"""
import math
import bpy
import bmesh
from mathutils import Vector

def material(name, color, metallic=0, roughness=0.4, emission=0):
    mat = bpy.data.materials.new('MUB_' + name)
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = color
    bsdf.inputs['Metallic'].default_value = metallic
    bsdf.inputs['Roughness'].default_value = roughness
    if emission:
        bsdf.inputs['Emission Color'].default_value = color
        bsdf.inputs['Emission Strength'].default_value = emission
    return mat


def collection(name):
    col = bpy.data.collections.new(name)
    scene.collection.children.link(col)
    return col


def finish(obj, name, mat, col, parent=None, smooth=True):
    obj.name = name
    for previous in list(obj.users_collection):
        previous.objects.unlink(obj)
    col.objects.link(obj)
    if mat:
        obj.data.materials.append(mat)
    if obj.type == 'MESH' and smooth:
        for face in obj.data.polygons:
            face.use_smooth = True
    if parent:
        obj.parent = parent  # roots have identity transforms
    return obj


def mesh(name, vertices, faces, mat, col, parent=None, smooth=False):
    data = bpy.data.meshes.new(name)
    data.from_pydata(vertices, [], faces)
    data.update()
    obj = bpy.data.objects.new(name, data)
    col.objects.link(obj)
    return finish(obj, name, mat, col, parent, smooth)


def bevel(obj, amount=0.04):
    mod = obj.modifiers.new('Bordas arredondadas', 'BEVEL')
    mod.width = amount
    mod.segments = 3
    normals = obj.modifiers.new('Normais das placas', 'WEIGHTED_NORMAL')
    normals.keep_sharp = True
    return obj


def sphere(name, position, scale, mat, col, parent=None):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, location=position)
    obj = bpy.context.object
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(obj, name, mat, col, parent)


def tube(name, points, radii, mat, col, parent=None, sides=10):
    """Closed tapered tube: curved horns, wing ribs, trim and grips."""
    points = [Vector(p) for p in points]
    vertices, faces = [], []
    for i, (point, radius) in enumerate(zip(points, radii)):
        tangent = points[min(i + 1, len(points) - 1)] - points[max(i - 1, 0)]
        tangent.normalize()
        reference = Vector((0, 1, 0)) if abs(tangent.y) < 0.9 else Vector((1, 0, 0))
        u = tangent.cross(reference).normalized()
        v = tangent.cross(u).normalized()
        for j in range(sides):
            a = 2 * math.pi * j / sides
            vertices.append(tuple(point + radius * (math.cos(a) * u + math.sin(a) * v)))
    for i in range(len(points) - 1):
        for j in range(sides):
            a, b = i * sides + j, i * sides + (j + 1) % sides
            faces.append((a, b, b + sides, a + sides))
    faces += [tuple(reversed(range(sides))), tuple(range(len(vertices) - sides, len(vertices)))]
    return mesh(name, vertices, faces, mat, col, parent, True)


def plate(name, outline, y, depth, mat, col, parent=None, rounding=0.03):
    """Closed X/Z plate; negative Y is the visible front."""
    n = len(outline)
    vertices = [(x, y, z) for x, z in outline] + [(x, y + depth, z) for x, z in outline]
    faces = [tuple(range(n)), tuple(reversed(range(n, 2 * n)))]
    faces += [(i, (i + 1) % n, (i + 1) % n + n, i + n) for i in range(n)]
    obj = mesh(name, vertices, faces, mat, col, parent)
    return bevel(obj, rounding) if rounding else obj


def inset(name, outline, y, depth, mat, col, parent, shrink=0.86):
    plate(name + '_Borda', outline, y, depth, gold, col, parent)
    cx = sum(p[0] for p in outline) / len(outline)
    cz = sum(p[1] for p in outline) / len(outline)
    inside = [(cx + (x-cx)*shrink, cz + (z-cz)*shrink) for x,z in outline]
    return plate(name, inside, y-0.035, depth, mat, col, parent)


def root(name, col, slot):
    obj = bpy.data.objects.new(name, None)
    col.objects.link(obj)
    obj.empty_display_size = 0.15
    obj['equipment_slot'] = slot
    obj['stage'] = 'Base visual; adaptar ao R15 antes de exportar'
    return obj


def look_at(obj, target):
    obj.rotation_euler = (Vector(target)-obj.location).to_track_quat('-Z', 'Y').to_euler()


def curve(name, points, radius, mat, col, parent=None):
    data=bpy.data.curves.new(name,'CURVE'); data.dimensions='3D'
    data.resolution_u=16; data.bevel_depth=radius; data.bevel_resolution=3
    spline=data.splines.new('BEZIER'); spline.bezier_points.add(len(points)-1)
    for bp,point in zip(spline.bezier_points,points):
        bp.co=point; bp.handle_left_type='AUTO'; bp.handle_right_type='AUTO'
    obj=bpy.data.objects.new(name,data); col.objects.link(obj)
    obj.data.materials.append(mat); obj.parent=parent
    return obj


def merge_skin(objects,name,col,parent,voxel=.035,smooth_iterations=5):
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects: obj.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    bpy.ops.object.join(); obj=bpy.context.object; obj.name=name
    remesh=obj.modifiers.new('Unir volumes organicos','REMESH'); remesh.mode='VOXEL'; remesh.voxel_size=voxel
    bpy.ops.object.modifier_apply(modifier=remesh.name)
    smooth=obj.modifiers.new('Suavizar anatomia','SMOOTH'); smooth.factor=1.2; smooth.iterations=smooth_iterations
    bpy.ops.object.modifier_apply(modifier=smooth.name)
    for p in obj.data.polygons: p.use_smooth=True
    return obj


if bpy.context.object and bpy.context.object.mode!='OBJECT': bpy.ops.object.mode_set(mode='OBJECT')
scene=bpy.data.scenes.new('MUBlox_Corpo_Base'); bpy.context.window.scene=scene
scene['stage']='Prototipo visual: sem rig, UV ou escala R15 calibrada'
scene['front_axis']='-Y'
skin=material('Pele',(.63,.32,.135,1),0,.48)
inner=material('Orelha',(.42,.15,.075,1),0,.55)
hair=material('Cabelo',(.075,.027,.012,1),0,.38)
hair_light=material('Mechas',(.12,.045,.018,1),0,.42)
white=material('Olhos',(.92,.90,.80,1),0,.25)
iris=material('Iris',(.15,.052,.015,1),0,.25)
black=material('Pupilas',(.005,.003,.002,1),0,.25)
olive=material('Tunica',(.14,.16,.035,1),0,.8)
pants_mat=material('Calcas',(.055,.069,.025,1),0,.8)
gold=material('Bordado',(.67,.38,.075,1),.1,.55)
leather=material('Couro',(.12,.052,.025,1),0,.58)
sole=material('Sola',(.045,.022,.012,1),0,.7)
cols={key:collection(name) for key,name in [('body','01_Corpo'),('face','02_Rosto'),('hair','03_Cabelo'),('shirt','04_Tunica'),('pants','05_Calcas'),('gloves','06_Luvas'),('boots','07_Botas'),('stage','08_Apresentacao_Nao_Exportar')]}
roots={key:root(name,cols[key],name) for key,name in [('body','Body'),('face','Face'),('hair','Hair'),('shirt','StarterShirt'),('pants','StarterPants'),('gloves','StarterGloves'),('boots','StarterBoots')]}
def ball(name,pos,scale,mat,key): return sphere(name,pos,scale,mat,cols[key],roots.get(key))
def line(name,points,radius,mat,key): return curve(name,points,radius,mat,cols[key],roots.get(key))

# Torso/legs are distinct from arm chains: shoulder volumes must not be cut
# vertically and then attached partly to the torso and partly to the upper arm.
parts=[ball('Torso',(0,0,2.50),(.49,.265,.55),skin,'body'),ball('Quadril',(0,0,1.98),(.46,.29,.35),skin,'body'),ball('Pescoco',(0,0,3.02),(.20,.21,.32),skin,'body')]
for s in [-1,1]:
    parts += [ball('Coxa',(s*.28,0,1.60),(.25,.26,.43),skin,'body'),ball('Joelho',(s*.30,0,1.22),(.20,.22,.20),skin,'body'),ball('Canela',(s*.32,0,.91),(.19,.20,.35),skin,'body'),ball('Pe',(s*.32,-.12,.42),(.23,.36,.17),skin,'body')]
merge_skin(parts,'Corpo_Organico',cols['body'],roots['body'])
for side,s in [('Left',1),('Right',-1)]:
    arm_parts=[ball('Ombro',(s*.60,0,2.82),(.22,.22,.23),skin,'body'),
        ball('Braco',(s*.76,0,2.59),(.175,.18,.30),skin,'body'),
        ball('Cotovelo',(s*.91,0,2.32),(.16,.17,.18),skin,'body'),
        ball('Antebraco',(s*1.02,0,2.13),(.16,.16,.27),skin,'body')]
    arm=merge_skin(arm_parts,'Braco_Base_'+side,cols['body'],roots['body'],voxel=.022)
    arm['R15Chain']=side
    # Palm, four separate fingertips and an opposing thumb. Finer voxel size
    # keeps the finger gaps instead of melting them into the previous mitten.
    hand_parts=[ball('Palma',(s*1.15,-.015,1.80),(.15,.09,.14),skin,'body'),
        ball('Pulso',(s*1.15,0,1.93),(.105,.105,.09),skin,'body')]
    lengths=[.135,.16,.15,.115]
    for i,length in enumerate(lengths):
        hand_parts.append(ball('Dedo_'+str(i),(s*(1.15+(i-1.5)*.077),-.025,1.65),(.031,.052,length),skin,'body'))
    hand_parts += [ball('Base_Polegar',(s*.995,-.025,1.80),(.065,.07,.08),skin,'body'),
        ball('Polegar',(s*.96,-.05,1.71),(.047,.065,.115),skin,'body')]
    hand=merge_skin(hand_parts,'Mao_Base_'+side,cols['body'],roots['body'],voxel=.009,smooth_iterations=3)
    hand['R15Part']=side+'Hand'
# Head is deliberately large; ears and nose merge into the face.
parts=[ball('Cranio',(0,0,3.84),(.72,.57,.79),skin,'body'),ball('Mandibula',(0,-.045,3.47),(.56,.47,.36),skin,'body'),ball('Nariz',(0,-.555,3.66),(.13,.13,.11),skin,'body')]
for s in [-1,1]: parts.append(ball('Orelha',(s*.71,.015,3.66),(.15,.13,.24),skin,'body'))
merge_skin(parts,'Cabeca',cols['body'],roots['body'])
for s in [-1,1]:
    ball('Interior_Orelha',(s*.75,-.103,3.66),(.075,.026,.13),inner,'face')
    eye=ball('Olho',(s*.275,-.500,3.87),(.20,.065,.235),white,'face')
    ball('Iris',(s*.275,-.553,3.86),(.11,.022,.15),iris,'face')
    ball('Pupila',(s*.275,-.572,3.86),(.062,.012,.10),black,'face')
    ball('Reflexo',(s*.275-.035,-.583,3.925),(.028,.006,.035),white,'face')
    line('Sobrancelha',[(s*.11,-.54,4.16),(s*.28,-.55,4.20),(s*.45,-.48,4.15)],.045,hair,'face')
line('Sorriso',[(-.22,-.47,3.47),(0,-.514,3.425),(.22,-.47,3.47)],.014,inner,'face')
# Hair cap follows the scalp. Front rim leaves eyes and brows unobstructed.
verts=[]; faces=[]; segments=48; rings=16
for j in range(rings):
    for i in range(segments):
        a=2*math.pi*i/segments
        front=(1-math.sin(a))/2
        limit=2.0-.80*front
        t=.012+(limit-.012)*j/(rings-1)
        verts.append((.745*math.sin(t)*math.cos(a),.60*math.sin(t)*math.sin(a),3.87+.83*math.cos(t)))
for j in range(rings-1):
    for i in range(segments):
        a=j*segments+i; b=j*segments+(i+1)%segments
        faces.append((a,b,b+segments,a+segments))
faces += [tuple(reversed(range(segments))),tuple(range((rings-1)*segments,rings*segments))]
mesh('Cabelo_Capa',verts,faces,hair,cols['hair'],roots['hair'],True)
# Swept tapered locks with smooth longitudinal profiles.
def lock(name,control,width,mat):
    p=[Vector(v) for v in control]; points=[]; radii=[]
    for i in range(16):
        t=i/15
        q=(1-t)**3*p[0]+3*(1-t)**2*t*p[1]+3*(1-t)*t*t*p[2]+t**3*p[3]
        points.append(tuple(q)); radii.append(max(.004,width*math.sin(math.pi*(.15+.85*t))**.8))
    return tube(name,points,radii,mat,cols['hair'],roots['hair'],12)
for i in range(5):
    x=-.48+i*.22
    lock('Franja',[(x+.20,-.20,4.52),(x+.33,-.52,4.60),(x-.08,-.65,4.27),(x-.20,-.55,4.12+i*.025)],.16,hair_light if i%2 else hair)
for s in [-1,1]:
    for i in range(3):
        y=.05+i*.18
        lock('Mecha_Lateral',[(s*.49,y,4.42),(s*.76,y+.08,4.26),(s*.77,y+.06,3.98),(s*.66,y+.04,3.78)],.13,hair)
lock('Topete',[(-.30,.05,4.51),(-.05,-.05,4.73),(.38,-.1,4.70),(.56,-.06,4.54)],.17,hair_light)

# Oval cloth shell rings. Independent outfit pieces, not fused with the skin.
def garment(name,levels,mat,key):
    vertices=[]; faces=[]; n=48
    for z,rx,ry in levels:
        vertices += [(rx*math.cos(i*2*math.pi/n),ry*math.sin(i*2*math.pi/n),z) for i in range(n)]
    for j in range(len(levels)-1):
        for i in range(n):
            a=j*n+i; b=j*n+(i+1)%n; faces.append((a,b,b+n,a+n))
    obj=mesh(name,vertices,faces,mat,cols[key],roots[key],True)
    mod=obj.modifiers.new('Tecido','SOLIDIFY'); mod.thickness=.025
    return obj

garment('Tunica',[(1.65,.63,.36),(1.80,.58,.345),(2.12,.44,.32),(2.40,.53,.34),(2.70,.57,.34),(2.84,.51,.33),(2.98,.23,.245)],olive,'shirt')
# Tunic shoulders taper to a neck opening, arms remain clear of cloth.
for z,rx,ry in [(1.65,.635,.365),(2.98,.235,.25)]:
    line('Bainha',[(rx*math.cos(i*2*math.pi/48),ry*math.sin(i*2*math.pi/48),z) for i in range(49)],.025,gold,'shirt')
for s in [-1,1]:
    line('Acabamento_Frontal',[(s*.20,-.325,2.13),(s*.25,-.34,1.90),(s*.32,-.32,1.66)],.022,gold,'shirt')
# Small original insignia, no borrowed crest.
line('Emblema',[ (0,-.34,2.79),(.09,-.346,2.67),(0,-.35,2.55),(-.09,-.346,2.67),(0,-.34,2.79)],.018,gold,'shirt')
garment('Cinto',[(2.10,.465,.34),(2.23,.465,.34)],leather,'shirt')
line('Fivela',[(-.11,-.355,2.12),(.11,-.355,2.12),(.11,-.355,2.22),(-.11,-.355,2.22),(-.11,-.355,2.12)],.025,gold,'shirt')
ball('Calcas_Quadril',(0,0,1.94),(.47,.30,.32),pants_mat,'pants')
for s in [-1,1]:
    ball('Calca_Perna',(s*.29,0,1.48),(.265,.275,.51),pants_mat,'pants')
    ball('Bota_Cano',(s*.32,0,.83),(.24,.25,.38),leather,'boots')
    ball('Bota_Pe',(s*.32,-.16,.39),(.27,.42,.22),leather,'boots')
    ball('Sola',(s*.32,-.17,.25),(.28,.425,.075),sole,'boots')
    ball('Dobra_Bota',(s*.32,0,1.10),(.27,.28,.12),gold,'boots')
    glove=garment('Luva',[(1.72,.155,.105),(1.83,.16,.11),(1.94,.118,.118)],leather,'gloves')
    glove.location.x=s*1.15; glove.location.y=-.015
    line('Costura_Luva',[(s*1.07,-.12,1.91),(s*1.08,-.13,1.82),(s*1.08,-.12,1.74)],.006,gold,'gloves')

# Rendering stage, separate from the character.
stage=cols['stage']
stone=material('Pedestal',(.055,.075,.10,1),.1,.6)
floor_mat=material('Fundo',(.16,.19,.22,1),0,.8)
bpy.ops.mesh.primitive_cylinder_add(vertices=64,radius=1.65,depth=.14,location=(0,0,.09))
bevel(finish(bpy.context.object,'Pedestal',stone,stage),.04)
bpy.ops.mesh.primitive_plane_add(size=200)
finish(bpy.context.object,'Chao',floor_mat,stage)
world=bpy.data.worlds.new('Estudio_Corpo'); scene.world=world; world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.25,.28,.34,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.4
for name,pos,power,color,size in [('Principal',(3,-6,8),850,(1,.85,.7),5),('Preenchimento',(-4,-3,5),600,(.7,.8,1),4),('Recorte',(2,3,7),1000,(1,.76,.48),3)]:
    data=bpy.data.lights.new(name,'AREA'); data.energy=power; data.color=color; data.size=size
    obj=bpy.data.objects.new(name,data); stage.objects.link(obj); obj.location=pos; look_at(obj,(0,0,2.5))
data=bpy.data.cameras.new('Camera'); camera=bpy.data.objects.new('Camera',data); stage.objects.link(camera)
camera.location=(5,-17,7); look_at(camera,(0,0,2.55)); data.type='ORTHO'; data.ortho_scale=6.0; scene.camera=camera
scene.render.engine='CYCLES'; scene.cycles.samples=48; scene.cycles.use_denoising=False
scene.render.resolution_x=1000; scene.render.resolution_y=1100; scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'; scene.view_settings.view_transform='AgX'
for obj in scene.objects:
    if obj.type=='MESH':
        bm=bmesh.new(); bm.from_mesh(obj.data); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(obj.data); bm.free(); obj.data.update()
bpy.ops.object.select_all(action='DESELECT'); roots['body'].select_set(True); bpy.context.view_layer.objects.active=roots['body']
for screen in bpy.data.screens:
    for area in screen.areas:
        if area.type=='VIEW_3D':
            sp=area.spaces.active; sp.shading.type='SOLID'; sp.shading.color_type='MATERIAL'
            sp.region_3d.view_distance=7; sp.region_3d.view_location=(0,0,2.5); sp.region_3d.view_rotation=camera.rotation_euler.to_quaternion()
print('MUBlox: corpo-base criado em nova cena. Salve como .blend. Ainda sem rig/UV.')
