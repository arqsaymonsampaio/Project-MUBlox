-- Usa o bloco real de combate; apenas serviços e instâncias Roblox são simulados.
local function scenario(options)
 options=options or {}
 local mt={}
 local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},mt) end
 mt.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
 mt.__sub=function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
 mt.__mul=function(a,b) return vec(a.X*b,a.Y*b,a.Z*b) end
 mt.__index=function(a,k)
  local m=math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z)
  if k=="Magnitude" then return m end
  if k=="Unit" then return vec(a.X/m,a.Y/m,a.Z/m) end
  if k=="Dot" then return function(_,b) return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
 end
 local Vector3={new=vec}
 local now=100
 local attrs={Class=options.class or "Guerreiro",Mana=options.mana or 100,Level=1,Experience=0}
 local humanoid={Health=options.dead and 0 or 150}
 local root={Position=vec(0,0,0),CFrame={LookVector=vec(0,0,-1)}}
 local weapon={GetAttribute=function() return options.wrongWeapon and "Invalid" or attrs.Class end,FindFirstChild=function() return nil end}
 local character={}
 function character:FindFirstChildOfClass() return humanoid end
 function character:FindFirstChild(name)
  if name=="HumanoidRootPart" then return root end
  if name=="MUBloxWeapon" and not options.unarmed then return weapon end
 end
 local player={Character=character,Parent=true}
 function player:GetAttribute(key) return attrs[key] end
 function player:SetAttribute(key,value) attrs[key]=value end
 local enemies,initial={},{}
 for i,coords in options.targets or {{0,0,-5}} do
  local enemy={Parent=true,PrimaryPart={Position=vec(table.unpack(coords))},index=i}
  function enemy:Destroy() self.Parent=nil end
  function enemy:SetAttribute(key,value) self[key]=value end
  enemies[enemy]={health=options.health or 120,slot=i}
  table.insert(initial,enemy)
 end
 local cooldowns,requests={},{}
 local classes={Guerreiro=true,Mago=true,Elfa=true}
 local allowed={}
 local function refreshEquipment() end
 local function applyClass() end
 local function sight(_,_,_,enemy) return not options.blocked and not (options.blockedIndex==enemy.index) end
 local respawns=0
 local function spawnMob() respawns+=1 end
 local queue={}
 local task={delay=function(delay,fn) table.insert(queue,{at=now+delay,fn=fn}) end}
 local workspace={GetServerTimeNow=function() return now end}
 local notices,hits,effects={},{},{}
 local callback
 local R={OnServerEvent={Connect=function(_,fn) callback=fn end}}
 function R:FireClient(_,message) table.insert(notices,message) end
 function R:FireAllClients(event,...)
  local args={...}
  if event=="Damage" then table.insert(hits,{damage=args[2],skill=args[3]}) else table.insert(effects,{event=event,args=args}) end
 end
 -- CALLBACK_PLACEHOLDER
 local function tick(dt)
  now+=dt
  local due={}
  for i=#queue,1,-1 do if queue[i].at<=now then table.insert(due,table.remove(queue,i)) end end
  for _, job in due do job.fn() end
 end
 return {
  cast=function(action,target,advance)
   tick(advance or 0)
   if type(target)=="number" then target=initial[target]
   elseif type(target)=="table" then
    local converted={};for _,id in target do table.insert(converted,type(id)=="number" and initial[id] or id) end;target=converted
   end
   callback(player,action,target)
  end,
  tick=tick,
  snapshot=function()
   local hp={};for i,enemy in initial do hp[i]=enemies[enemy] and enemies[enemy].health or 0 end
   return {mana=attrs.Mana,hp=hp,hits=hits,attrs=attrs,respawns=respawns,effects=effects,notices=notices}
  end,
  killPlayer=function() humanoid.Health=0 end,
  moveEnemy=function(i,x,y,z) initial[i].PrimaryPart.Position=vec(x,y,z) end,
 }
end
local passed=0
local function check(name,fn) fn();passed+=1;print("PASS "..name) end
check("basic requires clicked registered target for every class",function()
 for _, class in {"Guerreiro","Mago","Elfa"} do
  local s=scenario({class=class});s.cast("Basic");s.cast("Basic",{},.1);s.tick(1)
  assert(s.snapshot().hp[1]==120)
 end
end)
check("warrior basic and spin remain melee and hit multiple targets",function()
 local s=scenario({targets={{0,0,-5},{5,0,0},{0,0,-20}}})
 s.cast("Basic",1);assert(s.snapshot().hp[1]==105)
 s.cast("Skill",nil,1);local r=s.snapshot()
 assert(r.hp[1]==60 and r.hp[2]==75 and r.hp[3]==120 and r.mana==80)
end)
check("mage orb and elf arrow travel before damage",function()
 for _, data in {{"Mago",18,"Orb"},{"Elfa",16,"Arrow"}} do
  local s=scenario({class=data[1],targets={{0,0,-40}}});s.cast("Basic",1)
  local r=s.snapshot();assert(r.hp[1]==120 and r.effects[1].args[1]==data[3])
  s.tick(1);assert(s.snapshot().hp[1]==120-data[2])
 end
end)
check("ranged basics reject too far and obstructed targets",function()
 for _, config in {{class="Mago",targets={{0,0,-61}}},{class="Elfa",targets={{0,0,-56}}},{class="Mago",blocked=true}} do
  local s=scenario(config);s.cast("Basic",1);s.tick(1);assert(s.snapshot().hp[1]==120 and #s.snapshot().effects==0)
 end
end)
check("spirits hit visible list once and exclude omitted targets",function()
 local s=scenario({class="Mago",targets={{0,0,-20},{10,0,-30},{0,0,20}}})
 s.cast("Skill",{1,1,2});s.tick(1);local r=s.snapshot()
 assert(r.hp[1]==85 and r.hp[2]==85 and r.hp[3]==120 and #r.hits==2 and r.mana==70)
end)
check("spirits reject fake, distant and obstructed targets",function()
 local s=scenario({class="Mago",targets={{0,0,-66},{0,0,-20}},blockedIndex=2})
 s.cast("Skill",{1,2,{}});s.tick(1);assert(#s.snapshot().hits==0)
end)
check("multishot hits frontal cone only",function()
 local s=scenario({class="Elfa",targets={{0,0,-20},{10,0,-20},{30,0,-10},{0,0,20},{0,0,-56}}})
 s.cast("Skill");s.tick(1);local r=s.snapshot()
 assert(r.hp[1]==88 and r.hp[2]==88 and r.hp[3]==120 and r.hp[4]==120 and r.hp[5]==120)
 assert(r.mana==75 and #r.hits==2)
end)
check("empty skills consume mana with cooldown",function()
 for _, data in {{"Guerreiro",20,3},{"Mago",30,4},{"Elfa",25,3}} do
  local s=scenario({class=data[1],targets={}});s.cast("Skill");s.cast("Skill",nil,.1)
  assert(s.snapshot().mana==100-data[2])
  s.cast("Skill",nil,data[3]);assert(s.snapshot().mana==100-data[2]*2)
 end
end)
check("insufficient mana, dead and unequipped cannot cast",function()
 for _, config in {{class="Mago",mana=29},{class="Elfa",mana=24},{unarmed=true},{wrongWeapon=true},{dead=true}} do
  local s=scenario(config);local before=s.snapshot().mana;s.cast("Skill",{1});s.tick(1)
  local r=s.snapshot();assert(r.mana==before and r.hp[1]==120 and not r.attrs.MUBloxAttackTime)
 end
end)
check("projectile cancelled by caster death or target leaving range",function()
 local s=scenario({class="Mago"});s.cast("Basic",1);s.killPlayer();s.tick(1);assert(s.snapshot().hp[1]==120)
 local other=scenario({class="Elfa"});other.cast("Basic",1);other.moveEnemy(1,0,0,-100);other.tick(1);assert(other.snapshot().hp[1]==120)
end)
check("multiple kills award XP and respawn each enemy once",function()
 local s=scenario({class="Mago",health=10,targets={{0,0,-20},{5,0,-20},{-5,0,-20}}})
 s.cast("Skill",{1,1,2,3});s.tick(1);local r=s.snapshot()
 assert(#r.hits==3 and r.hits[1].damage==10 and r.attrs.Level==2 and r.attrs.Experience==50)
 s.tick(5);assert(s.snapshot().respawns==3)
end)
print(passed.." combat scenarios passed")
