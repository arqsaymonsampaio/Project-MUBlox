-- Exercita a IA real com vetores e serviços mínimos, sem simulação física do Studio.
local function scenario(options)
 options=options or {}
 local mt={}
 local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},mt) end
 mt.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
 mt.__sub=function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
 mt.__mul=function(a,s) return vec(a.X*s,a.Y*s,a.Z*s) end
 mt.__index=function(a,k)
  local magnitude=math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z)
  if k=="Magnitude" then return magnitude end
  if k=="Unit" then return vec(a.X/magnitude,a.Y/magnitude,a.Z/magnitude) end
 end
 local Vector3={new=vec}
 local frameMT={__mul=function(a,b) return b end}
 local CFrame={Angles=function(x,y,z) return setmetatable({x=x,y=y,z=z},frameMT) end,
  lookAt=function(a,b) return {position=a,target=b} end}
 local Color3={fromRGB=function(r,g,b) return {r,g,b} end}
 local now=100
 local workspace={GetServerTimeNow=function() return now end}
 local arenaCenter=vec(0,7.4,-235)
 local patrolPoints={vec(-16,7.4,-247),vec(16,7.4,-247),vec(16,7.4,-223),vec(-16,7.4,-223)}
 local stone={}
 local health=120
 local mob={Parent=true,PrimaryPart={}}
 local mobAI={position=arenaCenter,forward=vec(0,0,-1),goal=1,joints={},phase=0,nextAttack=0}
 for _, name in {"ArmLeft","ArmRight","LegLeft","LegRight"} do
  mobAI.joints[name]={joint={},rest=setmetatable({},frameMT)}
 end
 local damage=0
 local h={Health=options.dead and 0 or 100}
 function h:TakeDamage(amount) damage+=amount; self.Health-=amount end
 local root={Position=vec(options.x or 6,7.4,-235),Parent=true}
 local character={FindFirstChildOfClass=function() return h end,FindFirstChild=function() return root end}
 local player={Character=character,GetAttribute=function() return not options.noClass and "Guerreiro" or nil end}
 local Players={GetPlayers=function() return options.empty and {} or {player} end}
 local function sight() return not options.blocked end
 local callback
 local game={GetService=function() return {Heartbeat={Connect=function(_,fn) callback=fn end}} end}
 -- AI_PLACEHOLDER
 return {
  tick=function(dt) now+=dt;callback(dt) end,
  state=function() return {position=mobAI.position,attack=mobAI.attack,damage=damage,joints=mobAI.joints} end,
  movePlayer=function(x) root.Position=vec(x,7.4,-235) end,
  killMob=function() health=0;mob.Parent=nil end,
 }
end
local passed=0
local function test(name,fn) fn();passed+=1;print("PASS "..name) end
test("patrol without a target and animate legs",function()
 local s=scenario({empty=true});s.tick(.1);local r=s.state()
 assert(r.position.X<0 and r.position.Z<-235 and r.joints.LegLeft.joint.C0.x~=0)
 for _=1,2000 do s.tick(.1);r=s.state();assert(math.abs(r.position.X)<=22 and r.position.Z>=-252 and r.position.Z<=-218) end
end)
test("approaching player attracts enemy before attacking it",function()
 local s=scenario({x=20});s.tick(.1);assert(s.state().position.X>0 and not s.state().attack)
end)
test("ignore dead, unselected, obstructed and distant players",function()
 for _, config in {{dead=true},{noClass=true},{blocked=true},{x=55}} do
  local s=scenario(config);s.tick(.1);assert(s.state().position.X<0 and not s.state().attack)
 end
end)
test("attack telegraphs then hits once",function()
 local s=scenario();s.tick(.1);assert(s.state().attack and s.state().damage==0)
 for _=1,3 do s.tick(.1) end
 assert(s.state().damage==0 and s.state().joints.ArmRight.joint.C0.x>0)
 for _=1,4 do s.tick(.1) end
 assert(s.state().damage==12)
end)
test("leaving reach avoids damage",function()
 local s=scenario();s.tick(.1);s.movePlayer(25)
 for _=1,8 do s.tick(.1) end
 assert(s.state().damage==0)
end)
test("death cancels pending hit",function()
 local s=scenario();s.tick(.1);s.killMob()
 for _=1,8 do s.tick(.1) end
 assert(s.state().damage==0)
end)
print(passed.." enemy scenarios passed")
