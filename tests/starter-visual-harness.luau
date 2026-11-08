-- Minimal rigid vector/frame math to exercise the actual import validator.
local V={}
local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},V) end
V.__unm=function(a) return vec(-a.X,-a.Y,-a.Z) end
V.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V.__sub=function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
V.__mul=function(a,b) if type(b)=="number" then return vec(a.X*b,a.Y*b,a.Z*b) end return vec(a.X*b.X,a.Y*b.Y,a.Z*b.Z) end
V.__div=function(a,b) if type(b)=="number" then return a*(1/b) end return vec(a.X/b.X,a.Y/b.Y,a.Z/b.Z) end
V.__index=function(a,key)
 if key=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
 if key=="Unit" then return a/a.Magnitude end
 if key=="Dot" then return function(_,b) return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
 if key=="Cross" then return function(_,b) return vec(a.Y*b.Z-a.Z*b.Y,a.Z*b.X-a.X*b.Z,a.X*b.Y-a.Y*b.X) end end
end
local zero=vec(0,0,0)
local Vector3={new=vec,zero=zero}
local C={}
local function frame(p,x,y,z) return setmetatable({p=p,x=x or vec(1,0,0),y=y or vec(0,1,0),z=z or vec(0,0,1)},C) end
local function rotate(a,v) return a.x*v.X+a.y*v.Y+a.z*v.Z end
C.__mul=function(a,b) return frame(a.p+rotate(a,b.p),rotate(a,b.x),rotate(a,b.y),rotate(a,b.z)) end
C.__index=function(a,key)
 if key=="Rotation" then return frame(zero,a.x,a.y,a.z) end
 if key=="RightVector" then return a.x end
 if key=="UpVector" then return a.y end
 if key=="LookVector" then return a.z*-1 end
 if key=="Inverse" then return function()
  local inverse=frame(zero,vec(a.x.X,a.y.X,a.z.X),vec(a.x.Y,a.y.Y,a.z.Y),vec(a.x.Z,a.y.Z,a.z.Z))
  inverse.p=rotate(inverse,a.p*-1); return inverse
 end end
 if key=="PointToWorldSpace" then return function(_,v) return a.p+rotate(a,v) end end
 if key=="PointToObjectSpace" then return function(_,v) return rotate(a:Inverse().Rotation,v-a.p) end end
 if key=="ToObjectSpace" then return function(_,b) return a:Inverse()*b end end
end
local CFrame={new=function(p) return frame(p) end,fromMatrix=frame}
-- VALIDATOR_PLACEHOLDER
local function part(name,kind,pos,size)
 local obj={Name=name,Position=pos or zero,Size=size or vec(1,1,1),CFrame=frame(zero)}
 function obj:IsA(k) return k==kind or k=="BasePart" end
 return obj
end
local function fixture()
 local descendants={part("AxisOrigin","Part"),part("AxisUp","Part",vec(0,1,0)),part("AxisFront","Part",vec(0,0,-1))}
 local body={}
 for _,name in starterParts do
  table.insert(descendants,part("Visual_"..name,"MeshPart"))
  table.insert(descendants,part("Bind_"..name,"Part"))
  body[name]=part(name,"Part")
 end
 local template={IsA=function(_,k) return k=="Model" end,GetDescendants=function() return descendants end}
 local character={FindFirstChild=function(_,name) return body[name] end}
 return template,character,descendants,body
end
local template,char,desc,body=fixture()
assert(#validateStarterTemplate(template,char)==15)
assert(validateStarterTemplate(nil,char)==nil)
table.remove(desc,4); assert(validateStarterTemplate(template,char)==nil)
template,char,desc,body=fixture(); body.LeftHand=nil; assert(validateStarterTemplate(template,char)==nil)
template,char,desc=fixture(); table.insert(desc,desc[4]); assert(validateStarterTemplate(template,char)==nil)
template,char,desc=fixture(); desc[2].Position=zero; assert(validateStarterTemplate(template,char)==nil)
template,char,desc=fixture(); desc[3].Position=vec(0,1,-1); assert(validateStarterTemplate(template,char)==nil)
template,char,desc=fixture(); desc[4].CFrame=frame(zero,vec(.707,0,.707),vec(0,1,0),vec(-.707,0,.707)); assert(validateStarterTemplate(template,char)==nil)
local dims=dimensionsInFrame(vec(2,3,4),frame(zero,vec(0,1,0),vec(0,0,1),vec(1,0,0)))
assert(dims.X==4 and dims.Y==2 and dims.Z==3)
print("PASS starter template: valid R15, missing model/mesh/limb, duplicate names, degenerate/skew axes, rotated part and axis-swapped sizing")

-- V2 contract: all expected clothes are present, separately mapped to equipment slots.
local template2,char2,desc2=fixture()
table.insert(desc2,part("FormatV2","Part"))
for name,slots in starterWear do
 for _,slot in slots do table.insert(desc2,part("Wear_"..slot.."_"..name,"MeshPart")) end
end
local entries=validateStarterTemplate(template2,char2)
assert(entries and #entries==29)
local layers={}
for _,entry in entries do
 local attrs={HideSlot=entry.slot,BaseTransparency=0}
 local layer={Transparency=0,IsA=function(_,k) return k=="BasePart" end,GetAttribute=function(_,k) return attrs[k] end}
 table.insert(layers,layer)
end
local attrs={}
local p={GetAttribute=function(_,k) return attrs[k] end}
local visual={GetChildren=function() return layers end}
-- Equip each slot independently; wings must not hide any starter clothing.
for _,slot in {"Helmet","Armor","Gloves","Pants","Boots","Wings"} do
 attrs["Equipped"..slot]=true
 syncStarterVisibility(p,visual)
 for i,layer in layers do assert(layer.Transparency==(entries[i].slot==slot and 1 or 0)) end
 attrs["Equipped"..slot]=false
 syncStarterVisibility(p,visual)
 for _,layer in layers do assert(layer.Transparency==0) end
end
-- Full set hides every clothing layer, never the underlying body/face.
for _,slot in {"Helmet","Armor","Gloves","Pants","Boots"} do attrs["Equipped"..slot]=true end
syncStarterVisibility(p,visual)
for i,layer in layers do assert(layer.Transparency==(entries[i].slot and 1 or 0)) end
-- Imported translucency must be restored, not forced opaque.
local translucent={Transparency=1,IsA=function() return true end,GetAttribute=function(_,k) return k=="BaseTransparency" and .25 or nil end}
syncStarterVisibility(p,{GetChildren=function() return {translucent} end}); assert(translucent.Transparency==.25)
table.remove(desc2); assert(validateStarterTemplate(template2,char2)==nil)
print("PASS V2: required layers, per-slot equip/unequip, full set, wings independence and transparency restoration")

-- Exercise the real equipment bounds helper using offset/rotated visual meshes.
local starter
-- BOUNDS_PLACEHOLDER
local torso={Name="UpperTorso",Size=vec(2,2,1),CFrame=frame(zero)}
local size,offset=fitted(torso); assert(size==torso.Size and offset==zero)
local function visualPiece(name,size,cf)
 return {Size=size,CFrame=cf,Transparency=1,IsA=function() return true end,
  GetAttribute=function(_,key) return key=="BodyPart" and name or nil end}
end
local visibleParts={visualPiece("UpperTorso",vec(2,4,2),frame(vec(1,0,0))),visualPiece("UpperTorso",vec(2,2,2),frame(vec(-1,0,0))),visualPiece("Head",vec(20,20,20),frame(vec(100,0,0)))}
starter={GetAttribute=function() return true end,GetChildren=function() return visibleParts end}
size,offset=fitted(torso)
assert(size.X==4 and size.Y==4 and size.Z==2 and offset.Magnitude==0)
visibleParts[1].CFrame=frame(vec(1,0,0),vec(0,1,0),vec(-1,0,0),vec(0,0,1))
size,offset=fitted(torso)
assert(size.X==5 and size.Y==2 and size.Z==2 and offset.X==.5)
print("PASS equipment bounds: legacy fallback, offsets, rotations, hidden clothing and exclusion of other limbs")

-- V3 preserves hand proportions even when the R15 hand bounding box is very short.
local function limbWithJoints(size,joints)
 local body={Size=size,FindFirstChild=function(_,name)
  local point=joints[name]
  return point and {Position=point,IsA=function(_,k) return k=="Attachment" end} or nil
 end}
 return body
end
local refs={}
refs.LeftUpperArm={name="LeftUpperArm",v2=true,v3=true,bindSize=vec(.44,.75,.44),body=limbWithJoints(vec(2,.6,2),{LeftShoulderRigAttachment=vec(0,.3,0),LeftElbowRigAttachment=vec(0,-.28,0)})}
refs.LeftLowerArm={name="LeftLowerArm",v2=true,v3=true,bindSize=vec(.44,.38,.44),body=limbWithJoints(vec(2,.38,2),{LeftElbowRigAttachment=vec(0,.19,0),LeftWristRigAttachment=vec(0,-.19,0)})}
refs.LeftHand={name="LeftHand",v2=true,v3=true,bindSize=vec(.34,.52,.24),body=limbWithJoints(vec(2,.12,2),{LeftWristRigAttachment=vec(.02,.06,.01)})}
local scale,shift=starterScale(refs.LeftUpperArm,refs)
assert(math.abs(scale.Y-1)<.00001 and math.abs(scale.X-1)<.00001)
assert((vec(0,.205,0)*scale+shift-vec(0,.3,0)).Magnitude<.00001)
assert((vec(0,-.375,0)*scale+shift-vec(0,-.28,0)).Magnitude<.00001)
scale,shift=starterScale(refs.LeftHand,refs)
assert(math.abs(scale.X-scale.Y)<.00001 and math.abs(scale.Z-scale.Y)<.00001)
assert((vec(0,.26,0)*scale+shift-vec(.02,.06,.01)).Magnitude<.00001)
refs.LeftHand.body=limbWithJoints(vec(.3,.3,.3),{})
scale,shift=starterScale(refs.LeftHand,refs)
assert((vec(0,.26,0)*scale+shift-vec(0,.15,0)).Magnitude<.00001)
-- Wear meshes identify layered templates even if the optional format cube was omitted.
local t3,c3,d3=fixture()
for name,slots in starterWear do for _,slot in slots do table.insert(d3,part("Wear_"..slot.."_"..name,"MeshPart")) end end
assert(#validateStarterTemplate(t3,c3)==29)
table.insert(d3,part("FormatV3","Part")); local e3=validateStarterTemplate(t3,c3)
assert(e3[1].v3 and e3[1].v2)
print("PASS V3: joint-based arm length, uniform hands, wrist alignment, attachment fallback and layered detection")
