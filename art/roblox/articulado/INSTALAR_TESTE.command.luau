-- Execute na Barra de Comandos, com o modelo articulado inteiro selecionado.
assert(not game:GetService("RunService"):IsRunning(), "Pare o Play primeiro.")
local selection = game:GetService("Selection"):Get()
assert(#selection == 1 and selection[1]:IsA("Model"), "Selecione somente o Model inteiro importado.")
local model = selection[1]
assert(model:IsDescendantOf(workspace), "Coloque o modelo no Workspace.")
local bones, count = {}, 0
for _, item in model:GetDescendants() do
    if item:IsA("Bone") then bones[item.Name] = true end
    if item:IsA("MeshPart") then count += 1 end
end
for _, name in {"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "LowerTorso", "UpperTorso", "Head"} do
    assert(bones[name], "Osso ausente: " .. name .. ". Importe o novo FBX articulado preservando o esqueleto.")
end
assert(count >= 7, "Malhas ausentes: confira a importação do FBX.")
assert(not model:FindFirstChild("MUBloxDemonstracao"), "A demonstração já está instalada. Basta dar Play.")
local history = game:GetService("ChangeHistoryService")
local recording = history:TryBeginRecording("MUBloxRigDemo", "Instalar teste articulado")
assert(recording, "Histórico ocupado; tente novamente.")
local success, failure = pcall(function()
    local cf, size = model:GetBoundingBox()
    assert(size.Y > 0, "Modelo sem altura.")
    local feet = cf.Position - Vector3.new(0, size.Y / 2, 0)
    model:ScaleTo(model:GetScale() * 5.5 / size.Y)
    local newCf, newSize = model:GetBoundingBox()
    model:PivotTo(model:GetPivot() + feet - (newCf.Position - Vector3.new(0, newSize.Y / 2, 0)))
    for _, item in model:GetDescendants() do
        if item:IsA("BasePart") then
            item.Anchored = true
            item.CanCollide = false
            item.CanTouch = false
        end
    end
    local demo = Instance.new("Script")
    demo.Name = "MUBloxDemonstracao"
    demo.RunContext = Enum.RunContext.Client
    demo.Source = [==[-- Somente demonstração visual. Script com RunContext=Client dentro do modelo.
local RunService = game:GetService("RunService")
local model = script.Parent
local angles = {LeftLowerArm = -70, RightLowerArm = -70, LeftUpperLeg = -25, LeftLowerLeg = 65}
local bones = {}
local started = os.clock()
local connection
local function register(object)
    if object:IsA("Bone") and angles[object.Name] and not bones[object] then
        bones[object] = {
            base = object.Transform,
            axis = object.WorldCFrame:VectorToObjectSpace(model:GetPivot().RightVector),
            angle = math.rad(angles[object.Name]),
        }
    end
end
for _, object in model:GetDescendants() do register(object) end
local added = model.DescendantAdded:Connect(register)
connection = RunService.PreSimulation:Connect(function()
    local strength = (1 - math.cos((os.clock() - started) * math.pi / 2)) / 2
    for bone, data in pairs(bones) do
        if bone.Parent then
            bone.Transform = data.base * CFrame.fromAxisAngle(data.axis, data.angle * strength)
        else
            bones[bone] = nil
        end
    end
end)
script.Destroying:Connect(function()
    connection:Disconnect()
    added:Disconnect()
    for bone, data in pairs(bones) do
        if bone.Parent then bone.Transform = data.base end
    end
end)
]==]
    demo.Parent = model
    model.Name = "MUBloxTesteArticulado"
end)
history:FinishRecording(recording, success and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
assert(success, failure)
print("Teste instalado. Posicione no mapa e dê Play para conferir cotovelos e joelho.")
