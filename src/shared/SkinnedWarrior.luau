-- V5: cosmetic skin driven by the existing R15 character, including flight/combat poses.
local Skin = {}
Skin.Names = {"LowerTorso","UpperTorso","Head","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
local layerSlots = {Skin_Hair="Helmet",Skin_StarterShirt="Armor",Skin_StarterGloves="Gloves",Skin_StarterPants="Pants",Skin_StarterBoots="Boots"}
local meshNames = {"Skin_Body","Skin_Face","Skin_Hair","Skin_StarterShirt","Skin_StarterGloves","Skin_StarterPants","Skin_StarterBoots"}
local nextBone = {LowerTorso="UpperTorso",UpperTorso="Head",LeftUpperArm="LeftLowerArm",LeftLowerArm="LeftHand",RightUpperArm="RightLowerArm",RightLowerArm="RightHand",LeftUpperLeg="LeftLowerLeg",LeftLowerLeg="LeftFoot",RightUpperLeg="RightLowerLeg",RightLowerLeg="RightFoot"}

function Skin.validate(template, character)
 if not template or not template:IsA("Model") then return nil,"modelo articulado ausente" end
 local root=template:FindFirstChild("RootPart")
 if not root or not root:IsA("BasePart") then return nil,"RootPart ausente" end
 local bones={}
 for _, obj in template:GetDescendants() do
  if obj:IsA("Bone") then
   if bones[obj.Name] then return nil,"osso duplicado: "..obj.Name end
   bones[obj.Name]=obj
  end
 end
 for _, name in Skin.Names do
  if not bones[name] or not bones[name]:IsDescendantOf(root) then return nil,"osso ausente: "..name end
  local body=character:FindFirstChild(name)
  if not body or not body:IsA("BasePart") then return nil,"requer R15: "..name end
 end
 for _, name in meshNames do
  local mesh=template:FindFirstChild(name)
  if not mesh or not mesh:IsA("MeshPart") then return nil,"malha ausente: "..name end
 end
 return bones
end

-- Solve neutral R15 frames from joint attachments, never from an animated snapshot.
function Skin.driverRest(character)
 local root=character:FindFirstChild("HumanoidRootPart")
 if not root then return nil end
 local frames={[root]=CFrame.identity}
 local joints={}
 for _, joint in character:GetDescendants() do
  local a,b,c0,c1
  if joint:IsA("Motor6D") then
   a,b,c0,c1=joint.Part0,joint.Part1,joint.C0,joint.C1
  elseif joint:IsA("AnimationConstraint") and joint.Attachment0 and joint.Attachment1 then
   a,b=joint.Attachment0.Parent,joint.Attachment1.Parent
   c0,c1=joint.Attachment0.CFrame,joint.Attachment1.CFrame
  end
  if a and b and a.Parent==character and b.Parent==character then
   table.insert(joints,{a,b,c0,c1})
  end
 end
 for _=1,16 do
  for _, j in joints do
   if frames[j[1]] and not frames[j[2]] then frames[j[2]]=frames[j[1]]*j[3]*j[4]:Inverse() end
   if frames[j[2]] and not frames[j[1]] then frames[j[1]]=frames[j[2]]*j[4]*j[3]:Inverse() end
  end
 end
 local result={}
 for _, name in Skin.Names do
  local value=frames[character:FindFirstChild(name)]
  if not value then return nil end
  result[name]=value
 end
 return result
end

-- Rotation-only retarget preserves the new body's proportions and joint lengths.
function Skin.pose(restBone, driverRest, driverFrame, parentFrame, localRest, rootDelta)
 local rotation=driverFrame.Rotation*driverRest.Rotation:Inverse()*restBone.Rotation
 local position=parentFrame:PointToWorldSpace(localRest.Position)
 if rootDelta then position+=rootDelta end
 local world=CFrame.new(position)*rotation
 return localRest:Inverse()*parentFrame:ToObjectSpace(world),world
end

local function proxyFrame(name,bones,root)
 local bone=bones[name]
 local a=root.CFrame:ToObjectSpace(bone.WorldCFrame)
 local child=nextBone[name] and bones[nextBone[name]]
 local scale=root.Parent:GetAttribute("BodyScale") or 1
 local up,center,size
 if child then
  local b=root.CFrame:PointToObjectSpace(child.WorldCFrame.Position)
  local direction=b-a.Position
  up=direction.Unit
  if string.find(name,"Arm") or string.find(name,"Leg") then up=-up end
  center=(a.Position+b)*.5
  local width=string.find(name,"Arm") and .44 or string.find(name,"Leg") and .55 or name=="UpperTorso" and 1.15 or .95
  local depth=string.find(name,"Torso") and .68 or width
  size=Vector3.new(width*scale,direction.Magnitude+.12*scale,depth*scale)
 elseif name=="Head" then
  up=Vector3.yAxis; size=Vector3.new(2.1,1.95,1.65)*scale
  center=a.Position+Vector3.new(0,size.Y*.48,0)
 elseif string.find(name,"Hand") then
  up=-(a.UpVector); size=Vector3.new(.36,.48,.25)*scale
  center=a.Position-up*size.Y*.45
 else
  up=Vector3.yAxis; size=Vector3.new(.62,.48,.94)*scale
  center=a.Position+Vector3.new(0,-.20,-.14)*scale
 end
 local right=up:Cross(Vector3.zAxis)
 if right.Magnitude<.001 then right=Vector3.xAxis end
 right=right.Unit
 return CFrame.fromMatrix(center,right,up,right:Cross(up)),size
end

function Skin.mount(template,character)
 local valid,reason=Skin.validate(template,character)
 if not valid then return nil,reason end
 local rest=Skin.driverRest(character)
 local hrp=character:FindFirstChild("HumanoidRootPart")
 local humanoid=character:FindFirstChildOfClass("Humanoid")
 if not rest or not hrp or not humanoid then return nil,"articulacoes R15 ainda indisponiveis" end
 local visual=template:Clone()
 visual.Name="MUBloxStarterVisual"
 visual:SetAttribute("SkinnedV5",true)
 visual:SetAttribute("FormatV2",true)
 visual:SetAttribute("VisualRevision",5)
 visual:SetAttribute("BodyScale",1) -- uploaded model already has the approved scale
 for _, obj in visual:GetDescendants() do
  if obj:IsA("LuaSourceContainer") or obj:IsA("AnimationController") or obj:IsA("Animator") or obj:IsA("HumanoidRigDescription") then obj:Destroy() end
 end
 local root=visual:FindFirstChild("RootPart")
 visual.PrimaryPart=root
 local baseHip=humanoid:GetAttribute("MUBloxBaseHip") or humanoid.HipHeight
 visual:PivotTo(hrp.CFrame*CFrame.new(0,-baseHip-hrp.Size.Y*.5,0))
 local bones={}
 for _, obj in visual:GetDescendants() do
  if obj:IsA("Bone") then obj.Transform=CFrame.identity; bones[obj.Name]=obj end
  if obj:IsA("BasePart") then
   obj.Anchored=false; obj.Massless=true; obj.CanCollide=false; obj.CanTouch=false; obj.CanQuery=false
   if obj==root then obj.Transparency=1 end
   obj:SetAttribute("HideSlot",layerSlots[obj.Name])
   obj:SetAttribute("BaseTransparency",obj.Transparency)
  end
 end
 local anchors=Instance.new("Folder"); anchors.Name="PoseAnchors"; anchors.Parent=visual
 for _, name in Skin.Names do
  local bone=bones[name]
  bone:SetAttribute("DriverRest",rest[name])
  bone:SetAttribute("SkinRest",root.CFrame:ToObjectSpace(bone.WorldCFrame))
  local cf,size=proxyFrame(name,bones,root)
  local anchor=Instance.new("Part"); anchor.Name=name; anchor.Size=size; anchor.Transparency=1
  anchor.Anchored=false; anchor.Massless=true; anchor.CanCollide=false; anchor.CanTouch=false; anchor.CanQuery=false
  anchor.CFrame=root.CFrame*cf; anchor.Parent=anchors
  anchor:SetAttribute("BoneOffset",bone.WorldCFrame:ToObjectSpace(anchor.CFrame))
  local joint=Instance.new("Motor6D"); joint.Name="SkinAnchor"; joint.Part0=root; joint.Part1=anchor; joint.C0=cf; joint.Parent=anchor
 end
 local weld=Instance.new("WeldConstraint"); weld.Part0=hrp; weld.Part1=root; weld.Parent=root
 visual.Parent=character
 return visual
end

function Skin.body(character,name)
 local visual=character:FindFirstChild("MUBloxStarterVisual")
 local anchors=visual and visual:GetAttribute("SkinnedV5") and visual:FindFirstChild("PoseAnchors")
 return anchors and anchors:FindFirstChild(name) or character:FindFirstChild(name)
end

function Skin.grip(character)
 local visual=character:FindFirstChild("MUBloxStarterVisual")
 if not visual or not visual:GetAttribute("SkinnedV5") then return end
 local tool=character:FindFirstChild("MUBloxWeapon")
 local handle=tool and tool:FindFirstChild("Handle")
 local hand=Skin.body(character,"RightHand")
 if not handle or not hand then return end
 for _, joint in character:GetDescendants() do
  if joint:IsA("Motor6D") and joint.Name=="RightGrip" and joint.Part1==handle then
   if joint.Part0~=hand then
    joint.Part0=hand
    joint.C0=CFrame.new(0,-hand.Size.Y*.25,0)*joint.C0.Rotation
   end
   return
  end
 end
end

function Skin.clientState(character,visual)
 local root=visual:FindFirstChild("RootPart")
 local hrp=character:FindFirstChild("HumanoidRootPart")
 local anchors=visual:FindFirstChild("PoseAnchors")
 if not root or not hrp or not anchors then return nil end
 local bones={}
 for _, obj in root:GetDescendants() do if obj:IsA("Bone") then bones[obj.Name]=obj end end
 local records={}
 for _, name in Skin.Names do
  local bone=bones[name]
  local body=character:FindFirstChild(name)
  local anchor=anchors:FindFirstChild(name)
  local driver=bone and bone:GetAttribute("DriverRest")
  local bind=bone and bone:GetAttribute("SkinRest")
  if not bone or not body or not anchor or not driver or not bind then return nil end
  local motor=anchor:FindFirstChild("SkinAnchor")
  local offset=anchor:GetAttribute("BoneOffset")
  if not motor or not offset then return nil end
  table.insert(records,{bone=bone,body=body,driver=driver,bind=bind,anchor=anchor,motor=motor,offset=offset})
 end
 return {visual=visual,root=root,hrp=hrp,records=records}
end

function Skin.update(state)
 local worlds={}
 for _, record in state.records do
  local bone=record.bone
  if not bone.Parent or not record.body.Parent then return end
  local parent=worlds[bone.Parent] or state.root.CFrame
  local delta
  if bone.Parent==state.root then
   delta=record.body.Position-state.hrp.CFrame:PointToWorldSpace(record.driver.Position)
  end
  local pose,world=Skin.pose(record.bind,record.driver,record.body.CFrame,parent,bone.CFrame,delta)
  bone.Transform=pose
  worlds[bone]=world
  record.motor.C0=state.root.CFrame:ToObjectSpace(world*record.offset)
 end
end
return Skin
