-- Execute na Barra de Comandos do Studio DURANTE o Play, depois de escolher Guerreiro.
-- Somente leitura: imprime medidas e encaixes; nao modifica o personagem.
local player=game:GetService("Players"):GetPlayers()[1]
local c=player and player.Character
assert(c,"Inicie o Play e escolha Guerreiro antes de executar.")
local visual=c:FindFirstChild("MUBloxStarterVisual")
assert(visual,"O visual inicial ainda nao foi aplicado.")
local function fmt(v) return string.format("%.3f,%.3f,%.3f",v.X,v.Y,v.Z) end
print("=== MUBLOX DIAGNOSTICO BRACOS | visual V"..tostring(visual:GetAttribute("VisualRevision")).." ===")
local models=0
for _,child in c:GetChildren() do if child.Name=="MUBloxStarterVisual" then models+=1 end end
print("Modelos de visual:",models,"| contexto:",game:GetService("RunService"):IsClient() and "Cliente" or "Servidor")
for _,side in {"Left","Right"} do
 for _,segment in {"UpperArm","LowerArm","Hand"} do
  local name=side..segment
  local b=c:FindFirstChild(name)
  if not b then print("AUSENTE",name); continue end
  local joints={}
  for _,joint in {"Shoulder","Elbow","Wrist"} do
   local a=b:FindFirstChild(side..joint.."RigAttachment")
   if a then table.insert(joints,joint.."="..fmt(a.Position)) end
  end
  print(name.." | size="..fmt(b.Size).." | invis="..b.Transparency.." | "..table.concat(joints,"; "))
  for _,v in visual:GetChildren() do
   if v:IsA("BasePart") and v:GetAttribute("BodyPart")==name then
    local localCF=b.CFrame:ToObjectSpace(v.CFrame)
    local x,y,z=localCF:ToOrientation()
    print("  "..v.Name.." | size="..fmt(v.Size).." | pos="..fmt(localCF.Position).." | rot="..fmt(Vector3.new(math.deg(x),math.deg(y),math.deg(z))))
   end
  end
 end
end
local template=game:GetService("ServerStorage"):FindFirstChild("MUBloxWarriorVisual")
if template then
 for _,name in {"Bind_LeftUpperArm","Bind_LeftLowerArm","Bind_LeftHand"} do
  local b=template:FindFirstChild(name,true)
  if b and b:IsA("BasePart") then print("TEMPLATE "..name.." | size="..fmt(b.Size)) end
 end
end
print("=== FIM DO DIAGNOSTICO ===")
