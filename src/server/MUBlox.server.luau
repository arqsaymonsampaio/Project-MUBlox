-- MUBLOX_VISUAL_V5: guerreiro articulado com controle R15 e encaixes nos ossos.
local Players = game:GetService("Players")
local R = game:GetService("ReplicatedStorage"):WaitForChild("MUBloxAction")
local SkinnedWarrior = require(game:GetService("ReplicatedStorage"):WaitForChild("SkinnedWarrior"))
local classes = {Guerreiro={150,60,Color3.fromRGB(165,40,28)}, Mago={90,150,Color3.fromRGB(35,65,150)}, Elfa={110,100,Color3.fromRGB(45,135,85)}}
local slots = {"Helmet","Armor","Gloves","Pants","Boots","Sword","Wings"}
local allowed = {}; for _, slot in slots do allowed[slot]=true end
local gold = Color3.fromRGB(220,175,70)
local function part(parent,name,size,cf,color,material)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf
 p.Color=color; p.Material=material or Enum.Material.Slate; p.Anchored=true
 p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent; return p
end
local function model(name,parent)
 local m=Instance.new("Model"); m.Name=name; m.Parent=parent; return m
end
local stone=Color3.fromRGB(100,105,100)
local wood=Color3.fromRGB(85,55,35)
-- Preserva a cidade anterior, se ela já existir.
if not workspace:FindFirstChild("MUBloxVillage") then
 local city=model("MUBloxVillage",workspace)
 local function block(name,size,x,y,z,color,material)
  return part(city,name,size,CFrame.new(x,y,z),color,material)
 end
 block("Terreno",Vector3.new(380,4,380),0,0,0,Color3.fromRGB(76,103,62),Enum.Material.Grass)
 block("Praca",Vector3.new(64,.3,64),0,2.15,0,stone,Enum.Material.Cobblestone)
 block("Rua",Vector3.new(19,.3,300),0,2.15,0,stone,Enum.Material.Cobblestone)
 block("Rua",Vector3.new(300,.3,19),0,2.15,0,stone,Enum.Material.Cobblestone)
 for _, side in {-145,145} do
  for _, n in {-81,81} do
   block("Muralha",Vector3.new(128,17,5),n,10.5,side,stone)
   block("Muralha",Vector3.new(5,17,128),side,10.5,n,stone)
  end
  for n=-138,138,9 do if math.abs(n)>20 then
   block("Ameia",Vector3.new(4,3,5),n,20.5,side,stone)
   block("Ameia",Vector3.new(5,3,4),side,20.5,n,stone)
  end end
 end
 for _, x in {-145,145} do for _, z in {-145,145} do
  block("Torre",Vector3.new(14,27,14),x,15.5,z,stone)
  block("Topo",Vector3.new(17,2,17),x,30,z,stone)
 end end
 for i,data in {{-65,-65,"ESTALAGEM"},{65,-65,"FERRARIA"},{-65,65,"ARMAZEM"},{65,65,"GUILDA"}} do
  local x,z,title=table.unpack(data)
  local origin=CFrame.new(x,2,z)*CFrame.Angles(0,z<0 and math.pi or 0,0)
  local function house(name,size,offset,color,material)
   return part(city,name,size,origin*offset,color,material)
  end
  house("Fundacao",Vector3.new(32,2,26),CFrame.new(0,1,0),stone)
  house("Casa",Vector3.new(30,15,24),CFrame.new(0,9.5,0),Color3.fromRGB(190,175,145),Enum.Material.Plaster)
  for _, side in {-1,1} do
   house("Telhado",Vector3.new(20,1.2,29),CFrame.new(side*8.5,23,0)*CFrame.Angles(0,0,math.rad(-side*32)),Color3.fromRGB(70,80,95))
   for _, back in {-1,1} do house("Viga",Vector3.new(1,16,1),CFrame.new(side*15,10,back*12),wood,Enum.Material.Wood) end
   house("Janela",Vector3.new(4,5,.4),CFrame.new(side*9,10,-12.3),Color3.fromRGB(245,175,80),Enum.Material.Neon)
  end
  house("Porta",Vector3.new(5,8,.5),CFrame.new(0,6,-12.3),wood,Enum.Material.WoodPlanks)
  local board=house(title,Vector3.new(18,3,.5),CFrame.new(0,15,-12.5),wood)
  local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.Parent=board
  local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
  label.Text=title; label.TextScaled=true; label.TextColor3=gold; label.Parent=gui
  block("Acesso",Vector3.new(10,.3,45),x,2.15,z<0 and -31 or 31,stone,Enum.Material.Cobblestone)
 end
 block("Fonte",Vector3.new(20,1,20),0,2.8,0,stone)
 for _, s in {-1,1} do
  block("Borda",Vector3.new(20,2.5,1),0,4,s*9.5,stone)
  block("Borda",Vector3.new(1,2.5,20),s*9.5,4,0,stone)
 end
 local water=block("Agua",Vector3.new(18,.2,18),0,4,0,Color3.fromRGB(60,145,180),Enum.Material.Glass); water.CanCollide=false; water.Transparency=.3
 block("Pedestal",Vector3.new(4,6,4),0,6,0,stone)
 local crystal=block("Cristal",Vector3.new(3,5,3),0,12,0,Color3.fromRGB(140,95,255),Enum.Material.Neon)
 crystal.CFrame*=CFrame.Angles(0,0,math.rad(45))
 local light=Instance.new("PointLight"); light.Color=crystal.Color; light.Range=25; light.Parent=crystal
 for _, x in {-115,115} do for z=-110,110,44 do
  block("Tronco",Vector3.new(3,12,3),x,8,z,wood,Enum.Material.Wood)
  local leaves=block("Copa",Vector3.new(15,16,15),x,18,z,Color3.fromRGB(55,95,50),Enum.Material.Grass)
  leaves.Shape=Enum.PartType.Ball; leaves.CanCollide=false
 end end
 for _, n in {-110,-45,45,110} do for _, x in {-13,13} do
  block("Poste",Vector3.new(.6,10,.6),x,7,n,wood)
  local lantern=block("Lanterna",Vector3.new(1.5,2,1.5),x,12,n,Color3.fromRGB(255,190,100),Enum.Material.Neon)
  local l=Instance.new("PointLight"); l.Range=18; l.Brightness=1; l.Color=lantern.Color; l.Parent=lantern
 end end
end
local spawn=workspace:FindFirstChildWhichIsA("SpawnLocation",true)
if not spawn then spawn=Instance.new("SpawnLocation"); spawn.Size=Vector3.new(6,1,6); spawn.Anchored=true; spawn.Neutral=true; spawn.Parent=workspace end
spawn.CFrame=CFrame.new(0,3,24)
-- START STARTER VISUAL: optional imported cosmetic skin, original R15 drives movement.
local starterParts={"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
local function dimensionsInFrame(size,rotation)
 local x,y,z=rotation.RightVector,rotation.UpVector,rotation.LookVector
 return Vector3.new(math.abs(x.X)*size.X+math.abs(y.X)*size.Y+math.abs(z.X)*size.Z,
  math.abs(x.Y)*size.X+math.abs(y.Y)*size.Y+math.abs(z.Y)*size.Z,
  math.abs(x.Z)*size.X+math.abs(y.Z)*size.Y+math.abs(z.Z)*size.Z)
end
local starterWear={
 Head={"Helmet"},UpperTorso={"Armor"},LowerTorso={"Armor","Pants"},
 LeftHand={"Gloves"},RightHand={"Gloves"},
 LeftUpperLeg={"Pants"},RightUpperLeg={"Pants"},
 LeftLowerLeg={"Pants","Boots"},RightLowerLeg={"Pants","Boots"},
 LeftFoot={"Boots"},RightFoot={"Boots"},
}
local function syncStarterVisibility(player,visualModel)
 if not visualModel then return end
 for _, obj in visualModel:GetChildren() do
  if obj:IsA("BasePart") then
   local slot=obj:GetAttribute("HideSlot")
   obj.Transparency=slot and player:GetAttribute("Equipped"..slot) and 1 or (obj:GetAttribute("BaseTransparency") or 0)
  end
 end
end
local function validateStarterTemplate(template,character)
 if not template or not template:IsA("Model") then return nil,"modelo ausente" end
 local found={}
 for _, obj in template:GetDescendants() do
  if obj:IsA("BasePart") then
   if found[obj.Name] then return nil,"nomes duplicados: "..obj.Name end
   found[obj.Name]=obj
  end
 end
 local layered=found.FormatV2~=nil or found.FormatV3~=nil
 for name in found do if string.sub(name,1,5)=="Wear_" then layered=true end end
 for _, axis in {"AxisOrigin","AxisUp","AxisFront"} do
  if not found[axis] then return nil,"marcador ausente: "..axis end
 end
 local up=found.AxisUp.Position-found.AxisOrigin.Position
 local front=found.AxisFront.Position-found.AxisOrigin.Position
 if up.Magnitude<.001 or front.Magnitude<.001 then return nil,"eixos sem escala" end
 if math.abs(up.Unit:Dot(front.Unit))>.01 then return nil,"eixos deformados" end
 local right=front.Unit:Cross(up.Unit).Unit
 local orientation=CFrame.fromMatrix(Vector3.zero,right,up.Unit,right:Cross(up.Unit))
 local entries={}
 for _, name in starterParts do
  local body=character:FindFirstChild(name)
  local visual,bind=found["Visual_"..name],found["Bind_"..name]
  if not body or not body:IsA("BasePart") then return nil,"requer personagem R15: "..name end
  if not visual or not visual:IsA("MeshPart") or not bind then return nil,"malha/marcador ausente: "..name end
  local frame=CFrame.new(bind.Position)*orientation
  local bindSize=dimensionsInFrame(bind.Size,frame.Rotation:ToObjectSpace(bind.CFrame.Rotation))
  if math.min(bindSize.X,bindSize.Y,bindSize.Z)<.001 then return nil,"marcador sem tamanho: "..name end
  local visuals={{part=visual}}
  if layered then
   for _, slot in starterWear[name] or {} do
    local wear=found["Wear_"..slot.."_"..name]
    if not wear or not wear:IsA("MeshPart") then return nil,"camada V2 ausente: "..slot.."_"..name end
    table.insert(visuals,{part=wear,slot=slot})
   end
  end
  for _, layer in visuals do
   local rotation=frame.Rotation:ToObjectSpace(layer.part.CFrame.Rotation)
   for _, axis in {rotation.RightVector,rotation.UpVector,rotation.LookVector} do
    if math.max(math.abs(axis.X),math.abs(axis.Y),math.abs(axis.Z))<.999 then return nil,"rotacao individual invalida: "..name end
   end
   table.insert(entries,{name=name,body=body,visual=layer.part,frame=frame,bindSize=bindSize,slot=layer.slot,v2=layered,v3=found.FormatV3~=nil})
  end
 end
 return entries
end
-- Fit complete 3D joint vectors; some R15 packages have diagonal local joint axes.
local function starterScale(entry,references)
 local body=entry.body
 local ratio=body.Size/entry.bindSize
 if not entry.v2 then return ratio,Vector3.zero,CFrame.identity end
 local side=string.sub(entry.name,1,4)=="Left" and "Left" or "Right"
 local isArm=string.find(entry.name,"Arm") or string.find(entry.name,"Hand")
 local referenceName=isArm and side.."UpperArm" or (string.find(entry.name,"Leg") or string.find(entry.name,"Foot")) and side.."UpperLeg"
 local reference=referenceName and references[referenceName]
 if not reference then return ratio,Vector3.zero,CFrame.identity end
 if entry.v3 and isArm then
  local function attachment(part,joint)
   local value=part:FindFirstChild(side..joint.."RigAttachment")
   return value and value:IsA("Attachment") and value or nil
  end
  local function axial(name,topJoint,bottomJoint,spanFraction)
   local ref=references[name]
   if not ref then return ratio.Y end
   local top,bottom=attachment(ref.body,topJoint),attachment(ref.body,bottomJoint)
   if top and bottom then
    local span=(top.Position-bottom.Position).Magnitude
    if span>.001 then return span/(ref.bindSize.Y*spanFraction) end
   end
   return ref.body.Size.Y/ref.bindSize.Y
  end
  local upper=axial(side.."UpperArm","Shoulder","Elbow",.58/.75)
  local lower=axial(side.."LowerArm","Elbow","Wrist",1)
  local width=math.min(upper,lower)
  local joint,bottomJoint,pivotFraction,height
  if string.find(entry.name,"UpperArm") then joint="Shoulder"; bottomJoint="Elbow"; pivotFraction=.205/.75; height=upper
  elseif string.find(entry.name,"LowerArm") then joint="Elbow"; bottomJoint="Wrist"; pivotFraction=.5; height=lower
  else joint="Wrist"; pivotFraction=.5; height=width end
  ratio=Vector3.new(width,height,width)
  local target=attachment(body,joint)
  local targetPoint=target and target.Position or Vector3.new(0,body.Size.Y*.5,0)
  local sourcePoint=Vector3.new(0,entry.bindSize.Y*pivotFraction,0)
  local bottom=bottomJoint and attachment(body,bottomJoint)
  local axis=bottom and targetPoint-bottom.Position or bottomJoint and Vector3.new(0,1,0) or targetPoint
  if axis.Magnitude<.001 then axis=Vector3.new(0,1,0) end
  local up=axis.Unit
  local right=up:Cross(Vector3.new(0,0,1))
  if right.Magnitude<.001 then right=up:Cross(Vector3.new(1,0,0)) end
  right=right.Unit
  local rotation=CFrame.fromMatrix(Vector3.zero,right,up,right:Cross(up))
  return ratio,targetPoint-rotation:VectorToWorldSpace(sourcePoint*ratio),rotation
 end
 local shared=reference.body.Size/reference.bindSize
 return Vector3.new(shared.X,ratio.Y,shared.Z),Vector3.zero,CFrame.identity
end
local function applyStarterVisual(player,character,rebuild)
 if player.Character~=character then return false end
 if player:GetAttribute("Class")~="Guerreiro" then return false end
 local existing=character:FindFirstChild("MUBloxStarterVisual")
 local skinnedTemplate=game:GetService("ServerStorage"):FindFirstChild("MUBloxWarriorSkinned")
 local skinnedReady=existing and existing:GetAttribute("SkinnedV5") and not rebuild
 if skinnedTemplate and not skinnedReady then
  local visual,reason=SkinnedWarrior.mount(skinnedTemplate,character)
  if visual then
   if existing then existing:Destroy() end
   existing=visual; skinnedReady=true
   print("MUBlox visual: V5 articulado, 15 ossos e 7 malhas")
  else warn("MUBlox V5: "..tostring(reason).."; mantendo visual anterior") end
 end
 if not skinnedReady and (not existing or rebuild) then
  local template=game:GetService("ServerStorage"):FindFirstChild("MUBloxWarriorVisual")
  if not template then return false end -- Existing game remains usable without imported assets.
  local entries,reason=validateStarterTemplate(template,character)
  if not entries then warn("MUBlox: visual inicial nao aplicado: "..reason); return false end
  local visualModel=Instance.new("Model"); visualModel.Name="MUBloxStarterVisual"
  local references={}
  for _, entry in entries do references[entry.name]=entry end
  visualModel:SetAttribute("FormatV2",entries[1].v2)
  local revision=entries[1].v3 and 4 or entries[1].v2 and 2 or 1
  visualModel:SetAttribute("VisualRevision",revision)
  -- Prepare every mesh before hiding the original avatar.
  for _, entry in entries do
   local body=entry.body
   local ratio,pivotOffset,fitRotation=starterScale(entry,references)
   local relative=entry.frame:ToObjectSpace(entry.visual.CFrame)
   local copy=entry.visual:Clone()
   for _, child in copy:GetDescendants() do
    if child:IsA("LuaSourceContainer") or child:IsA("JointInstance") or child:IsA("Constraint") then child:Destroy() end
   end
   local localScale=dimensionsInFrame(ratio,relative.Rotation:Inverse())
   copy.Size=entry.visual.Size*localScale
   copy.CFrame=body.CFrame*CFrame.new(pivotOffset)*fitRotation*CFrame.new(relative.Position*ratio)*relative.Rotation
   copy.Anchored=false; copy.Massless=true; copy.CanCollide=false; copy.CanTouch=false; copy.CanQuery=false
   copy:SetAttribute("BodyPart",entry.name)
   copy:SetAttribute("FitRotation",fitRotation)
   copy:SetAttribute("HideSlot",entry.slot)
   copy:SetAttribute("BaseTransparency",entry.visual.Transparency)
   copy.Parent=visualModel
   local weld=Instance.new("WeldConstraint"); weld.Part0=body; weld.Part1=copy; weld.Parent=copy
  end
  visualModel.Parent=character
  print(string.format("MUBlox visual: V%d, %d malhas",revision,#entries))
  if existing then existing:Destroy() end
 end
 for _, name in starterParts do
  local part=character:FindFirstChild(name)
  if part then
   part.Transparency=1
   for _, obj in part:GetDescendants() do if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1 end end
  end
 end
 for _, child in character:GetChildren() do
  if child:IsA("Accessory") then
   for _, obj in child:GetDescendants() do if obj:IsA("BasePart") then obj.Transparency=1 end end
  end
 end
 if not player:GetAttribute("StarterVisualInitialized") then
  player:SetAttribute("StarterVisualInitialized",true)
  for _, slot in {"Helmet","Armor","Gloves","Pants","Boots","Wings"} do player:SetAttribute("Equipped"..slot,false) end
 end
 return true
end
-- END STARTER VISUAL

-- Equipamentos visuais: nenhuma peça concede atributos nesta versão.
local function refreshEquipment(player)
 local c=player.Character; local class=classes[player:GetAttribute("Class")]
 local h=c and c:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 or not class then return end
 local base=h:GetAttribute("MUBloxBaseHip")
 if base==nil then base=h.HipHeight; h:SetAttribute("MUBloxBaseHip",base) end
 h.HipHeight=base+(player:GetAttribute("EquippedWings") and .85 or 0)
 local old=c:FindFirstChild("MUBloxArmor"); if old then old:Destroy() end
 local armor=model("MUBloxArmor",c)
 local starter=c:FindFirstChild("MUBloxStarterVisual")
 syncStarterVisibility(player,starter)
 local function fitted(body)
  if starter and starter:GetAttribute("SkinnedV5") then return body.Size,Vector3.zero,CFrame.identity end
  if not starter or not starter:GetAttribute("FormatV2") then return body.Size,Vector3.zero,CFrame.identity end
  local rotation=CFrame.identity
  for _, visual in starter:GetChildren() do
   if visual:IsA("BasePart") and visual:GetAttribute("BodyPart")==body.Name then
    rotation=visual:GetAttribute("FitRotation") or CFrame.identity; break
   end
  end
  local fittingFrame=body.CFrame*rotation
  local low=Vector3.new(math.huge,math.huge,math.huge)
  local high=-low
  local found=false
  for _, visual in starter:GetChildren() do
   if visual:IsA("BasePart") and visual:GetAttribute("BodyPart")==body.Name then
    for _, x in {-1,1} do for _, y in {-1,1} do for _, z in {-1,1} do
     local corner=fittingFrame:PointToObjectSpace(visual.CFrame:PointToWorldSpace(visual.Size*Vector3.new(x,y,z)*.5))
     low=Vector3.new(math.min(low.X,corner.X),math.min(low.Y,corner.Y),math.min(low.Z,corner.Z))
     high=Vector3.new(math.max(high.X,corner.X),math.max(high.Y,corner.Y),math.max(high.Z,corner.Z))
     found=true
    end end end
   end
  end
  if not found then return body.Size,Vector3.zero,CFrame.identity end
  return high-low,(high+low)*.5,rotation
 end
 local function limb(a,b) return SkinnedWarrior.body(c,a) or SkinnedWarrior.body(c,b) end
 local torso=limb("UpperTorso","Torso")
 local function piece(name,body,size,offset,color,shape)
  if not body then return end
  local p=part(armor,name,size,body.CFrame*offset,color or class[3],Enum.Material.Metal)
  p.Anchored=false; p.Massless=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Shape=shape or Enum.PartType.Ball
  local w=Instance.new("WeldConstraint"); w.Part0=body; w.Part1=p; w.Parent=p; return p
 end
 local head=SkinnedWarrior.body(c,"Head")
 if player:GetAttribute("EquippedHelmet") and head then
  if starter and starter:GetAttribute("FormatV2") then
   local size,offset=fitted(head)
   piece("Helmet",head,size*Vector3.new(1.12,1.12,1.14),CFrame.new(offset))
   piece("Visor",head,Vector3.new(size.X*.7,size.Y*.18,.12),CFrame.new(offset+Vector3.new(0,0,-size.Z*.57)),Color3.fromRGB(20,20,25),Enum.PartType.Block)
  else
   piece("Helmet",head,head.Size*Vector3.new(1.2,1.4,1.35),CFrame.new(0,.1,0))
   piece("Visor",head,Vector3.new(head.Size.X*.7,.28,.12),CFrame.new(0,.05,-head.Size.Z*.68),Color3.fromRGB(20,20,25),Enum.PartType.Block)
  end
 end
 if player:GetAttribute("EquippedArmor") and torso then
  local size,offset=fitted(torso)
  piece("Armor",torso,size*Vector3.new(1.15,1.08,1.3),CFrame.new(offset))
  piece("Emblema",torso,Vector3.new(.8,.8,.18),CFrame.new(offset+Vector3.new(0,0,-size.Z*.66))*CFrame.Angles(0,0,math.rad(45)),gold,Enum.PartType.Block)
 end
 if starter and starter:GetAttribute("FormatV2") then
  local pelvis=SkinnedWarrior.body(c,"LowerTorso")
  if pelvis and (player:GetAttribute("EquippedArmor") or player:GetAttribute("EquippedPants")) then
   local size,offset=fitted(pelvis)
   piece("CinturaSet",pelvis,size*Vector3.new(1.12,1.05,1.15),CFrame.new(offset))
  end
 end
 for _, side in {"Left","Right"} do
  local arm=limb(side.."UpperArm",side.." Arm")
  if player:GetAttribute("EquippedArmor") and arm then
   if starter and starter:GetAttribute("FormatV2") then
    local size,offset,rotation=fitted(arm)
    piece("Ombreira",arm,Vector3.new(size.X*1.25,math.max(.25,size.Y*.32),size.Z*1.25),rotation*CFrame.new(offset+Vector3.new(0,size.Y*.34,0)))
   else
    piece("Ombreira",arm,Vector3.new(arm.Size.X*1.6,.8,arm.Size.Z*1.6),CFrame.new(0,arm.Size.Y*.35,0))
   end
  end
  for _, info in {{"Gloves",side.."Hand",side.." Arm"},{"Pants",side.."UpperLeg",side.." Leg"},{"Boots",side.."Foot",side.." Leg"}} do
   local slot,a,b=table.unpack(info); local body=limb(a,b)
   if body and player:GetAttribute("Equipped"..slot) then
    local r6=h.RigType==Enum.HumanoidRigType.R6
    local short=slot~="Pants"
    local size,offset,rotation=fitted(body)
    local heightFactor=starter and starter:GetAttribute("FormatV2") and 1.05 or .95
    piece(slot,body,Vector3.new(size.X*1.2,r6 and short and .8 or size.Y*heightFactor,size.Z*1.2),rotation*CFrame.new(offset+Vector3.new(0,r6 and short and -.6 or 0,0)))
   end
  end
  if starter and starter:GetAttribute("FormatV2") and player:GetAttribute("EquippedBoots") then
   local shin=SkinnedWarrior.body(c,side.."LowerLeg")
   if shin then
    local size,offset=fitted(shin)
    piece("GrevaSet",shin,size*Vector3.new(1.12,1.04,1.15),CFrame.new(offset))
   end
  end
 end
 if player:GetAttribute("EquippedWings") and torso then
  local className=player:GetAttribute("Class")
  armor:SetAttribute("WingCount",className=="Mago" and 28 or 2)
  if className=="Mago" then
   -- Mantém a asa de penas e sua batida já aprovada.
   for _, side in {-1,1} do for i=1,7 do
    local offset=CFrame.new(side*(.65+i*.39),.1+i*.25,1.05+i*.04)*CFrame.Angles(0,0,math.rad(-side*(12+i*6)))
    piece("WingsFeather",torso,Vector3.new(.57,2.3+i*.17,.24),offset,Color3.fromRGB(225,230,245))
    local glow=piece("WingsGlow",torso,Vector3.new(.1,(2.3+i*.17)*.82,.09),offset*CFrame.new(0,0,.15),Color3.fromRGB(160,215,255)); glow.Material=Enum.Material.Neon
   end end
  else
   -- Membranas e nervuras compartilham um pivô para não se separarem.
   for _, side in {-1,1} do
    local pivot=piece("WingPivot",torso,Vector3.new(.1,.1,.1),CFrame.new(side*.45,.45,torso.Size.Z*.5+.35))
    pivot.Transparency=1
    pivot:SetAttribute("WingSide",side)
    pivot:SetAttribute("WingStyle",className)
    local function shape(name,size,cf,color,transparency,kind)
     local p=Instance.new(kind or "Part"); p.Name=name; p.Size=size; p.CFrame=pivot.CFrame*cf
     p.Color=color; p.Transparency=transparency or 0; p.Material=Enum.Material.SmoothPlastic
     p.Massless=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=armor
     local w=Instance.new("WeldConstraint"); w.Part0=pivot; w.Part1=p; w.Parent=p
     return p
    end
    local function rod(a,b,color,width)
     return shape("WingVein",Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
    end
    if className=="Guerreiro" then
     local red=Color3.fromRGB(100,27,38)
     local edge=Color3.fromRGB(45,26,35)
     local origin=Vector3.new(0,0,0)
     local tips={Vector3.new(side*.9,2,0),Vector3.new(side*2.6,1.5,0),Vector3.new(side*3.4,-.25,0),Vector3.new(side*1.7,-1.1,0),Vector3.new(side*.5,-1.5,0)}
     local function triangle(a,b,c)
      local ab,ac,bc=b-a,c-a,c-b
      if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then c,a=a,c
      elseif ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
      ab,ac,bc=b-a,c-a,c-b
      local right=ac:Cross(ab).Unit
      local up=bc:Cross(right).Unit
      local back=bc.Unit
      local height=math.abs(ab:Dot(up))
      shape("BatMembrane",Vector3.new(.09,height,math.abs(ab:Dot(back))),CFrame.fromMatrix((a+b)/2,right,up,back),red,.08,"WedgePart")
      shape("BatMembrane",Vector3.new(.09,height,math.abs(ac:Dot(back))),CFrame.fromMatrix((a+c)/2,-right,up,-back),red,.08,"WedgePart")
     end
     for i=1,#tips-1 do
      -- Borda recortada entre os dedos da asa de morcego.
      local notch=(tips[i]+tips[i+1])*.34
      triangle(origin,tips[i],notch)
      triangle(origin,notch,tips[i+1])
      rod(tips[i],notch,edge,.1); rod(notch,tips[i+1],edge,.1)
     end
     for _, tip in tips do rod(origin,tip,edge,.16) end
    else
     local upper=CFrame.new(side*1.25,1,0)*CFrame.Angles(0,0,math.rad(-side*30))
     local lower=CFrame.new(side*.85,-.8,.03)*CFrame.Angles(0,0,math.rad(side*25))
     for _, data in {{upper,Vector3.new(2.1,3.1,.12),Color3.fromRGB(125,205,240)}, {lower,Vector3.new(1.6,2.1,.12),Color3.fromRGB(200,150,235)}} do
      local lobe=shape("ButterflyMembrane",data[2],data[1],data[3],.4)
      lobe.Shape=Enum.PartType.Ball
      local inset=shape("ButterflyPattern",data[2]*Vector3.new(.7,.7,.6),data[1]*CFrame.new(0,0,.08),Color3.fromRGB(205,245,225),.55)
      inset.Shape=Enum.PartType.Ball
     end
     for _, tip in {Vector3.new(side*1.5,2,0),Vector3.new(side*2,1,0),Vector3.new(side*1.5,-1,0),Vector3.new(side*.7,-1.7,0)} do
      rod(Vector3.zero,tip,Color3.fromRGB(185,225,210),.045).Transparency=.25
     end
    end
   end
  end
 end
 local backpack=player:FindFirstChildOfClass("Backpack"); if not backpack then return end
 local tool=c:FindFirstChild("MUBloxWeapon") or backpack:FindFirstChild("MUBloxWeapon")
 if not player:GetAttribute("EquippedSword") then if tool then tool:Destroy() end; return end
 if tool then if tool.Parent~=c then h:EquipTool(tool) end; SkinnedWarrior.grip(c); return end
 local className=player:GetAttribute("Class")
 tool=Instance.new("Tool"); tool.Name="MUBloxWeapon"; tool.CanBeDropped=false
 tool:SetAttribute("WeaponClass",className)
 tool.ToolTip=className=="Mago" and "Staff" or className=="Elfa" and "Arco" or "Espada"
 local handle=part(tool,"Handle",Vector3.new(.3,1.3,.3),CFrame.new(),wood,Enum.Material.Wood)
 handle.Anchored=false; handle.Massless=true; handle.CanCollide=false; handle.CanTouch=false; handle.CanQuery=false
 local function weaponPart(name,size,offset,color,material)
  local p=part(tool,name,size,handle.CFrame*offset,color,material or Enum.Material.Metal)
  p.Anchored=false; p.Massless=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
  local w=Instance.new("WeldConstraint"); w.Part0=handle; w.Part1=p; w.Parent=p
  return p
 end
 local tip=Instance.new("Attachment"); tip.Name="CastPoint"; tip.Parent=handle
 if className=="Guerreiro" then
  weaponPart("Guarda",Vector3.new(1.7,.25,.5),CFrame.new(0,.65,0),gold)
  weaponPart("Lamina",Vector3.new(.65,3.4,.18),CFrame.new(0,2.4,0),Color3.fromRGB(195,210,225))
  tip.Position=Vector3.new(0,4.1,0)
 elseif className=="Mago" then
  weaponPart("Haste",Vector3.new(.28,4.8,.28),CFrame.new(0,.8,0),wood,Enum.Material.Wood)
  weaponPart("Coroa",Vector3.new(.85,.3,.85),CFrame.new(0,3.2,0),gold)
  local crystal=weaponPart("Cristal",Vector3.new(.75,1.1,.75),CFrame.new(0,3.8,0)*CFrame.Angles(0,0,math.rad(45)),Color3.fromRGB(155,95,255),Enum.Material.Neon)
  local light=Instance.new("PointLight"); light.Range=7; light.Brightness=.5; light.Color=crystal.Color; light.Parent=crystal
  tip.Position=Vector3.new(0,4.2,0)
 else
  local points={Vector3.new(.65,-2,0),Vector3.new(.05,-1.3,0),Vector3.new(-.2,-.5,0),Vector3.new(-.2,.5,0),Vector3.new(.05,1.3,0),Vector3.new(.65,2,0)}
  for i=1,#points-1 do
   local a,b=points[i],points[i+1]
   weaponPart("LaminaArco",Vector3.new(.18,.22,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),gold)
  end
  weaponPart("Corda",Vector3.new(.035,4,.035),CFrame.new(.65,0,0),Color3.fromRGB(210,235,205))
  tip.Position=Vector3.new(.65,0,-.5)
 end
 tool.Parent=backpack; h:EquipTool(tool); SkinnedWarrior.grip(c)
end
local function applyClass(player,c)
 local h=c:WaitForChild("Humanoid"); if player.Character~=c then return end
 local class=classes[player:GetAttribute("Class")]; if not class then return end
 applyStarterVisual(player,c)
 h.MaxHealth=class[1]; h.Health=class[1]
 player:SetAttribute("MaxMana",class[2]); player:SetAttribute("Mana",class[2]); refreshEquipment(player)
end
local function setup(player)
 for key,value in {Level=1,Experience=0,Mana=0,MaxMana=0,SpinReadyAt=0} do player:SetAttribute(key,value) end
 for _, slot in slots do player:SetAttribute("Equipped"..slot,slot~="Wings") end
 player.CharacterAdded:Connect(function(c)
  c.DescendantAdded:Connect(function(obj)
   if obj.Name=="RightGrip" and obj:IsA("Motor6D") then task.defer(SkinnedWarrior.grip,c) end
  end)
  applyClass(player,c)
 end)
 player.CharacterAppearanceLoaded:Connect(function(c)
  applyStarterVisual(player,c,true); refreshEquipment(player)
 end)
 if player.Character then task.spawn(applyClass,player,player.Character) end
end
Players.PlayerAdded:Connect(setup); for _, p in Players:GetPlayers() do setup(p) end
-- Área e inimigo de treino.
local zone=workspace:FindFirstChild("MUBloxTrainingGround") or model("MUBloxTrainingGround",workspace)
for _, child in zone:GetChildren() do if child.Name=="GolemDePedra" then child:Destroy() end end
if not zone:FindFirstChild("Campo") then
 part(zone,"Campo",Vector3.new(130,4,120),CFrame.new(0,0,-235),Color3.fromRGB(76,96,57),Enum.Material.Grass)
 part(zone,"Caminho",Vector3.new(19,.3,110),CFrame.new(0,2.15,-205),stone,Enum.Material.Cobblestone)
 part(zone,"Arena",Vector3.new(55,.4,45),CFrame.new(0,2.2,-235),stone,Enum.Material.Cobblestone)
 for _, x in {-30,30} do for _, z in {-215,-255} do part(zone,"Pilar",Vector3.new(5,12,5),CFrame.new(x,8,z),stone) end end
end
local enemies={}
local spawnPositions={Vector3.new(-14,7.4,-245),Vector3.new(14,7.4,-245),Vector3.new(0,7.4,-221)}
local arenaCenter=Vector3.new(0,7.4,-235)
local patrolPoints={Vector3.new(-16,7.4,-247),Vector3.new(16,7.4,-247),Vector3.new(16,7.4,-223),Vector3.new(-16,7.4,-223)}
local function spawnMob(slot)
 local mob=model("GolemDePedra",zone); local health=120
 local origin=spawnPositions[slot]
 mob:SetAttribute("Health",health); mob:SetAttribute("MaxHealth",120)
 local torso=part(mob,"Corpo",Vector3.new(5,5,3),CFrame.new(origin),stone)
 mob.PrimaryPart=torso
 local joints={}
 local function body(name,size,offset,color,pivot)
  local p=part(mob,name,size,torso.CFrame*CFrame.new(offset),color or stone)
  p.Anchored=false; p.Massless=true; p.CanCollide=false
  local joint=Instance.new("Motor6D"); joint.Name=name.."Joint"; joint.Part0=torso; joint.Part1=p
  joint.C0=CFrame.new(pivot or offset); joint.C1=CFrame.new((pivot or offset)-offset); joint.Parent=torso
  joints[name]={joint=joint,rest=joint.C0}
  return p
 end
 body("Cabeca",Vector3.new(3,2.5,2.8),Vector3.new(0,3.5,0))
 for _, side in {-1,1} do
  local suffix=side<0 and "Left" or "Right"
  body("Arm"..suffix,Vector3.new(2,4.5,2.5),Vector3.new(side*3.5,0,0),nil,Vector3.new(side*3,2,0))
  body("Leg"..suffix,Vector3.new(2,3,2.5),Vector3.new(side*1.4,-3.5,0),nil,Vector3.new(side*1.4,-2,0))
  body("Eye"..suffix,Vector3.new(.5,.4,.15),Vector3.new(side*.65,3.7,-1.45),gold).Material=Enum.Material.Neon
 end
 local gui=Instance.new("BillboardGui"); gui.Name="HealthDisplay"; gui.Size=UDim2.fromOffset(180,48)
 gui.StudsOffset=Vector3.new(0,6,0); gui.MaxDistance=100; gui.Parent=torso
 local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,0,0,26); title.BackgroundTransparency=1
 title.Text="GOLEM DE PEDRA"; title.TextColor3=gold; title.TextStrokeTransparency=.3; title.TextSize=14; title.Parent=gui
 local track=Instance.new("Frame"); track.Name="Track"; track.Size=UDim2.new(1,-12,0,12); track.Position=UDim2.fromOffset(6,29)
 track.BackgroundColor3=Color3.fromRGB(35,24,25); track.BorderSizePixel=0; track.ClipsDescendants=true; track.Parent=gui
 local fill=Instance.new("Frame"); fill.Name="Fill"; fill.Size=UDim2.fromScale(1,1); fill.BorderSizePixel=0
 fill.BackgroundColor3=Color3.fromRGB(70,200,90); fill.Parent=track
 local border=Instance.new("UIStroke"); border.Color=gold; border.Thickness=1; border.Parent=track
 enemies[mob]={health=120,slot=slot,ai={position=origin,forward=Vector3.new(0,0,-1),goal=slot,joints=joints,phase=0,nextAttack=0}}
end
for slot=1,#spawnPositions do spawnMob(slot) end
local cooldowns={}; local requests={}
local function sight(origin,target,exclude,expected)
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={exclude}
 local hit=workspace:Raycast(origin,target-origin,params)
 return not hit or hit.Instance:IsDescendantOf(expected)
end
-- Regras de combate por classe. O cliente envia intenção, nunca dano ou mana.
local combatProfiles={
 Guerreiro={basicRange=10,basicDamage=15,basicCooldown=.6,skill="Spin",skillName="Golpe Giratório",skillRange=14,skillDamage=45,mana=20,cooldown=3,duration=.65},
 Mago={basicRange=60,basicDamage=18,basicCooldown=.7,projectile="Orb",speed=75,skill="Spirits",skillName="Espíritos",skillRange=65,skillDamage=35,mana=30,cooldown=4,duration=.7},
 Elfa={basicRange=55,basicDamage=16,basicCooldown=.6,projectile="Arrow",speed=100,skill="MultiShot",skillName="Multi-Shot",skillRange=55,skillDamage=32,mana=25,cooldown=3,duration=.45},
}
local function eligibleEnemy(enemy,origin,range,character)
 local data=enemies[enemy]
 return data and data.health>0 and enemy.Parent and enemy.PrimaryPart
  and (enemy.PrimaryPart.Position-origin).Magnitude<=range
  and sight(origin,enemy.PrimaryPart.Position,character,enemy)
end
local function dealDamage(player,enemy,amount,skillHit)
 local data=enemies[enemy]
 if not data or data.health<=0 or not enemy.Parent then return end
 local damage=math.min(data.health,amount)
 local position=enemy.PrimaryPart.Position
 data.health-=damage; enemy:SetAttribute("Health",data.health)
 R:FireAllClients("Damage",position,damage,skillHit)
 if data.health==0 then
  enemies[enemy]=nil; enemy:Destroy()
  local xp=(player:GetAttribute("Experience") or 0)+50
  local level=player:GetAttribute("Level") or 1
  while xp>=100 do xp-=100; level+=1 end
  player:SetAttribute("Experience",xp); player:SetAttribute("Level",level)
  R:FireClient(player,"+50 XP · Nível "..level)
  task.delay(5,function() spawnMob(data.slot) end)
 end
end
local function launchProjectile(player,character,origin,enemy,damage,range,speed,kind,skillHit)
 local destination=enemy.PrimaryPart.Position
 local duration=math.clamp((destination-origin).Magnitude/speed,.12,.9)
 R:FireAllClients("Projectile",kind,origin,destination,enemy,duration,workspace:GetServerTimeNow())
 task.delay(duration,function()
  local h=character:FindFirstChildOfClass("Humanoid")
  if player.Parent and player.Character==character and h and h.Health>0
   and eligibleEnemy(enemy,origin,range+5,character) then
   dealDamage(player,enemy,damage,skillHit)
  end
 end)
end
R.OnServerEvent:Connect(function(player,action,value)
 if typeof(action)~="string" then return end
 local now=workspace:GetServerTimeNow()
 if now-(requests[player] or -math.huge)<.08 then return end; requests[player]=now
 if action=="Class" then
  if typeof(value)~="string" or not classes[value] or player:GetAttribute("Class") then return end
  player:SetAttribute("Class",value)
  local profile=combatProfiles[value]
  player:SetAttribute("SkillName",profile.skillName); player:SetAttribute("SkillMana",profile.mana)
  if player.Character then applyClass(player,player.Character) end
  return
 end
 local className=player:GetAttribute("Class")
 local profile=combatProfiles[className]
 if not profile then return end
 if action=="Equip" then
  if typeof(value)~="string" or not allowed[value] then return end
  player:SetAttribute("Equipped"..value,not player:GetAttribute("Equipped"..value)); refreshEquipment(player); return
 end
 if action~="Basic" and action~="Skill" then return end
 local character=player.Character
 local h=character and character:FindFirstChildOfClass("Humanoid")
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if not h or h.Health<=0 or not root then return end
 local weapon=character:FindFirstChild("MUBloxWeapon")
 if not weapon or weapon:GetAttribute("WeaponClass")~=className then R:FireClient(player,"Equipe sua arma"); return end
 local isSkill=action=="Skill"
 local times=cooldowns[player] or {}; cooldowns[player]=times
 if now<(times[action] or 0) or now<(times.Lock or 0) then return end
 local targets={}
 local origin=root.Position
 local forward=root.CFrame.LookVector
 if not isSkill then
  if not eligibleEnemy(value,origin,profile.basicRange,character) then R:FireClient(player,"Clique em um monstro ao alcance"); return end
  targets[1]=value
 elseif className=="Mago" then
  -- A câmera escolhe os candidatos. Registro, alcance, obstáculos e duplicatas
  -- são conferidos no servidor; nenhum candidato pode definir seu próprio dano.
  if value~=nil and typeof(value)~="table" then return end
  local seen={}
  for index,enemy in ipairs(value or {}) do
   if index>32 then break end
   if not seen[enemy] and eligibleEnemy(enemy,origin,profile.skillRange,character) then
    seen[enemy]=true; table.insert(targets,enemy)
   end
  end
 else
  for enemy in pairs(enemies) do
   if not eligibleEnemy(enemy,origin,profile.skillRange,character) then continue end
   local delta=enemy.PrimaryPart.Position-origin
   local inCone=true
   if className=="Elfa" then
    local flat=Vector3.new(delta.X,0,delta.Z)
    local facing=Vector3.new(forward.X,0,forward.Z)
    inCone=flat.Magnitude<.1 or (facing.Magnitude>.1 and facing.Unit:Dot(flat.Unit)>=math.cos(math.rad(40)))
   end
   if inCone then table.insert(targets,enemy) end
  end
 end
 local mana=player:GetAttribute("Mana") or 0
 if isSkill and mana<profile.mana then R:FireClient(player,"Mana insuficiente"); return end
 local animation=isSkill and profile.skill or profile.projectile or "Basic"
 local animationDuration=isSkill and profile.duration or (className=="Guerreiro" and .32 or .4)
 times[action]=now+(isSkill and profile.cooldown or profile.basicCooldown)
 times.Lock=now+animationDuration
 if isSkill then
  player:SetAttribute("Mana",mana-profile.mana)
  player:SetAttribute("SpinReadyAt",now+profile.cooldown)
 end
 player:SetAttribute("MUBloxAttackKind",animation)
 player:SetAttribute("MUBloxAttackDuration",animationDuration)
 player:SetAttribute("MUBloxAttackTime",now)
 local castOrigin=origin+Vector3.new(0,1,0)+forward*1.5
 local handle=weapon:FindFirstChild("Handle")
 local castPoint=handle and handle:FindFirstChild("CastPoint")
 if castPoint and (castPoint.WorldPosition-origin).Magnitude<10 then castOrigin=castPoint.WorldPosition end
 if isSkill then
  R:FireClient(player,profile.skillName.."!")
  if className~="Guerreiro" then R:FireAllClients("Cast",animation,castOrigin,forward,now) end
 end
 for _, enemy in targets do
  local damage=isSkill and profile.skillDamage or profile.basicDamage
  if className=="Guerreiro" then
   dealDamage(player,enemy,damage,isSkill)
  else
   local kind=isSkill and className=="Mago" and "Spirit" or profile.projectile
   launchProjectile(player,character,castOrigin,enemy,damage,isSkill and profile.skillRange or profile.basicRange,
    kind=="Spirit" and 65 or profile.speed,kind,isSkill)
  end
 end
end)
Players.PlayerRemoving:Connect(function(p) cooldowns[p]=nil; requests[p]=nil end)
task.spawn(function() while true do task.wait(1)
 for _, p in Players:GetPlayers() do
  local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  if h and h.Health>0 then p:SetAttribute("Mana",math.min(p:GetAttribute("MaxMana") or 0,(p:GetAttribute("Mana") or 0)+5)) end
 end
end end)
-- Patrulha e perseguição autoritativas, com alcance limitado à arena.
local function clampToArena(position)
 return Vector3.new(math.clamp(position.X,-22,22),arenaCenter.Y,math.clamp(position.Z,-252,-218))
end
local function findEnemyTarget(enemy,position)
 local selected=nil
 local distance=32
 for _, p in Players:GetPlayers() do
  local c=p.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); local root=c and c:FindFirstChild("HumanoidRootPart")
  if h and root and h.Health>0 and p:GetAttribute("Class") then
   local homeDistance=(root.Position-arenaCenter).Magnitude
   local d=(root.Position-position).Magnitude
   if homeDistance<=42 and d<distance and sight(position,root.Position,enemy,c) then
    selected={character=c,humanoid=h,root=root}; distance=d
   end
  end
 end
 return selected,distance
end
local function updateEnemy(mob,data,step,now)
 if not mob.Parent or data.health<=0 then return end
 local ai=data.ai
 local torso=mob.PrimaryPart
 local target,distance=findEnemyTarget(mob,ai.position)
 local moving=false
 local armAngle=0
 if ai.attack then
  local elapsed=now-ai.attack.started
  if elapsed<.45 then
   armAngle=math.rad(140)*math.clamp(elapsed/.45,0,1)
  else
   armAngle=math.rad(140)*math.max(0,1-(elapsed-.45)/.4)
  end
  if elapsed>=.45 and not ai.attack.struck then
   ai.attack.struck=true
   local victim=ai.attack.target
   if victim.root.Parent and victim.humanoid.Health>0
    and (victim.root.Position-ai.position).Magnitude<=11
    and sight(ai.position,victim.root.Position,mob,victim.character) then
    victim.humanoid:TakeDamage(12)
   end
  end
  if elapsed>=.9 then ai.attack=nil end
 elseif target and distance<=9 then
  local facing=Vector3.new(target.root.Position.X-ai.position.X,0,target.root.Position.Z-ai.position.Z)
  if facing.Magnitude>.01 then ai.forward=facing.Unit end
  if now>=ai.nextAttack then
   ai.attack={started=now,target=target,struck=false}; ai.nextAttack=now+1.8
  end
 else
  local destination=target and clampToArena(target.root.Position) or patrolPoints[ai.goal]
  local delta=destination-ai.position
  if delta.Magnitude<.5 then
   if not target then ai.goal=ai.goal%#patrolPoints+1 end
  else
   local speed=target and 8 or 4
   local travel=math.min(delta.Magnitude,speed*step)
   ai.forward=delta.Unit
   ai.position=clampToArena(ai.position+delta.Unit*travel)
   ai.phase+=travel*1.5
   moving=true
  end
 end
 local bob=moving and math.abs(math.sin(ai.phase))*.12 or 0
 torso.CFrame=CFrame.lookAt(ai.position+Vector3.new(0,bob,0),ai.position+Vector3.new(0,bob,0)+ai.forward)
 torso.Color=ai.attack and Color3.fromRGB(185,85,55) or stone
 local walk=moving and math.sin(ai.phase)*math.rad(23) or 0
 for name,entry in pairs(ai.joints) do
  local angle=0
  if name=="LegLeft" then angle=walk
  elseif name=="LegRight" then angle=-walk
  elseif name=="ArmLeft" then angle=ai.attack and armAngle or -walk*.6
  elseif name=="ArmRight" then angle=ai.attack and armAngle or walk*.6 end
  entry.joint.C0=entry.rest*CFrame.Angles(angle,0,0)
 end
end
local elapsedAI=0
game:GetService("RunService").Heartbeat:Connect(function(dt)
 elapsedAI+=dt
 if elapsedAI<.05 then return end
 local step=math.min(elapsedAI,.1); elapsedAI=0
 local now=workspace:GetServerTimeNow()
 for enemy,data in pairs(enemies) do updateEnemy(enemy,data,step,now) end
end)
