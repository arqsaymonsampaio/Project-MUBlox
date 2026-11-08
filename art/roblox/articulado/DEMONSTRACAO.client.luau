-- Somente demonstração visual. Script com RunContext=Client dentro do modelo.
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
