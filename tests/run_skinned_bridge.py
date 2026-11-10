"""Execute real retargeting code with CFrame doubles and the saved mapped skeleton."""
from pathlib import Path
import subprocess
import tempfile
import sys
import xml.etree.ElementTree as E
root=Path(__file__).resolve().parents[1]
source=(root/'src/shared/SkinnedWarrior.luau').read_text()
prelude=(root/'tests/starter-visual-harness.luau').read_text().split('-- VALIDATOR_PLACEHOLDER')[0]
prelude=prelude.replace('if key=="Rotation"', 'if key=="Position" then return a.p end\n if key=="Rotation"')
prelude+='''
Vector3.xAxis=vec(1,0,0); Vector3.yAxis=vec(0,1,0); Vector3.zAxis=vec(0,0,1)
local oldNew=CFrame.new
CFrame.new=function(a,b,c) return type(a)=="number" and frame(vec(a,b or 0,c or 0)) or oldNew(a) end
local function rx(a) return frame(zero,vec(1,0,0),vec(0,math.cos(a),math.sin(a)),vec(0,-math.sin(a),math.cos(a))) end
local function ry(a) return frame(zero,vec(math.cos(a),0,-math.sin(a)),vec(0,1,0),vec(math.sin(a),0,math.cos(a))) end
local function near(a,b) return (a-b).Magnitude<.0001 end
local function same(a,b)
 return near(a.Position,b.Position) and near(a.RightVector,b.RightVector) and near(a.UpVector,b.UpVector)
end
'''
asset=E.parse(root/'art/roblox/MUBloxWarriorSkinned.rbxmx').getroot()
bone_lines=[]
def walk(item,parent=None):
    if item.get('class')=='Bone':
        name=item.findtext("Properties/string[@name='Name']")
        cf=item.find("Properties/CoordinateFrame[@name='CFrame']")
        values={p.tag:float(p.text) for p in cf}
        v=lambda fields: 'vec('+','.join(str(values[k]) for k in fields)+')'
        mat='frame('+','.join(v(f) for f in [('X','Y','Z'),('R00','R10','R20'),('R01','R11','R21'),('R02','R12','R22')])+')'
        bone_lines.append(f'bones["{name}"]={{name="{name}",parent={repr(parent) if parent else "nil"},localRest={mat}}}')
        parent=name
    for child in item.findall('Item'): walk(child,parent)
for item in asset.findall('Item'):walk(item)
test='''
local Skin=(function()
MODULE
end)()
local bones={}
BONES
for _,name in Skin.Names do
 local b=bones[name]
 b.bind=(b.parent and bones[b.parent].bind or CFrame.identity)*b.localRest
 -- Deliberately non-identity package orientation, to catch rotated R15 limbs.
 b.driver=CFrame.new(vec(0,1,0))*ry(.2)*rx(.1)
end
local function exercise(spin,flex)
 local worldRoot=CFrame.new(vec(12,3,-7))*ry(spin)
 local worlds={}
 for _,name in Skin.Names do
  local b=bones[name]
  local change=(name=="LeftLowerArm" or name=="LeftHand") and rx(flex) or CFrame.identity
  local driver=worldRoot*change*b.driver
  local parent=b.parent and worlds[b.parent] or worldRoot
  local transform,world=Skin.pose(b.bind,b.driver,driver,parent,b.localRest)
  assert(same(parent*b.localRest*transform,world),name..": reconstructed pose")
  if flex==0 then
   assert(same(transform,CFrame.identity),name..": rest must not deform")
   assert(same(world,worldRoot*b.bind),name..": root rotation must carry entire skeleton")
  end
  if b.parent then
   local length=(world.Position-worlds[b.parent].Position).Magnitude
   assert(math.abs(length-b.localRest.Position.Magnitude)<.0001,name..": joint length changed")
  end
  worlds[name]=world
 end
 return worlds
end
local neutral=exercise(0,0)
local bent=exercise(0,math.rad(70))
assert(near(neutral.LeftLowerArm.Position,bent.LeftLowerArm.Position),"elbow pivot moved")
assert((neutral.LeftHand.Position-bent.LeftHand.Position).Magnitude>.2,"hand must follow bent elbow")
assert(same(neutral.Head,bent.Head),"elbow must not move head")
assert(same(neutral.RightHand,bent.RightHand),"elbow must not move other hand")
exercise(math.rad(123),0); exercise(math.rad(-65),math.rad(50))
local b=bones.LowerTorso
local bob=vec(0,.16,0)
local _,world=Skin.pose(b.bind,b.driver,b.driver,CFrame.identity,b.localRest,bob)
assert(near(world.Position,b.bind.Position+bob),"flight bob")
print("PASS V5 retarget: uploaded 15-bone rest, elbow/hand, root turn/spin, invariant joint lengths, independent head/other arm and flight bob")

local descendants={}
local bodies={}
local function object(kind,name)
 local obj={Name=name}
 function obj:IsA(k) return k==kind or k=="BasePart" and (kind=="MeshPart" or kind=="Part") end
 function obj:IsDescendantOf(parent) return parent==bodies.RootPart end
 return obj
end
bodies.RootPart=object("Part","RootPart")
local template={IsA=function(_,k) return k=="Model" end,FindFirstChild=function(_,n) return bodies[n] end,GetDescendants=function() return descendants end}
local character={FindFirstChild=function(_,n) return bodies[n] end}
for _,name in Skin.Names do
 bodies[name]=object("Part",name)
 table.insert(descendants,object("Bone",name))
end
for _,name in {"Body","Face","Hair","StarterShirt","StarterGloves","StarterPants","StarterBoots"} do bodies["Skin_"..name]=object("MeshPart","Skin_"..name) end
assert(Skin.validate(template,character))
local missing=table.remove(descendants); assert(not Skin.validate(template,character)); table.insert(descendants,missing)
table.insert(descendants,descendants[1]); assert(not Skin.validate(template,character)); table.remove(descendants)
local head=bodies.Head; bodies.Head=nil; assert(not Skin.validate(template,character)); bodies.Head=head
local shirt=bodies.Skin_StarterShirt; bodies.Skin_StarterShirt=nil; assert(not Skin.validate(template,character)); bodies.Skin_StarterShirt=shirt
assert(not Skin.validate(nil,character))
print("PASS V5 validation: rejects missing/duplicate bones, incomplete mesh, non-R15 and missing asset")

-- Neutral driver solve must use joints, including upgraded AnimationConstraints,
-- and not depend on the character's animated world-space snapshot.
local driver={}
local links={}
local avatar={GetDescendants=function() return links end,FindFirstChild=function(_,n) return driver[n] end}
driver.HumanoidRootPart={Parent=avatar}
for index,name in Skin.Names do
 driver[name]={Parent=avatar}
 local parent=index==1 and driver.HumanoidRootPart or driver[Skin.Names[index-1]]
 local c0=CFrame.new(vec(.1,.2,.3))*ry(.15)
 local c1=rx(.1)
 local constraint=index%2==0
 local joint={Part0=parent,Part1=driver[name],C0=c0,C1=c1,
  Attachment0={Parent=parent,CFrame=c0},Attachment1={Parent=driver[name],CFrame=c1}}
 function joint:IsA(kind) return kind==(constraint and "AnimationConstraint" or "Motor6D") end
 table.insert(links,joint)
end
local solved=Skin.driverRest(avatar)
assert(solved)
local expected=CFrame.identity
for _,name in Skin.Names do
 expected=expected*CFrame.new(vec(.1,.2,.3))*ry(.15)*rx(.1):Inverse()
 assert(same(solved[name],expected),"joint solve: "..name)
end
table.remove(links)
assert(not Skin.driverRest(avatar),"incomplete driver must fail instead of inventing a bind pose")
print("PASS V5 driver: neutral frames across Motor6D/AnimationConstraint and incomplete skeleton rejection")
'''.replace('MODULE',source).replace('BONES','\n'.join(bone_lines))
with tempfile.TemporaryDirectory() as temp:
    file=Path(temp)/'skinned.luau';file.write_text(prelude+test)
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',str(file)],check=True)
