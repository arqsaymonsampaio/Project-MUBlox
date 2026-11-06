
local Players = game:GetService("Players")
local R = game:GetService("ReplicatedStorage"):WaitForChild("MUBloxAction")
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
 local function limb(a,b) return c:FindFirstChild(a) or c:FindFirstChild(b) end
 local torso=limb("UpperTorso","Torso")
 local function piece(name,body,size,offset,color,shape)
  if not body then return end
  local p=part(armor,name,size,body.CFrame*offset,color or class[3],Enum.Material.Metal)
  p.Anchored=false; p.Massless=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Shape=shape or Enum.PartType.Ball
  local w=Instance.new("WeldConstraint"); w.Part0=body; w.Part1=p; w.Parent=p; return p
 end
 local head=c:FindFirstChild("Head")
 if player:GetAttribute("EquippedHelmet") and head then
  piece("Helmet",head,head.Size*Vector3.new(1.2,1.4,1.35),CFrame.new(0,.1,0))
  piece("Visor",head,Vector3.new(head.Size.X*.7,.28,.12),CFrame.new(0,.05,-head.Size.Z*.68),Color3.fromRGB(20,20,25),Enum.PartType.Block)
 end
 if player:GetAttribute("EquippedArmor") and torso then
  piece("Armor",torso,torso.Size*Vector3.new(1.15,1.08,1.3),CFrame.new())
  piece("Emblema",torso,Vector3.new(.8,.8,.18),CFrame.new(0,0,-torso.Size.Z*.66)*CFrame.Angles(0,0,math.rad(45)),gold,Enum.PartType.Block)
 end
 for _, side in {"Left","Right"} do
  local arm=limb(side.."UpperArm",side.." Arm")
  if player:GetAttribute("EquippedArmor") and arm then piece("Ombreira",arm,Vector3.new(arm.Size.X*1.6,.8,arm.Size.Z*1.6),CFrame.new(0,arm.Size.Y*.35,0)) end
  for _, info in {{"Gloves",side.."Hand",side.." Arm"},{"Pants",side.."UpperLeg",side.." Leg"},{"Boots",side.."Foot",side.." Leg"}} do
   local slot,a,b=table.unpack(info); local body=limb(a,b)
   if body and player:GetAttribute("Equipped"..slot) then
    local r6=h.RigType==Enum.HumanoidRigType.R6
    local short=slot~="Pants"
    piece(slot,body,Vector3.new(body.Size.X*1.2,r6 and short and .8 or body.Size.Y*.95,body.Size.Z*1.2),CFrame.new(0,r6 and short and -.6 or 0,0))
   end
  end
 end
 if player:GetAttribute("EquippedWings") and torso then
  for _, side in {-1,1} do for i=1,7 do
   local offset=CFrame.new(side*(.65+i*.39),.1+i*.25,1.05+i*.04)*CFrame.Angles(0,0,math.rad(-side*(12+i*6)))
   piece("WingsFeather",torso,Vector3.new(.57,2.3+i*.17,.24),offset,Color3.fromRGB(225,230,245))
   local glow=piece("WingsGlow",torso,Vector3.new(.1,(2.3+i*.17)*.82,.09),offset*CFrame.new(0,0,.15),Color3.fromRGB(160,215,255)); glow.Material=Enum.Material.Neon
  end end
 end
 local backpack=player:FindFirstChildOfClass("Backpack"); if not backpack then return end
 local tool=c:FindFirstChild("MUBloxSword") or backpack:FindFirstChild("MUBloxSword")
 if not player:GetAttribute("EquippedSword") then if tool then tool:Destroy() end; return end
 if tool then h:EquipTool(tool); return end
 tool=Instance.new("Tool"); tool.Name="MUBloxSword"; tool.CanBeDropped=false
 local handle=part(tool,"Handle",Vector3.new(.35,1.3,.35),CFrame.new(),wood,Enum.Material.Wood)
 handle.Anchored=false; handle.Massless=true; handle.CanCollide=false; handle.CanTouch=false; handle.CanQuery=false
 for _, data in {{"Guarda",Vector3.new(1.7,.25,.5),.65,gold},{"Lamina",Vector3.new(.65,3.4,.18),2.4,Color3.fromRGB(195,210,225)}} do
  local p=part(tool,data[1],data[2],handle.CFrame*CFrame.new(0,data[3],0),data[4],Enum.Material.Metal)
  p.Anchored=false; p.Massless=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
  local w=Instance.new("WeldConstraint"); w.Part0=handle; w.Part1=p; w.Parent=p
 end
 tool.Parent=backpack; h:EquipTool(tool)
end
local function applyClass(player,c)
 local h=c:WaitForChild("Humanoid"); if player.Character~=c then return end
 local class=classes[player:GetAttribute("Class")]; if not class then return end
 h.MaxHealth=class[1]; h.Health=class[1]
 player:SetAttribute("MaxMana",class[2]); player:SetAttribute("Mana",class[2]); refreshEquipment(player)
end
local function setup(player)
 for key,value in {Level=1,Experience=0,Mana=0,MaxMana=0,SpinReadyAt=0} do player:SetAttribute(key,value) end
 for _, slot in slots do player:SetAttribute("Equipped"..slot,slot~="Wings") end
 player.CharacterAdded:Connect(function(c) applyClass(player,c) end)
 player.CharacterAppearanceLoaded:Connect(function() refreshEquipment(player) end)
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
local mob,health,label
local function spawnMob()
 mob=model("GolemDePedra",zone); health=120
 local function body(name,size,offset,color) return part(mob,name,size,CFrame.new(Vector3.new(0,2.4,-235)+offset),color or stone) end
 local torso=body("Corpo",Vector3.new(5,5,3),Vector3.new(0,5,0)); mob.PrimaryPart=torso
 body("Cabeca",Vector3.new(3,2.5,2.8),Vector3.new(0,8.5,0))
 for _, s in {-1,1} do
  body("Braco",Vector3.new(2,4.5,2.5),Vector3.new(s*3.5,5,0))
  body("Perna",Vector3.new(2,3,2.5),Vector3.new(s*1.4,1.5,0))
  body("Olho",Vector3.new(.5,.4,.15),Vector3.new(s*.65,8.7,1.45),gold).Material=Enum.Material.Neon
 end
 local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(220,55); gui.StudsOffset=Vector3.new(0,6,0); gui.MaxDistance=100; gui.Parent=torso
 label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.TextColor3=gold; label.TextStrokeTransparency=.3; label.TextSize=16; label.Parent=gui
 label.Text="GOLEM DE PEDRA\n120 / 120 · 50 XP"
end
spawnMob()
local cooldowns={}; local requests={}
local function sight(origin,target,exclude,expected)
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={exclude}
 local hit=workspace:Raycast(origin,target-origin,params)
 return not hit or hit.Instance:IsDescendantOf(expected)
end
R.OnServerEvent:Connect(function(player,action,value)
 if typeof(action)~="string" then return end
 local now=workspace:GetServerTimeNow()
 if now-(requests[player] or -math.huge)<.08 then return end; requests[player]=now
 if action=="Class" then
  if typeof(value)~="string" or not classes[value] or player:GetAttribute("Class") then return end
  player:SetAttribute("Class",value); if player.Character then applyClass(player,player.Character) end; return
 end
 if not player:GetAttribute("Class") then return end
 if action=="Equip" then
  if typeof(value)~="string" or not allowed[value] then return end
  player:SetAttribute("Equipped"..value,not player:GetAttribute("Equipped"..value)); refreshEquipment(player); return
 end
 if action~="Basic" and action~="Spin" then return end
 local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); local root=c and c:FindFirstChild("HumanoidRootPart")
 if not h or h.Health<=0 or not root or not mob or value~=mob then return end
 if not c:FindFirstChild("MUBloxSword") then R:FireClient(player,"Equipe a espada"); return end
 local spin=action=="Spin"
 if spin and player:GetAttribute("Class")~="Guerreiro" then R:FireClient(player,"Skill exclusiva do Guerreiro"); return end
 local times=cooldowns[player] or {}; cooldowns[player]=times
 if now<(times[action] or 0) or now<(times.Lock or 0) then return end
 if (root.Position-mob.PrimaryPart.Position).Magnitude>(spin and 14 or 10) then R:FireClient(player,"Aproxime-se do golem"); return end
 if not sight(root.Position,mob.PrimaryPart.Position,c,mob) then return end
 local mana=player:GetAttribute("Mana") or 0
 if spin and mana<20 then R:FireClient(player,"Mana insuficiente"); return end
 times[action]=now+(spin and 3 or .6); times.Lock=now+(spin and .65 or .32)
 if spin then player:SetAttribute("Mana",mana-20); player:SetAttribute("SpinReadyAt",now+3) end
 player:SetAttribute("MUBloxAttackKind",action); player:SetAttribute("MUBloxAttackTime",now)
 health=math.max(0,health-(spin and 45 or 15)); label.Text="GOLEM DE PEDRA\n"..health.." / 120 · 50 XP"
 R:FireClient(player,spin and "Golpe Giratório!" or "Acerto!")
 if health==0 then
  mob:Destroy(); mob=nil
  local xp=(player:GetAttribute("Experience") or 0)+50
  local level=player:GetAttribute("Level") or 1
  if xp>=100 then xp-=100; level+=1 end
  player:SetAttribute("Experience",xp); player:SetAttribute("Level",level)
  R:FireClient(player,"+50 XP · Nível "..level); task.delay(5,spawnMob)
 end
end)
Players.PlayerRemoving:Connect(function(p) cooldowns[p]=nil; requests[p]=nil end)
task.spawn(function() while true do task.wait(1)
 for _, p in Players:GetPlayers() do
  local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  if h and h.Health>0 then p:SetAttribute("Mana",math.min(p:GetAttribute("MaxMana") or 0,(p:GetAttribute("Mana") or 0)+5)) end
 end
end end)
task.spawn(function() while true do task.wait(1.8)
 if not mob then continue end
 local enemy=mob; local enemyBody=enemy.PrimaryPart; local target; local distance=11
 for _, p in Players:GetPlayers() do
  local c=p.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); local r=c and c:FindFirstChild("HumanoidRootPart")
  if h and r and h.Health>0 and p:GetAttribute("Class") then
   local d=(r.Position-enemyBody.Position).Magnitude
   if d<distance then target={c,h,r}; distance=d end
  end
 end
 if target then
  enemyBody.Color=Color3.fromRGB(210,90,55); task.wait(.45)
  if enemy.Parent then
   enemyBody.Color=stone
   if target[3].Parent and target[2].Health>0 and (target[3].Position-enemyBody.Position).Magnitude<12 and sight(enemyBody.Position,target[3].Position,enemy,target[1]) then target[2]:TakeDamage(12) end
  end
 end
end end)
