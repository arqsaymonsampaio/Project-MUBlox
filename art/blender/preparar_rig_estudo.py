"""Build a skinned test character and an elbow/knee animation from the study.
Separate asset: does not replace the working game's rigid R15 cosmetics.
"""
from pathlib import Path
import math
import runpy
import bpy
from mathutils import Vector, Quaternion

folder = Path(__file__).resolve().parent
ns = runpy.run_path(str(folder / 'exportar_estudo_studio.py'), init_globals={'EXPORT_STATIC': False})
scene = bpy.context.scene
scene.name = 'MUBlox_Teste_Deformacao'
scene['stage'] = 'Rig experimental com pesos e demonstracao; integracao jogavel pendente'
objects, factor, bottom = ns['objects'], ns['factor'], ns['bottom']
out = folder.parent / 'roblox' / 'articulado'
out.mkdir(parents=True, exist_ok=True)
ns['atlas'].filepath_raw = str(out / 'Articulado_Cores.png')
ns['atlas'].save()

def study(x, y, z):
    return Vector((x, y, .2 + (z - .2) * .9 if z < 1.65 else z - .145))

def export_point(point):
    return Vector((point.x * factor, point.y * factor, (point.z - bottom) * factor))

# Bone endpoints are the same landmarks used to build the anatomical surfaces.
spec = {
    'LowerTorso': (study(0, 0, 1.84), study(0, 0, 2.20), None),
    'UpperTorso': (study(0, 0, 2.20), study(0, 0, 3.00), 'LowerTorso'),
    'Head': (study(0, 0, 3.00), study(0, 0, 4.20), 'UpperTorso'),
}
for side, sign in [('Left', 1), ('Right', -1)]:
    shoulder, elbow, wrist = study(sign*.56, 0, 2.85), study(sign*.96, .075, 2.42), study(sign*1.15, -.16, 1.94)
    hip, knee, ankle = study(sign*.29, 0, 1.84), study(sign*.30, 0, 1.26), study(sign*.32, 0, .66)
    spec.update({
        side+'UpperArm': (shoulder, elbow, 'UpperTorso'),
        side+'LowerArm': (elbow, wrist, side+'UpperArm'),
        side+'Hand': (wrist, study(sign*1.15, -.18, 1.53), side+'LowerArm'),
        side+'UpperLeg': (hip, knee, 'LowerTorso'),
        side+'LowerLeg': (knee, ankle, side+'UpperLeg'),
        side+'Foot': (ankle, study(sign*.32, -.36, .35), side+'LowerLeg'),
    })
armature = bpy.data.armatures.new('MUBlox_Skeleton')
rig = bpy.data.objects.new('MUBloxRig', armature)
scene.collection.objects.link(rig)
rig.show_in_front = True
armature.display_type = 'OCTAHEDRAL'
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode='EDIT')
for name, (head, tail, parent) in spec.items():
    bone = armature.edit_bones.new(name)
    bone.head, bone.tail = export_point(head), export_point(tail)
    if parent:
        bone.parent = armature.edit_bones[parent]
        bone.use_connect = (bone.head - bone.parent.tail).length < .00001
bpy.ops.object.mode_set(mode='OBJECT')

def distance_sq(point, head, tail):
    axis = tail - head
    t = max(0, min(1, (point - head).dot(axis) / axis.length_squared))
    return (point - head - axis * t).length_squared

def weights(slot, point):
    side = 'Left' if point.x >= 0 else 'Right'
    if slot in {'Face', 'Hair'} or slot == 'Body' and point.z > 3.02:
        return {'Head': 1}
    if slot == 'StarterGloves':
        return {side+'Hand': 1}
    if slot == 'StarterShirt':
        # The hem follows the thighs gradually; otherwise a raised leg pierces it.
        amount = max(0, min(.85, (1.98 - point.z) / .40))
        if amount > 0:
            left = max(0, min(1, .5 + point.x / .55))
            return {name: value for name, value in {
                'LowerTorso': 1-amount, 'LeftUpperLeg': amount*left,
                'RightUpperLeg': amount*(1-left)}.items() if value > .0001}
        candidates = ['LowerTorso', 'UpperTorso']
    elif slot == 'StarterBoots':
        candidates = [side+'LowerLeg', side+'Foot']
    elif slot == 'StarterPants':
        candidates = ['LowerTorso', side+'UpperLeg', side+'LowerLeg']
    elif point.z < 1.60 and abs(point.x) < .7:
        candidates = ['LowerTorso', side+'UpperLeg', side+'LowerLeg', side+'Foot']
    else:
        candidates = ['LowerTorso', 'UpperTorso', 'Head', side+'UpperArm', side+'LowerArm', side+'Hand']
    distances = sorted((distance_sq(point, *spec[name][:2]), name) for name in candidates)
    nearest = distances[0][0]
    # Smooth compact blends around the shared joints; at most four influences.
    raw = {name: math.exp(-(distance - nearest) / .009) for distance, name in distances[:4]}
    raw = {name: value for name, value in raw.items() if value >= .015}
    total = sum(raw.values())
    return {name: value / total for name, value in raw.items()}

for obj in objects:
    slot = obj.name.removeprefix('Estudo_')
    obj.name = 'Skin_' + slot
    groups = {name: obj.vertex_groups.new(name=name) for name in spec}
    for vertex in obj.data.vertices:
        point = vertex.co / factor + Vector((0, 0, bottom))
        for name, weight in weights(slot, point).items():
            groups[name].add([vertex.index], weight, 'REPLACE')
    obj.parent = rig
    modifier = obj.modifiers.new('Deformacao_Esqueleto', 'ARMATURE')
    modifier.object = rig
    # Linear skinning matches the deformation expected from the FBX in Studio.
    modifier.use_deform_preserve_volume = False

# Hide the original static source and keep its lighting/camera for inspection.
for source in ns['sources']:
    source.hide_render = True
    source.hide_set(True)
for obj in scene.objects:
    if obj.type in {'CAMERA', 'LIGHT'}:
        obj.location = export_point(obj.location)
    elif obj.parent is None and obj.type == 'MESH' and obj not in objects:
        obj.location = export_point(obj.location)
        obj.scale *= factor
scene.camera.data.ortho_scale *= factor
target = export_point(Vector((0, 0, 2.50)))
scene.camera.rotation_euler = (target - scene.camera.location).to_track_quat('-Z','Y').to_euler()
scene.frame_start, scene.frame_end = 1, 81
scene.render.fps = 30
for frame, strength in [(1, 0), (21, 1), (41, 0), (61, 1), (81, 0)]:
    for name in spec:
        bone = rig.pose.bones[name]
        angle = 0
        if name.endswith('LowerArm'):
            angle = math.radians(-70) * strength
        elif name == 'LeftLowerLeg':
            angle = math.radians(65) * strength
        elif name == 'LeftUpperLeg':
            angle = math.radians(-25) * strength
        axis = armature.bones[name].matrix_local.to_3x3().inverted() @ Vector((1,0,0))
        bone.rotation_mode = 'QUATERNION'
        bone.rotation_quaternion = Quaternion(axis, angle)
        bone.keyframe_insert(data_path='rotation_quaternion', frame=frame)
rig.animation_data.action.name = 'Teste_Cotovelos_Joelho'
scene.frame_set(1)
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=str(folder / 'MUBlox_Guerreiro_Articulado.blend'))
bpy.ops.object.select_all(action='DESELECT')
rig.select_set(True)
for obj in objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = rig
# Export skin in rest pose. The separate demo is embedded only in the .blend;
# Studio can exercise the imported Bones using the provided test Script.
bpy.ops.export_scene.fbx(filepath=str(out / 'MUBlox_Guerreiro_Articulado.fbx'),
    use_selection=True, object_types={'MESH', 'ARMATURE'}, axis_forward='-Z', axis_up='Y',
    path_mode='COPY', embed_textures=True, add_leaf_bones=False, bake_anim=False,
    use_armature_deform_only=True, use_mesh_modifiers=False)
scene.frame_set(21)
scene.render.filepath = str(folder.parent / 'previews' / 'guerreiro_articulado_teste.png')
bpy.ops.render.render(write_still=True)
print('PASS rig generated: 15 bones, 7 skinned meshes, elbow/knee action and rest-pose FBX.')
