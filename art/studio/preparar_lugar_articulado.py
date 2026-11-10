"""Build an isolated test place from the user's saved XML, preserving mapped bones.
Usage: python art/studio/preparar_lugar_articulado.py /path/to/uploaded.rbxlx
No network access, asset uploads, or executable installer.
"""
from pathlib import Path
from copy import deepcopy
import sys
import xml.etree.ElementTree as E

repo=Path(__file__).resolve().parents[2]
source=E.parse(sys.argv[1]).getroot()
def name(item):
    return item.findtext("Properties/string[@name='Name']")
def props(item):
    return item.find('Properties')
def property(item,tag,key,value):
    p=props(item)
    old=next((x for x in p if x.get('name')==key),None)
    if old is not None: p.remove(old)
    E.SubElement(p,tag,{'name':key}).text=value
def service(root,kind):
    found=next((x for x in root.findall('Item') if x.get('class')==kind),None)
    if found is None:
        found=E.SubElement(root,'Item',{'class':kind,'referent':'RBXV5_'+kind})
        E.SubElement(found,'Properties')
        property(found,'string','Name',kind)
    return found
def script(parent,kind,title,path):
    item=next((i for i in parent.findall('Item') if name(i)==title),None)
    if item is None:
        item=E.SubElement(parent,'Item',{'class':kind,'referent':'RBXV5_'+title})
        E.SubElement(item,'Properties')
        property(item,'string','Name',title)
    property(item,'ProtectedString','Source',(repo/path).read_text())
    if kind!='ModuleScript': property(item,'bool','Disabled','false')
    return item
def shared_strings(root):
    keys={x.text for x in root.iter('SharedString') if x.text}
    strings=E.SubElement(root,'SharedStrings')
    for value in source.findall('SharedStrings/SharedString'):
        if value.get('md5') in keys: strings.append(deepcopy(value))
def write(root,path):
    E.indent(root)
    E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)

original=next(i for i in source.iter('Item') if i.get('class')=='Model' and name(i)=='MUBlox_Guerreiro_ArticuladoV2')
assert len([i for i in original.iter('Item') if i.get('class')=='Bone'])==15
template=deepcopy(original)
property(template,'string','Name','MUBloxWarriorSkinned')
# No scripts are copied into the asset. Mapping, texture IDs, skin and original scale remain intact.
for parent in template.iter('Item'):
    for child in list(parent.findall('Item')):
        if child.get('class') in {'Script','LocalScript','ModuleScript'}: parent.remove(child)
model=E.Element('roblox',{'version':'4'})
model.append(deepcopy(template)); shared_strings(model)
write(model,repo/'art/roblox/MUBloxWarriorSkinned.rbxmx')

# Preserve game services; omit Studio session state and device/account configuration.
keep={'Workspace','Players','ReplicatedStorage','ReplicatedFirst','ServerScriptService','ServerStorage',
      'StarterPlayer','StarterGui','StarterPack','Lighting','SoundService','Teams','TextChatService',
      'Chat','MaterialService','LocalizationService'}
place=E.Element('roblox',{'version':'4'})
for item in source.findall('Item'):
    if item.get('class') in keep: place.append(deepcopy(item))
workspace=service(place,'Workspace')
# Move the adjusted display model into storage, retaining the older template as fallback.
for item in list(workspace.findall('Item')):
    if name(item)=='MUBlox_Guerreiro_ArticuladoV2': workspace.remove(item)
storage=service(place,'ServerStorage')
for item in list(storage.findall('Item')):
    if name(item)=='MUBloxWarriorSkinned': storage.remove(item)
storage.append(template)
script(service(place,'ReplicatedStorage'),'ModuleScript','SkinnedWarrior',Path('src/shared/SkinnedWarrior.luau'))
script(service(place,'ServerScriptService'),'Script','MUBloxServerV2',Path('src/server/MUBlox.server.luau'))
starter=service(place,'StarterPlayer')
scripts=next(i for i in starter.findall('Item') if i.get('class')=='StarterPlayerScripts')
script(scripts,'LocalScript','MUBloxClientV2',Path('src/client/MUBlox.client.luau'))
shared_strings(place)
write(place,repo/'art/studio/MUBlox_Teste_Articulado_V5.rbxlx')
print('Prepared V5 test place and isolated mapped model; original upload unchanged.')
