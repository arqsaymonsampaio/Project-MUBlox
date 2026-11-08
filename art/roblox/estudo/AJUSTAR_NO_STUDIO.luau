-- Execute na Barra de Comandos, fora do Play, com somente o modelo importado selecionado.
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Pare o Play antes de ajustar o modelo.")
local selected = Selection:Get()
assert(#selected == 1 and selected[1]:IsA("Model"), "Selecione somente o Model do estudo no Explorador.")
local model = selected[1]
assert(model:FindFirstChild("Estudo_Body", true), "Selecione o estudo importado, não o personagem do jogo.")
assert(model:IsDescendantOf(workspace), "Coloque o estudo no Workspace primeiro.")
local history = game:GetService("ChangeHistoryService")
local recording = history:TryBeginRecording("AjustarEstudoMUBlox", "Ajustar estudo MUBlox")
assert(recording, "Não foi possível iniciar o histórico de desfazer; tente novamente.")
local success, failure = pcall(function()
    local before, size = model:GetBoundingBox()
    assert(size.Y > 0, "Modelo sem altura.")
    local feet = before.Position - Vector3.new(0, size.Y / 2, 0)
    model:ScaleTo(model:GetScale() * 5.5 / size.Y)
    local after, adjustedSize = model:GetBoundingBox()
    model:PivotTo(model:GetPivot() + feet - (after.Position - Vector3.new(0, adjustedSize.Y / 2, 0)))
    model.Name = "MUBloxEstudoMapa"
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
        end
    end
end)
history:FinishRecording(recording, success and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
assert(success, failure)
print("Estudo pronto: 5,5 studs de altura, ancorado e sem colisão. Use Mover para posicionar no mapa.")
