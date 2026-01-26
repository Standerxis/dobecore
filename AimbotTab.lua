local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURAÇÃO SIMPLIFICADA
local Config = {
    Enabled = true,
    TeamCheck = true,
    FOV = 150,           -- Área de detecção (aumente se não estiver pegando)
    Smoothness = 0.2,    -- 0.1 (lento/legit) até 1.0 (instantâneo)
    Prediction = 0.15,   -- Ajuste para prever pulos e corridas
    Key = Enum.UserInputType.MouseButton2,
    ShowFOV = false      -- Mude para 'true' se quiser ver o círculo de novo
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.ShowFOV
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local currentTarget = nil
local isAiming = false

-- Função para checar se o alvo está visível (não mudou)
local function isVisible(part, character)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
    return result == nil
end

-- Busca o alvo mais próximo do CENTRO DA TELA
local function getBestTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closestDist = Config.FOV
    local selected = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        if isVisible(head, player.Character) then
                            closestDist = dist
                            selected = player
                        end
                    end
                end
            end
        end
    end
    return selected
end

-- Controles de Input
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then isAiming = true end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then isAiming = false; currentTarget = nil end
end)

-- LOOP PRINCIPAL (RODA TODO FRAME)
RS.RenderStepped:Connect(function()
    if Config.ShowFOV then
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = Config.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    if Config.Enabled and isAiming then
        if not currentTarget then currentTarget = getBestTarget() end

        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
            local head = currentTarget.Character.Head
            
            -- CÁLCULO DE PREDIÇÃO COMPLEXA
            -- Prevemos onde a cabeça estará com base na velocidade de movimento e queda
            -- $$P_{alvo} = P_{atual} + (Velocidade \times Predição)$$
            local predictedPos = head.Position + (head.Velocity * Config.Prediction)
            
            -- FORÇAR A CÂMERA A OLHAR
            -- Isso ignora o zoom e a distância, focando a rotação da câmera no ponto 3D
            local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        else
            currentTarget = nil
        end
    end
end)
