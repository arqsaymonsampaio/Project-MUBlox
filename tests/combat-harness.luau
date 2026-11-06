-- Executado pelo runner com o callback real do servidor inserido abaixo.
local function scenario(options)
 options=options or {}
 local now=100
 local attrs={Class=options.class or "Guerreiro",Mana=options.mana or 60,Level=1,Experience=0}
 local humanoid={Health=options.dead and 0 or 150}
 local function position(x)
  return setmetatable({x=x},{__sub=function(a,b) return {Magnitude=math.abs(a.x-b.x)} end})
 end
 local root={Position=position(0)}
 local character={}
 function character:FindFirstChildOfClass() return humanoid end
 function character:FindFirstChild(name)
  if name=="HumanoidRootPart" then return root end
  if name=="MUBloxSword" and not options.unarmed then return {} end
 end
 local player={Character=character}
 function player:GetAttribute(key) return attrs[key] end
 function player:SetAttribute(key,value) attrs[key]=value end
 local mob={PrimaryPart={Position=position(options.distance or 5)}}
 if options.empty then mob=nil end
 if mob then function mob:Destroy() self.destroyed=true end end
 local initialMob=mob
 local health=options.health or 120
 local label={Text=""}
 local cooldowns,requests={},{}
 local classes={Guerreiro=true,Mago=true,Elfa=true}
 local allowed={}
 local function refreshEquipment() end
 local function applyClass() end
 local function sight() return not options.blocked end
 local function spawnMob() end
 local scheduled=0
 local task={delay=function() scheduled+=1 end}
 local workspace={GetServerTimeNow=function() return now end}
 local notices,hits={},{}
 local callback
 local R={OnServerEvent={Connect=function(_,fn) callback=fn end}}
 function R:FireClient(_,message) table.insert(notices,message) end
 function R:FireAllClients(event,point,damage,spin)
  table.insert(hits,{event=event,position=point,damage=damage,spin=spin})
 end
 -- CALLBACK_PLACEHOLDER
 return {
  cast=function(action,target,advance)
   now+=advance or 0
   callback(player,action,target=="mob" and initialMob or target)
  end,
  snapshot=function() return {mana=attrs.Mana,health=health,hits=hits,attrs=attrs,scheduled=scheduled,mob=mob,notices=notices} end,
 }
end
local passed=0
local function check(name,fn)
 fn(); passed+=1; print("PASS "..name)
end
check("basic requires clicked target",function()
 local s=scenario();s.cast("Basic");assert(s.snapshot().health==120)
 s.cast("Basic",{},.1);assert(s.snapshot().health==120)
 s.cast("Basic","mob",.1);assert(s.snapshot().health==105)
 assert(s.snapshot().hits[1].damage==15)
end)
check("basic rejects distance and obstacles",function()
 for _, config in {{distance=30},{blocked=true}} do
  local s=scenario(config);s.cast("Basic","mob");assert(s.snapshot().health==120)
  assert(#s.snapshot().hits==0)
 end
end)
check("empty spin consumes mana and animates",function()
 local s=scenario({empty=true});s.cast("Spin")
 local r=s.snapshot();assert(r.mana==40 and r.attrs.MUBloxAttackKind=="Spin")
 assert(r.attrs.SpinReadyAt==103 and #r.hits==0)
 s.cast("Spin",nil,.1);assert(s.snapshot().mana==40)
 s.cast("Spin",nil,3);assert(s.snapshot().mana==20)
end)
check("spin hits nearby golem without target",function()
 local s=scenario();s.cast("Spin")
 local r=s.snapshot();assert(r.health==75 and r.mana==40)
 assert(#r.hits==1 and r.hits[1].damage==45 and r.hits[1].spin)
end)
check("spin checks range and line of sight",function()
 for _, config in {{distance=15},{blocked=true}} do
  local s=scenario(config);s.cast("Spin");local r=s.snapshot()
  assert(r.health==120 and r.mana==40 and #r.hits==0)
 end
end)
check("invalid casts cost no mana and cause no damage",function()
 for _, config in {{mana=19},{class="Mago"},{unarmed=true},{dead=true}} do
  local s=scenario(config);local before=s.snapshot().mana;s.cast("Spin")
  local r=s.snapshot();assert(r.mana==before and r.health==120 and not r.attrs.MUBloxAttackTime)
 end
end)
check("finishing hit reports actual damage and awards XP once",function()
 local s=scenario({health=10});s.cast("Spin");local r=s.snapshot()
 assert(r.hits[1].damage==10 and r.health==0 and r.mob==nil)
 assert(r.attrs.Experience==50 and r.scheduled==1)
 s.cast("Basic","mob",1);assert(s.snapshot().attrs.Experience==50)
end)
print(string.format("%d combat scenarios passed",passed))
