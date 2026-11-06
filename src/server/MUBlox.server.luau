
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
local mob,health,mobAI
local arenaCenter=Vector3.new(0,7.4,-235)
local patrolPoints={Vector3.new(-16,7.4,-247),Vector3.new(16,7.4,-247),Vector3.new(16,7.4,-223),Vector3.new(-16,7.4,-223)}
local function spawnMob()
 mob=model("GolemDePedra",zone); health=120
 mob:SetAttribute("Health",health); mob:SetAttribute("MaxHealth",120)
 local torso=part(mob,"Corpo",Vector3.new(5,5,3),CFrame.new(arenaCenter),stone)
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
 mobAI={position=arenaCenter,forward=Vector3.new(0,0,-1),goal=1,joints=joints,phase=0,nextAttack=0}
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
 if not h or h.Health<=0 or not root then return end
 if not c:FindFirstChild("MUBloxSword") then R:FireClient(player,"Equipe a espada"); return end
 local spin=action=="Spin"
 if spin and player:GetAttribute("Class")~="Guerreiro" then R:FireClient(player,"Skill exclusiva do Guerreiro"); return end
 local times=cooldowns[player] or {}; cooldowns[player]=times
 if now<(times[action] or 0) or now<(times.Lock or 0) then return end
 -- O ataque básico exige o alvo clicado. O Giro consulta o alcance no servidor.
 local hitMob=nil
 if spin then
  if mob and health>0 and (root.Position-mob.PrimaryPart.Position).Magnitude<=14
   and sight(root.Position,mob.PrimaryPart.Position,c,mob) then hitMob=mob end
 else
  if not mob or value~=mob or health<=0 then return end
  if (root.Position-mob.PrimaryPart.Position).Magnitude>10 then R:FireClient(player,"Aproxime-se do golem"); return end
  if not sight(root.Position,mob.PrimaryPart.Position,c,mob) then return end
  hitMob=mob
 end
 local mana=player:GetAttribute("Mana") or 0
 if spin and mana<20 then R:FireClient(player,"Mana insuficiente"); return end
 times[action]=now+(spin and 3 or .6); times.Lock=now+(spin and .65 or .32)
 if spin then player:SetAttribute("Mana",mana-20); player:SetAttribute("SpinReadyAt",now+3) end
 player:SetAttribute("MUBloxAttackKind",action); player:SetAttribute("MUBloxAttackTime",now)
 R:FireClient(player,spin and "Golpe Giratório!" or "Acerto!")
 if not hitMob then return end
 local damage=math.min(health,spin and 45 or 15)
 local hitPosition=hitMob.PrimaryPart.Position
 health-=damage; hitMob:SetAttribute("Health",health)
 R:FireAllClients("Damage",hitPosition,damage,spin)
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
local elapsedAI=0
game:GetService("RunService").Heartbeat:Connect(function(dt)
 elapsedAI+=dt
 if elapsedAI<.05 then return end
 local step=math.min(elapsedAI,.1); elapsedAI=0
 if not mob or not mob.Parent or health<=0 then return end
 local ai=mobAI
 local torso=mob.PrimaryPart
 local now=workspace:GetServerTimeNow()
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
end)
