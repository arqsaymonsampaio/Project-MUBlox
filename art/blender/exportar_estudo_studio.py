"""Export the elbow study as a static, colored display model (not an R15 skin)."""
from pathlib import Path
import bpy
from mathutils import Vector

folder = Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(folder / 'MUBlox_Estudo_Referencia.blend'))
scene = bpy.data.scenes['MUBlox_Estudo_Referencia']
bpy.context.window.scene = scene
out = folder.parent / 'roblox' / 'estudo'
out.mkdir(parents=True, exist_ok=True)
sources = [o for o in scene.objects if o.parent and o.type in {'MESH', 'CURVE'}
           and o.parent.get('equipment_slot')]
materials = list(dict.fromkeys(m for o in sources for m in o.data.materials))
assert 0 < len(materials) <= 16
def srgb(value):
    return 12.92 * value if value <= .0031308 else 1.055 * value ** (1 / 2.4) - .055
colors = [tuple(srgb(c) for c in m.diffuse_color[:3]) + (1,) for m in materials]
atlas = bpy.data.images.new('Estudo_Cores', width=128, height=128, alpha=True)
atlas.pixels = [c for y in range(128) for x in range(128)
                for c in colors[min((y // 32) * 4 + x // 32, len(colors) - 1)]]
atlas.filepath_raw = str(out / 'Estudo_Cores.png')
atlas.file_format = 'PNG'
atlas.save()
material = bpy.data.materials.new('Estudo_Atlas')
material.use_nodes = True
node = material.node_tree.nodes.new('ShaderNodeTexImage')
node.image = atlas
shader = material.node_tree.nodes.get('Principled BSDF')
material.node_tree.links.new(node.outputs['Color'], shader.inputs['Base Color'])
shader.inputs['Roughness'].default_value = .65
deps = bpy.context.evaluated_depsgraph_get()
groups = {}
for source in sources:
    verts, faces, palette = groups.setdefault(source.parent['equipment_slot'], ([], [], []))
    evaluated = source.evaluated_get(deps)
    mesh = evaluated.to_mesh()
    offset = len(verts)
    verts.extend(tuple(source.matrix_world @ v.co) for v in mesh.vertices)
    for face in mesh.polygons:
        faces.append(tuple(offset + i for i in face.vertices))
        palette.append(materials.index(source.data.materials[face.material_index]))
    evaluated.to_mesh_clear()
assert set(groups) == {'Body', 'Face', 'Hair', 'StarterShirt', 'StarterGloves', 'StarterBoots', 'StarterPants'}, set(groups)
all_vertices = [p for verts, _, _ in groups.values() for p in verts]
bottom = min(p[2] for p in all_vertices)
height = max(p[2] for p in all_vertices) - bottom
factor = 5.5 / height
export = bpy.data.collections.new('Estudo_Exportacao_Estatica')
scene.collection.children.link(export)
objects = []
for slot, (verts, faces, palette) in groups.items():
    mesh = bpy.data.meshes.new('Estudo_' + slot)
    mesh.from_pydata([(x * factor, y * factor, (z - bottom) * factor) for x, y, z in verts], [], faces)
    mesh.update()
    mesh.materials.append(material)
    uv = mesh.uv_layers.new(name='UVMap')
    for face, index in zip(mesh.polygons, palette):
        face.use_smooth = True
        for loop in face.loop_indices:
            uv.data[loop].uv = ((index % 4 + .5) / 4, (index // 4 + .5) / 4)
    obj = bpy.data.objects.new(mesh.name, mesh)
    export.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    mesh.calc_loop_triangles()
    if len(mesh.loop_triangles) > 9000:
        modifier = obj.modifiers.new('Limite_Importacao', 'DECIMATE')
        modifier.ratio = 8500 / len(mesh.loop_triangles)
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    modifier = obj.modifiers.new('Triangulos', 'TRIANGULATE')
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    assert len(obj.data.polygons) <= 10000, (slot, len(obj.data.polygons))
    objects.append(obj)
scene.unit_settings.system = 'METRIC'
scene.unit_settings.scale_length = .28
bpy.ops.object.select_all(action='DESELECT')
for obj in objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = objects[0]
bpy.ops.export_scene.fbx(filepath=str(out / 'MUBlox_Estudo_Mapa.fbx'), use_selection=True,
    object_types={'MESH'}, axis_forward='-Z', axis_up='Y', path_mode='COPY',
    embed_textures=True, bake_anim=False, add_leaf_bones=False)
print('PASS static export: seven colored meshes; 5.5-unit height; no scenery or rig.')
