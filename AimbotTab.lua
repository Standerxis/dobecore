local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações Avançadas
local Config = {
    Enabled = true,
    TeamCheck = true,
    FOV = 150,
    Smoothness = 0.12, -- Quanto menor, mais suave. 1 = Instantâneo.
    PredictionAmount = 0.165, -- Ajuste para compensar o lag/velocidade (0.1 a 0.2 é o ideal)
    TargetPart = "Head",
    Key = Enum.UserInputType.MouseButton2
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0, 255, 150)

local currentTarget = nil
local isAiming = false

-- Função de Visibilidade Melhorada
local function isVisible(part, character)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    -- Ignora você e o personagem que você está tentando acertar
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    rayParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500
    local result = workspace:Raycast(origin, direction, rayParams)
    
    return result == nil
end

-- Busca o alvo com lógica de proximidade e FOV
local function getBestTarget()
    local mousePos = UIS:GetMouseLocation()
    local closestDist = Config.FOV
    local selected = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.TargetPart) then
            -- Team Check
            if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local char = player.Character
            local part = char[Config.TargetPart]
            local hum = char:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen and isVisible(part, char) then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        selected = player
                    end
                end
            end
        end
    end
    return selected
end

-- Input Listeners
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then
        isAiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then
        isAiming = false
        currentTarget = nil -- Limpa o alvo ao soltar o botão
    end
end)

-- Loop Principal de Alta Frequência
RS.RenderStepped:Connect(function(deltaTime)
    local mouseLocation = UIS:GetMouseLocation()
    
    -- UI do FOV
    FOVCircle.Visible = true
    FOVCircle.Radius = Config.FOV
    FOVCircle.Position = mouseLocation

    if Config.Enabled and isAiming then
        -- Mantém o alvo atual ou busca um novo se necessário
        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getBestTarget()
        end

        if currentTarget and currentTarget.Character then
            local targetPart = currentTarget.Character:FindFirstChild(Config.TargetPart)
            if targetPart then
                -- CÁLCULO DE PREDIÇÃO:
                -- Prevemos a posição baseada na velocidade do alvo multiplicada pelo delta de tempo
                local velocity = targetPart.Velocity
                local predictedPosition = targetPart.Position + (velocity * Config.PredictionAmount)
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPosition)
                
                if onScreen then
                    -- Interpolação para movimento suave (Lerp Espacial)
                    local targetVec = Vector2.new(screenPos.X, screenPos.Y)
                    local diff = targetVec - mouseLocation
                    
                    -- Se o executor suportar mousemoverel, ele é mais furtivo e eficiente
                    if mousemoverel then
                        mousemoverel(diff.X * Config.Smoothness, diff.Y * Config.Smoothness)
                    else
                        -- Fallback para câmera direta se não houver mousemoverel
                        local lookAt = CFrame.new(Camera.CFrame.Position, predictedPosition)
                        Camera.CFrame = Camera.CFrame:Lerp(lookAt, Config.Smoothness)
                    end
                else
                    currentTarget = nil -- Perdeu de vista, busca outro
                end
            end
        end
    end
end)
