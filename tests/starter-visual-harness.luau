-- Minimal rigid vector/frame math to exercise the actual import validator.
local V={}
local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},V) end
V.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V.__sub=function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
V.__mul=function(a,b) if type(b)=="number" then return vec(a.X*b,a.Y*b,a.Z*b) end return vec(a.X*b.X,a.Y*b.Y,a.Z*b.Z) end
V.__div=function(a,b) return a*(1/b) end
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
