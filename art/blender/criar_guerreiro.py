"""MUBlox — Guerreiro Rubro, base visual procedural, Blender 4.2+.

Scripting > Text > Open > este arquivo > Run Script (Alt+P).
Cria UMA NOVA CENA a cada execução. Não apaga nem salva arquivos existentes.
Frente = -Y, vertical = Z. Ainda sem rig, UV ou escala calibrada para R15.
Somente módulos que acompanham o Blender; não usa rede nem instala extensões.
"""

import math
import bpy
import bmesh
from mathutils import Vector

# Ajustes simples: execute novamente para gerar uma nova versão independente.
CRIAR_ASAS = True
CRIAR_ESPADA = True
VERMELHO = (0.38, 0.025, 0.018, 1)
VERMELHO_CLARO = (0.63, 0.065, 0.028, 1)
DOURADO = (0.68, 0.37, 0.085, 1)


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


# A new scene avoids destroying the user's cube, Elmo_Base or previous model.
if bpy.context.object and bpy.context.object.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')
scene = bpy.data.scenes.new('MUBlox_Guerreiro_Base')
bpy.context.window.scene = scene
scene['description'] = 'Guerreiro Rubro — estudo de armadura modular, ainda sem rig/UV.'
scene['front_axis'] = '-Y'

red = material('Armadura_Rubra', VERMELHO, 0.65, 0.3)
bright = material('Placas_Vermelhas', VERMELHO_CLARO, 0.55, 0.33)
gold = material('Metal_Dourado', DOURADO, 0.78, 0.26)
dark = material('Malha_Escura', (0.018, 0.024, 0.035, 1), 0.15, 0.6)
black = material('Viseira', (0.006, 0.012, 0.018, 1), 0.25, 0.22)
membrane = material('Membrana_Vinho', (0.095, 0.012, 0.027, 1), 0.08, 0.52)
steel = material('Aco', (0.40, 0.56, 0.67, 1), 0.85, 0.23)
glow = material('Cristais_Ambar', (1, 0.31, 0.035, 1), 0.35, 0.22, 2)

body_col = collection('01_Corpo_Base')
helmet_col = collection('02_Helmet_Elmo')
armor_col = collection('03_Armor_Peito_Ombros')
gloves_col = collection('04_Gloves_Luvas')
pants_col = collection('05_Pants_Calcas')
boots_col = collection('06_Boots_Botas')
sword_col = collection('07_Sword_Espada')
wings_col = collection('08_Wings_Asas')
stage_col = collection('09_Apresentacao_Nao_Exportar')
body = root('Corpo_Base', body_col, 'Body')
helmet = root('Helmet', helmet_col, 'Helmet')
armor = root('Armor', armor_col, 'Armor')
gloves = root('Gloves', gloves_col, 'Gloves')
pants = root('Pants', pants_col, 'Pants')
boots = root('Boots', boots_col, 'Boots')
sword = root('Sword', sword_col, 'Sword')
wings = root('Wings', wings_col, 'Wings')

# Rounded mannequin under segmented armor; deliberate gaps at elbow/knee.
sphere('Torax_Base', (0, 0, 3.8), (0.87, 0.43, 0.88), dark, body_col, body)
sphere('Cintura_Base', (0, 0, 2.95), (0.63, 0.38, 0.48), dark, body_col, body)
sphere('Pescoco_Base', (0, 0, 4.55), (0.29, 0.29, 0.3), dark, body_col, body)
sphere('Cabeca_Base', (0, 0, 5.18), (0.58, 0.49, 0.66), dark, body_col, body)
for sign, side in [(-1, 'D'), (1, 'E')]:
    x = sign * 0.46
    sphere('Coxa_' + side, (x, 0, 2.35), (0.36, 0.35, 0.57), dark, body_col, body)
    sphere('Joelho_' + side, (x, -0.015, 1.8), (0.29, 0.28, 0.25), dark, body_col, body)
    sphere('Canela_' + side, (x, 0, 1.27), (0.28, 0.28, 0.47), dark, body_col, body)
    sphere('Braco_' + side, (sign*1.17, 0, 3.8), (0.32, 0.32, 0.54), dark, body_col, body)
    sphere('Cotovelo_' + side, (sign*1.34, 0, 3.35), (0.26, 0.26, 0.24), dark, body_col, body)
    sphere('Antebraco_' + side, (sign*1.45, -0.02, 3.06), (0.29, 0.28, 0.37), red, gloves_col, gloves)
    sphere('Luva_' + side, (sign*1.52, -0.02, 2.72), (0.28, 0.28, 0.29), red, gloves_col, gloves)
    for finger in range(3):
        sphere('Dedo_' + side, (sign*1.52+(finger-1)*0.14, -0.25, 2.66), (0.07, 0.10, 0.16), bright, gloves_col, gloves)
    # Overlapping thigh lames and large greaves.
    for i in range(3):
        z = 2.72-i*0.24
        inset('Coxa_Placa_'+side+str(i), [(x-.34,z+.11),(x+.34,z+.11),(x+.29,z-.12),(x,z-.27),(x-.29,z-.12)], -.36-i*.015, .13, red, pants_col, pants)
    inset('Joelheira_'+side, [(x,2.04),(x+.30,1.82),(x,1.55),(x-.30,1.82)], -.36, .20, bright, pants_col, pants)
    sphere('Bota_'+side, (x,-.17,.58), (.38,.61,.32), red, boots_col, boots)
    sphere('Sola_'+side, (x,-.18,.39), (.39,.60,.105), dark, boots_col, boots)
    inset('Greva_'+side, [(x-.29,1.59),(x,1.71),(x+.29,1.59),(x+.27,.75),(x,.57),(x-.27,.75)], -.33, .22, red, boots_col, boots)
    inset('Biqueira_'+side, [(x-.30,.73),(x,.88),(x+.30,.73),(x+.29,.48),(x-.29,.48)], -.71, .20, bright, boots_col, boots)
    inset('Bracal_'+side, [(sign*1.45-.25,3.33),(sign*1.45+.25,3.33),(sign*1.45+.23,2.95),(sign*1.45,2.79),(sign*1.45-.23,2.95)], -.29,.15,bright,gloves_col,gloves)
    tube('Espora_Bracal_'+side, [(sign*1.67,0,3.05),(sign*1.9,0,3.35),(sign*1.92,0,3.58)], [.15,.11,.012], red, gloves_col, gloves)

# Chest shell and original angular dragon crest.
sphere('Peitoral_Casco', (0,.025,3.91), (.94,.48,.73), red, armor_col, armor)
inset('Peitoral', [(-.75,4.37),(0,4.49),(.75,4.37),(.68,3.65),(0,3.42),(-.68,3.65)], -.46, .18, bright, armor_col, armor)
for sign in [-1,1]:
    plate('Insignia_Asa', [(sign*.09,4.09),(sign*.64,4.32),(sign*.46,3.99),(sign*.23,3.85),(sign*.13,3.62)], -.55,.07,gold,armor_col,armor)
inset('Insignia_Centro', [(0,4.26),(.19,4.02),(0,3.7),(-.19,4.02)], -.59,.08,glow,armor_col,armor,.53)
for i in range(3):
    z = 3.43-i*.20
    inset('Abdomen_'+str(i), [(-.55,z+.08),(.55,z+.08),(.50,z-.10),(0,z-.24),(-.50,z-.10)], -.41-i*.01,.14,red,armor_col,armor)
inset('Cinto', [(-.67,2.98),(.67,2.98),(.65,2.77),(-.65,2.77)], -.43,.13,dark,pants_col,pants)
inset('Fivela', [(0,3.06),(.20,2.88),(0,2.7),(-.20,2.88)], -.60,.12,glow,pants_col,pants,.6)

for sign, side in [(-1,'D'),(1,'E')]:
    sphere('Ombreira_Casco_'+side,(sign*1.02,.015,4.28),(.58,.48,.35),red,armor_col,armor)
    for i in range(3):
        x,z = sign*(1.03+i*.12),4.43-i*.18
        inset('Ombreira_Lamela_'+side+str(i), [(x-sign*.41,z),(x+sign*.47,z+.16),(x+sign*.36,z-.18),(x,z-.29),(x-sign*.37,z-.20)], -.38-i*.035,.30,bright if i==0 else red,armor_col,armor)
    for i in range(2):
        tube('Chifre_Ombro_'+side+str(i), [(sign*(1.15+i*.25),.12,4.43),(sign*(1.38+i*.28),.13,4.73),(sign*(1.48+i*.30),.13,5.02-i*.12)], [.19,.12,.008],red,armor_col,armor)

# Large enclosed helm, recessed dark visor, swept cheeks and curved horns.
sphere('Elmo_Casco', (0,.025,5.24), (.70,.57,.75), red, helmet_col, helmet)
inset('Viseira_Moldura', [(-.56,5.48),(0,5.36),(.56,5.48),(.48,4.99),(0,4.78),(-.48,4.99)], -.54,.19,black,helmet_col,helmet,.88)
for sign in [-1,1]:
    plate('Sobrancelha', [(sign*.02,5.46),(sign*.65,5.7),(sign*.51,5.39),(sign*.17,5.28)], -.63,.14,bright,helmet_col,helmet)
    plate('Olho_Ambar', [(sign*.15,5.25),(sign*.44,5.34),(sign*.39,5.26),(sign*.18,5.19)], -.59,.035,glow,helmet_col,helmet,.008)
    inset('Mandibula', [(sign*.53,5.20),(sign*.64,4.96),(sign*.24,4.66),(0,4.76),(sign*.32,4.98)], -.56,.20,red,helmet_col,helmet,.8)
    tube('Chifre_Elmo', [(sign*.50,.02,5.68),(sign*.78,.04,5.96),(sign*.94,.06,6.30),(sign*.98,.10,6.57)], [.23,.18,.085,.006],red,helmet_col,helmet)
    tube('Chifre_Elmo_Dourado', [(sign*.50,-.16,5.72),(sign*.76,-.10,5.99),(sign*.92,.01,6.30)], [.045,.035,.004],gold,helmet_col,helmet)
inset('Crista_Elmo', [(-.19,5.55),(0,6.30),(.19,5.55),(0,5.31)], -.49,.24,bright,helmet_col,helmet,.73)

if CRIAR_ESPADA:
    x = -1.52
    tube('Punho', [(x,-.30,2.35),(x,-.30,3.01)], [.10,.10],dark,sword_col,sword)
    for i in range(5):
        tube('Aro_Punho', [(x,-.30,2.43+i*.105),(x,-.30,2.46+i*.105)], [.114,.114],gold,sword_col,sword)
    sphere('Pomo',(x,-.30,3.08),(.16,.16,.19),gold,sword_col,sword)
    tube('Guarda',[(x-.46,-.30,2.24),(x-.27,-.30,2.36),(x,-.30,2.38),(x+.27,-.30,2.36),(x+.46,-.30,2.24)],[.07,.10,.13,.10,.07],gold,sword_col,sword)
    plate('Lamina',[(x-.18,2.28),(x+.18,2.28),(x+.21,.67),(x,.20),(x-.21,.67)],-.36,.12,steel,sword_col,sword,.016)
    plate('Lamina_Espinha',[(x,2.25),(x+.055,.70),(x,.29),(x-.055,.70)],-.385,.04,gold,sword_col,sword,.006)

if CRIAR_ASAS:
    # Each half is parented separately to make later hinge animation possible.
    for sign, side in [(-1,'D'),(1,'E')]:
        half = root('Asa_'+side,wings_col,'Wings')
        half.parent = wings
        def wp(x,y,z):
            return (sign*x,y,z)
        hinge=wp(.38,.43,4.10)
        elbow=wp(1.80,.68,5.66)
        tip=wp(3.65,.82,5.92)
        lower=[wp(3.18,.82,4.48),wp(2.42,.72,3.66),wp(1.42,.59,2.98),wp(.52,.47,3.30)]
        boundary=[hinge,wp(.96,.56,5.05),elbow,wp(2.72,.76,5.96),tip]
        # Concave scallops between the four tips, arched toward the upper elbow.
        last=Vector(tip)
        for endpoint in lower:
            end=Vector(endpoint)
            for j in range(1,9):
                t=j/8
                point=last.lerp(end,t)
                point.z+=math.sin(t*math.pi)*.28
                boundary.append(tuple(point))
            last=end
        # Fan from the high elbow: scalloped silhouette has no crossing edges.
        vertices=[elbow]+boundary
        faces=[(0,i+1,(i+1)%len(boundary)+1) for i in range(len(boundary)) if i not in (1,2)]
        wing=mesh('Membrana_'+side,vertices,faces,membrane,wings_col,half,True)
        solid=wing.modifiers.new('Espessura membrana','SOLIDIFY'); solid.thickness=.035
        tube('Bordo_Asa_'+side,boundary+[hinge],[.045]* (len(boundary)+1),red,wings_col,half,8)
        tube('Braco_Asa_'+side,[hinge,wp(.96,.56,5.05),elbow,wp(2.72,.76,5.96),tip],[.18,.16,.13,.085,.008],red,wings_col,half)
        for i,endpoint in enumerate(lower[:-1]):
            middle=Vector(elbow).lerp(Vector(endpoint),.5); middle.y-=.04
            tube('Nervura_'+side+str(i),[elbow,tuple(middle),endpoint],[.085,.055,.01],red,wings_col,half)
        tube('Garra_Asa_'+side,[elbow,wp(1.88,.68,6.03),wp(2.08,.67,6.20)],[.14,.085,.004],gold,wings_col,half)

# Presentation only: separate collection, not part of the game asset.
stone=material('Pedestal',(0.055,.075,.105,1),.3,.42)
floor_mat=material('Fundo',(0.018,.027,.042,1),.05,.65)
bpy.ops.mesh.primitive_cylinder_add(vertices=64,radius=2.23,depth=.24,location=(0,0,.13))
bevel(finish(bpy.context.object,'Pedestal',stone,stage_col),.065)
bpy.ops.mesh.primitive_torus_add(major_radius=2.11,minor_radius=.028,major_segments=64,minor_segments=8,location=(0,0,.258))
finish(bpy.context.object,'Aro_Pedestal',gold,stage_col)
bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.005))
finish(bpy.context.object,'Chao_Estudio',floor_mat,stage_col)

world=bpy.data.worlds.new('MUBlox_Estudio'); scene.world=world; world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.12,.16,.23,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.35
for name,loc,energy,color,size in [
    ('Luz_Principal',(3,-7,10),1400,(1,.80,.65),5),
    ('Luz_Preenchimento',(-5,-4,6),1100,(.55,.72,1),4),
    ('Luz_Recorte',(2,4,8),1800,(1,.24,.08),3),
]:
    data=bpy.data.lights.new(name,'AREA'); data.energy=energy; data.color=color; data.shape='DISK'; data.size=size
    obj=bpy.data.objects.new(name,data); stage_col.objects.link(obj); obj.location=loc; look_at(obj,(0,0,3))
data=bpy.data.cameras.new('Camera_Preview'); camera=bpy.data.objects.new('Camera_Preview',data)
stage_col.objects.link(camera); camera.location=(7,-18,9); look_at(camera,(0,0,3.3))
data.type='ORTHO'; data.ortho_scale=9.2; scene.camera=camera
scene.render.engine='CYCLES'; scene.cycles.samples=64
# Some Linux Blender packages lack OpenImageDenoise; keep rendering portable.
scene.cycles.use_denoising=False
scene.render.resolution_x=1200; scene.render.resolution_y=1200; scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG'
scene.view_settings.view_transform='AgX'

# Mirrored plates need consistent outward normals before future export.
for obj in scene.objects:
    if obj.type == 'MESH':
        bm = bmesh.new()
        bm.from_mesh(obj.data)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        bm.to_mesh(obj.data)
        bm.free()
        obj.data.update()

# Ready-to-inspect viewport, with visible material colors even in Solid mode.
bpy.ops.object.select_all(action='DESELECT')
bpy.context.view_layer.objects.active=helmet
helmet.select_set(True)
for screen in bpy.data.screens:
    for area in screen.areas:
        if area.type=='VIEW_3D':
            space=area.spaces.active
            space.shading.type='SOLID'; space.shading.color_type='MATERIAL'
            space.clip_end=300
            space.region_3d.view_distance=11
            space.region_3d.view_location=(0,0,3.3)
            space.region_3d.view_rotation=camera.rotation_euler.to_quaternion()

print('MUBlox: Guerreiro criado em uma NOVA CENA. Volte a Layout e salve como .blend.')
print('Colecoes 01–08: modelo. Colecao 09: apresentacao. Ainda sem rig/UV e sem exportacao automatica.')
