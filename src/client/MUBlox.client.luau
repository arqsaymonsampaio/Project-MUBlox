-- MUBlox AnimationConstraint V1
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local Run=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local R=game:GetService("ReplicatedStorage"):WaitForChild("MUBloxAction")
local mouse=player:GetMouse()
local gold=Color3.fromRGB(205,170,85)
local slots={"Helmet","Armor","Gloves","Pants","Boots","Sword","Wings"}
local names={Helmet="Elmo",Armor="Armadura",Gloves="Luvas",Pants="Calças",Boots="Botas",Sword="Espada",Wings="Asas"}
local symbols={Helmet="H",Armor="A",Gloves="G",Pants="P",Boots="B",Sword="S",Wings="W"}
local function make(kind,props,parent)
 local o=Instance.new(kind); for k,v in pairs(props) do o[k]=v end; o.Parent=parent; return o
end
local gui=make("ScreenGui",{Name="MUBloxUI",ResetOnSpawn=false,DisplayOrder=20},player:WaitForChild("PlayerGui"))
local function text(parent,value,size,pos,fontSize)
 return make("TextLabel",{Text=value,Size=size,Position=pos,BackgroundTransparency=1,TextColor3=Color3.fromRGB(240,225,195),Font=Enum.Font.GothamBold,TextSize=fontSize or 13,TextWrapped=true},parent)
end
local function button(parent,value,size,pos)
 local b=make("TextButton",{Text=value,Size=size,Position=pos,BackgroundColor3=Color3.fromRGB(30,32,38),TextColor3=gold,Font=Enum.Font.GothamBold,TextSize=12},parent)
 make("UIStroke",{Color=Color3.fromRGB(105,100,85),Thickness=1},b); return b
end
local hud=make("Frame",{Size=UDim2.fromOffset(600,100),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-18),BackgroundTransparency=1},gui)
local hudScale=make("UIScale",{},hud)
local function crystal(x,color,title)
 local shell=make("Frame",{Size=UDim2.fromOffset(50,50),Position=UDim2.fromOffset(x,12),Rotation=45,BackgroundColor3=Color3.fromRGB(20,25,40),BorderSizePixel=0,ClipsDescendants=true},hud)
 make("UIStroke",{Color=gold,Thickness=3},shell)
 local fill=make("Frame",{Size=UDim2.fromScale(1,1),AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),BackgroundColor3=color,BorderSizePixel=0},shell)
 make("UIGradient",{Color=ColorSequence.new(color,Color3.fromRGB(30,15,45)),Rotation=90},fill)
 local label=text(hud,title,UDim2.fromOffset(125,24),UDim2.fromOffset(x-37,70),12)
 return function(value,max)
  fill.Size=UDim2.fromScale(1,max>0 and math.clamp(value/max,0,1) or 0)
  label.Text=string.format("%s %d/%d",title,math.floor(value),math.floor(max))
 end
end
local setHealth=crystal(30,Color3.fromRGB(230,35,65),"VIDA")
local setMana=crystal(520,Color3.fromRGB(35,140,255),"MANA")
local skill
for i=1,6 do
 local b=button(hud,tostring(i).." · —",UDim2.fromOffset(52,42),UDim2.fromOffset(125+(i-1)*59,15))
 if i==1 then skill=b end
end
local track=make("Frame",{Size=UDim2.fromOffset(347,7),Position=UDim2.fromOffset(125,68),BackgroundColor3=Color3.fromRGB(45,45,55),BorderSizePixel=0},hud)
local xpFill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=gold,BorderSizePixel=0},track)
local level=text(hud,"",UDim2.fromOffset(347,22),UDim2.fromOffset(125,79),12)
local notice=text(gui,"",UDim2.new(.7,0,0,45),UDim2.new(.5,0,0,12),16); notice.AnchorPoint=Vector2.new(.5,0)
local noticeId=0
local function notify(value)
 noticeId+=1; local id=noticeId; notice.Text=value
 task.delay(2.5,function() if id==noticeId then notice.Text="" end end)
end
local damageSequence=0
local function showDamage(position,amount,spin)
 local camera=workspace.CurrentCamera
 if not camera or (camera.CFrame.Position-position).Magnitude>150 then return end
 damageSequence+=1
 -- O marcador é independente do monstro, para sobreviver ao golpe final.
 local marker=make("Part",{Name="DamageMarker",Size=Vector3.new(.1,.1,.1),
  Position=position,Transparency=1,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false},workspace)
 local offset=Vector3.new(((damageSequence%3)-1)*.6,5,0)
 local billboard=make("BillboardGui",{Size=UDim2.fromOffset(130,60),Adornee=marker,
  StudsOffsetWorldSpace=offset,AlwaysOnTop=true,MaxDistance=150},marker)
 local number=text(billboard,tostring(amount),UDim2.fromScale(1,1),UDim2.new(),spin and 32 or 26)
 number.TextColor3=spin and Color3.fromRGB(255,190,65) or Color3.fromRGB(255,245,215)
 number.TextStrokeTransparency=.25
 TweenService:Create(billboard,TweenInfo.new(.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
  StudsOffsetWorldSpace=offset+Vector3.new(0,3,0)}):Play()
 TweenService:Create(number,TweenInfo.new(.55,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,.3),{
  TextTransparency=1,TextStrokeTransparency=1}):Play()
 Debris:AddItem(marker,1)
end
R.OnClientEvent:Connect(function(event,...)
 if event=="Damage" then showDamage(...) else notify(event) end
end)
skill.Activated:Connect(function()
 if player:GetAttribute("Class")=="Guerreiro" then R:FireServer("Spin") end
end)
-- Inventário: lateral direita; o centro permanece livre.
local toggle=button(gui,"INVENTÁRIO · I",UDim2.fromOffset(165,36),UDim2.new(1,-181,0,65))
local panel=make("Frame",{Name="EquipmentPanel",Size=UDim2.fromOffset(290,520),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-16,0,110),BackgroundColor3=Color3.fromRGB(19,20,22),Visible=false,Active=true},gui)
make("UIStroke",{Color=gold,Thickness=2},panel)
local panelScale=make("UIScale",{},panel)
text(panel,"I N V E N T Á R I O",UDim2.fromOffset(245,40),UDim2.new(),14)
local close=button(panel,"×",UDim2.fromOffset(30,30),UDim2.fromOffset(252,5)); close.Activated:Connect(function() panel.Visible=false end)
local layout={Helmet={111,65,68,54},Armor={111,125,68,70},Sword={20,65,78,130},Gloves={20,202,78,55},Pants={111,202,68,55},Boots={192,202,78,55},Wings={192,65,78,130}}
local topButtons={}; local bagButtons={}
for _, slot in slots do
 local d=layout[slot]; local b=button(panel,"",UDim2.fromOffset(d[3],d[4]),UDim2.fromOffset(d[1],d[2])); topButtons[slot]=b
 b.Activated:Connect(function() if player:GetAttribute("Equipped"..slot) then R:FireServer("Equip",slot) end end)
end
text(panel,"MOCHILA",UDim2.fromOffset(260,20),UDim2.fromOffset(15,268),12)
for i=1,40 do
 local b=button(panel,"",UDim2.fromOffset(30,30),UDim2.fromOffset(18+((i-1)%8)*32,294+math.floor((i-1)/8)*32))
 local slot=slots[i]
 if slot then bagButtons[slot]=b; b.Activated:Connect(function() if player:GetAttribute("Equipped"..slot)==false then R:FireServer("Equip",slot) end end) else b.AutoButtonColor=false end
end
text(panel,"Clique na peça para equipar ou retirar.\nItens cosméticos · Progresso desta sessão",UDim2.fromOffset(260,50),UDim2.fromOffset(15,460),11)
local function toggleInventory() if player:GetAttribute("Class") then panel.Visible=not panel.Visible end end
toggle.Activated:Connect(toggleInventory)
CAS:BindActionAtPriority("MUBloxToggleInventory",function(_,state)
 if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin then toggleInventory() end
 return Enum.ContextActionResult.Sink
end,false,10000,Enum.KeyCode.I)
local chooser=make("Frame",{Size=UDim2.fromOffset(280,235),Position=UDim2.fromScale(.5,.4),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(20,24,38)},gui)
text(chooser,"MUBlox · Escolha sua classe",UDim2.new(1,0,0,45),UDim2.new(),15)
for i,name in {"Guerreiro","Mago","Elfa"} do
 local b=button(chooser,name,UDim2.fromOffset(240,45),UDim2.fromOffset(20,50+(i-1)*58))
 b.Activated:Connect(function() R:FireServer("Class",name) end)
end
local function refresh()
 local class=player:GetAttribute("Class"); toggle.Visible=class~=nil; chooser.Visible=class==nil
 if not class then panel.Visible=false end
 setMana(player:GetAttribute("Mana") or 0,player:GetAttribute("MaxMana") or 0)
 local xp=player:GetAttribute("Experience") or 0; xpFill.Size=UDim2.fromScale(math.clamp(xp/100,0,1),1)
 level.Text=string.format("NÍVEL %d · EXP %d/100",player:GetAttribute("Level") or 1,xp)
 for _, slot in slots do
  local on=player:GetAttribute("Equipped"..slot)==true
  topButtons[slot].Text=(on and symbols[slot] or "—").."\n"..names[slot]
  topButtons[slot].BackgroundColor3=on and Color3.fromRGB(50,44,34) or Color3.fromRGB(25,27,30)
  bagButtons[slot].Text=on and "" or symbols[slot]
 end
end
player.AttributeChanged:Connect(refresh); refresh()
local healthConnections={}
local function bindHealth(c)
 for _, connection in healthConnections do connection:Disconnect() end; healthConnections={}
 local h=c:WaitForChild("Humanoid"); if player.Character~=c then return end
 local function update() setHealth(h.Health,h.MaxHealth) end
 table.insert(healthConnections,h.HealthChanged:Connect(update)); table.insert(healthConnections,h:GetPropertyChangedSignal("MaxHealth"):Connect(update)); update()
end
player.CharacterAdded:Connect(bindHealth); if player.Character then task.spawn(bindHealth,player.Character) end
UIS.InputBegan:Connect(function(input,processed)
 if processed or UIS:GetFocusedTextBox() or not player:GetAttribute("Class") then return end
 -- Cliques dentro do inventário pertencem à interface; fora dele, ao mundo.
 if panel.Visible then
  local pointer=UIS:GetMouseLocation()-game:GetService("GuiService"):GetGuiInset()
  local origin,size=panel.AbsolutePosition,panel.AbsoluteSize
  if pointer.X>=origin.X and pointer.X<=origin.X+size.X
   and pointer.Y>=origin.Y and pointer.Y<=origin.Y+size.Y then return end
 end
 local action=input.UserInputType==Enum.UserInputType.MouseButton1 and "Basic" or input.UserInputType==Enum.UserInputType.MouseButton2 and "Spin" or nil
 if not action then return end
 if action=="Spin" then R:FireServer("Spin"); return end
 local target=mouse.Target
 while target and target~=workspace do
  if target:IsA("Model") and target.Name=="GolemDePedra" then R:FireServer(action,target); return end
  target=target.Parent
 end
end)
task.spawn(function() for _=1,10 do
 local ok=pcall(function()
  game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
  game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health,false)
 end)
 if ok then break end; task.wait(.5)
end end)
-- Controlador único de animação: corpo, asas, braço e rastro.
local states={}
local function updateFootsteps(state,character,flying)
 state.footsteps=state.footsteps or {}
 for sound,volume in pairs(state.footsteps) do
  if not sound.Parent then state.footsteps[sound]=nil
  elseif flying then sound.Volume=0
  else sound.Volume=volume; state.footsteps[sound]=nil end
 end
 if not flying then return end
 -- Compatível com os sons clássicos e os AudioPlayers do Roblox.
 local soundRoot=character:FindFirstChild("HumanoidRootPart")
 if soundRoot then
  for _, sound in soundRoot:GetDescendants() do
   if sound.Name=="Running" and (sound:IsA("Sound") or sound:IsA("AudioPlayer")) then
    if state.footsteps[sound]==nil then state.footsteps[sound]=sound.Volume end
    sound.Volume=0
   end
  end
 end
end
local jointsWanted={Root=true,RootJoint=true,LeftHip=true,RightHip=true,LeftKnee=true,RightKnee=true,LeftShoulder=true,RightShoulder=true,RightElbow=true,LeftElbow=true,["Left Hip"]=true,["Right Hip"]=true,["Left Shoulder"]=true,["Right Shoulder"]=true}
Players.PlayerRemoving:Connect(function(p) states[p]=nil end)
local function setupWings(armor)
 local result={}; if not armor then return result end
 for _, p in armor:GetChildren() do
  if not p:IsA("BasePart") or not string.match(p.Name,"^Wings") then continue end
  local weld=p:FindFirstChildOfClass("WeldConstraint"); if not weld or not weld.Part0 then continue end
  local rest=weld.Part0.CFrame:ToObjectSpace(p.CFrame)
  local joint=Instance.new("Motor6D"); joint.Part0=weld.Part0; joint.Part1=p; joint.C0=rest
  weld.Enabled=false; joint.Parent=p
  table.insert(result,{joint=joint,rest=rest,side=rest.Position.X<0 and -1 or 1})
 end; return result
end
local function setupTrail(tool)
 local h=tool and tool:FindFirstChild("Handle"); if not h then return nil end
 local existing=h:FindFirstChild("BladeTrail"); if existing then return existing end
 local a=make("Attachment",{Position=Vector3.new(0,.9,0)},h)
 local b=make("Attachment",{Position=Vector3.new(0,4.1,0)},h)
 return make("Trail",{Name="BladeTrail",Attachment0=a,Attachment1=b,Lifetime=.16,MinLength=.05,FaceCamera=true,LightEmission=1,Enabled=false,Color=ColorSequence.new(Color3.fromRGB(255,245,185),Color3.fromRGB(255,140,40)),Transparency=NumberSequence.new(.25,1)},h)
end
Run.PreSimulation:Connect(function(dt)
 local now=workspace:GetServerTimeNow(); local smoothing=1-math.exp(-18*dt)
 for _, p in Players:GetPlayers() do
  local c=p.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); if not h then continue end
  local state=states[p]
  if not state or state.character~=c then state={character=c,joints={},wings={},nextScan=0,custom=false}; states[p]=state end
  if now>=state.nextScan then
   state.nextScan=now+.15
   for _, j in c:GetDescendants() do if (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) and jointsWanted[j.Name] and not state.joints[j] then state.joints[j] = j:IsA("AnimationConstraint") and j.Attachment0.CFrame or j.C0 end end
   local armor=c:FindFirstChild("MUBloxArmor")
   if armor~=state.armor then state.armor=armor; state.wings=setupWings(armor) end
   local tool=c:FindFirstChild("MUBloxSword")
   if tool~=state.tool then state.tool=tool; state.trail=setupTrail(tool) end
  end
  local flying=h.Health>0 and p:GetAttribute("EquippedWings")==true
  updateFootsteps(state,c,flying)
  -- A velocidade horizontal também funciona para os outros jogadores.
  -- Ignorar o eixo vertical evita inclinar o corpo ao subir ou cair.
  local characterRoot=c:FindFirstChild("HumanoidRootPart")
  local velocity=characterRoot and characterRoot.AssemblyLinearVelocity or Vector3.zero
  local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
  local moveTarget=flying and speed>.5 and math.clamp(speed/math.max(h.WalkSpeed*.8,1),0,1) or 0
  local moveBlend=state.flightMoveBlend or 0
  state.flightMoveBlend=flying and (moveBlend+(moveTarget-moveBlend)*(1-math.exp(-8*dt))) or 0
  local kind=p:GetAttribute("MUBloxAttackKind"); local time=p:GetAttribute("MUBloxAttackTime")
  local elapsed=time and now-time or math.huge; local duration=kind=="Spin" and .65 or .32
  local attacking=h.Health>0 and elapsed>=0 and elapsed<duration
  local custom=flying or attacking
  if state.trail then state.trail.Enabled=attacking end
  for _, wing in state.wings do if wing.joint.Parent then
   local flap=flying and math.sin(now*3.2-math.abs(wing.rest.Position.X)*.14)*math.rad(19) or 0
   local pivot=CFrame.new(wing.side*.4,.35,.85)
   wing.joint.C0=pivot*CFrame.Angles(0,wing.side*flap,0)*pivot:Inverse()*wing.rest
  end end
  if custom and not state.custom then
   state.animate=c:FindFirstChild("Animate"); if state.animate then state.disabled=state.animate.Disabled; state.animate.Disabled=true end
   local animator=h:FindFirstChildOfClass("Animator"); if animator then for _, t in animator:GetPlayingAnimationTracks() do t:Stop(.08) end end
  elseif not custom and state.custom then
   for j,base in pairs(state.joints) do if j.Parent then if j:IsA("AnimationConstraint") then
 j.Transform = CFrame.identity
 if state.bodyPose then state.bodyPose[j] = nil end
else
 j.C0 = base
end
; j.Transform=CFrame.identity end end
   if state.animate and state.animate.Parent then state.animate.Disabled=state.disabled end
  end
  state.custom=custom; if not custom then continue end
  local progress=attacking and math.clamp(elapsed/duration,0,1) or 0; local pulse=math.sin(progress*math.pi)
  for j,base in pairs(state.joints) do
   if not j.Parent then continue end
   local n = j.Name
local x, y, z, bob = 0, 0, 0, 0
local parentPart = j:IsA("AnimationConstraint")
 and j.Attachment0.Parent or j.Part0
local root = parentPart == c:FindFirstChild("HumanoidRootPart")
local breath = math.sin(now * 2.8)
if root then
 if flying then
  local movement = state.flightMoveBlend or 0
  x = -3 - 17 * movement + breath * (1 + movement)
  bob = breath * .16
 end
 if attacking then
  y = kind == "Spin"
   and progress * progress * (3 - 2 * progress) * 360
   or -30 * pulse
 end
elseif n == "RightHip" or n == "Right Hip" then
 x = flying and -12 or 0
 z = flying and 5 or 0
elseif n == "RightKnee" then
 x = flying and (-50 + breath * 3) or 0
elseif n == "LeftHip" or n == "Left Hip" then
 x = flying and 12 or 0
 z = flying and -4 or 0
elseif n == "LeftKnee" then
 x = flying and -8 or 0
elseif n == "RightShoulder" or n == "Right Shoulder" then
 x = flying and -15 or 0
 z = flying and 20 or 0
 if attacking then
  x = kind == "Spin" and -25 * pulse
   or -100 * math.sin(progress * math.pi * 2)
  z = kind == "Spin" and 85 * pulse or 25 * pulse
 end
elseif n == "LeftShoulder" or n == "Left Shoulder" then
 x = flying and -10 or 0
 z = flying and -22 or 0
elseif n == "RightElbow" then
 x = flying and -15 or 0
elseif n == "LeftElbow" then
 x = flying and -25 or 0
end
local motion=CFrame.new(0,bob,0)*CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))
   local goal=base*base.Rotation:Inverse()*motion*base.Rotation
   if j:IsA("AnimationConstraint") then
 state.bodyPose = state.bodyPose or {}
 local target = base:Inverse() * goal
 local previous = state.bodyPose[j] or CFrame.identity
 local pose = root and target or previous:Lerp(target, smoothing)
 state.bodyPose[j] = pose
 j.Transform = pose
else
 j.Transform = CFrame.identity
 j.C0 = root and goal or j.C0:Lerp(goal, smoothing)
end

  end
 end
end)
Run.RenderStepped:Connect(function()
 local camera=workspace.CurrentCamera; if camera then
  local v=camera.ViewportSize; hudScale.Scale=math.min(1,v.X/700)
  panelScale.Scale=math.min(1,math.max(.2,(v.Y-155)/520),math.max(.2,(v.X-32)/290))
 end
 local remaining=math.max(0,(player:GetAttribute("SpinReadyAt") or 0)-workspace:GetServerTimeNow())
 if player:GetAttribute("Class")~="Guerreiro" then skill.Text="1 · —"
 elseif not player:GetAttribute("EquippedSword") then skill.Text="GIRO\nSem arma"
 elseif remaining>0 then skill.Text=string.format("GIRO\n%.1fs",remaining)
 elseif (player:GetAttribute("Mana") or 0)<20 then skill.Text="GIRO\nSem mana"
 else skill.Text="GIRO\nDireito" end
end)

