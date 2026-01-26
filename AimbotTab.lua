local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações de Elite
local Config = {
    Enabled = true,
    TeamCheck = true,
    FOV_Radius = 120, -- Tamanho do círculo na tela
    MaxAngle = 25,    -- Ângulo máximo em graus (ignora zoom)
    Smoothness = 0.15, -- 0.1 a 0.3 (quanto menor, mais suave/legit)
    Prediction = 0.14, -- Ajuste para a velocidade do projétil/ping
    TargetPart = "Head",
    Key = Enum.UserInputType.MouseButton2
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Color = Color3.fromRGB(255, 80, 80)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.6

local currentTarget = nil
local isAiming = false

-- Função para ignorar seu personagem e acessórios no Raycast
local function getIgnoreList()
    local list = {LocalPlayer.Character}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then table.insert(list, p.Character) end
    end
    return list
end

local function isVisible(part, character)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    
    -- O raio sai da Câmera para o Alvo
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
    return result == nil
end

-- Busca o alvo baseado no ângulo da câmera (independente de zoom)
local function getBestTarget()
    local bestTarget = nil
    local minAngle = Config.MaxAngle

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local head = player.Character:FindFirstChild(Config.TargetPart)
            local hum = player.Character:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                -- Cálculo de Ângulo (Produto Escalar)
                local vectorToTarget = (head.Position - Camera.CFrame.Position).Unit
                local cameraLook = Camera.CFrame.LookVector
                
                -- Cosine Similarity -> Ângulo em graus
                local dotProduct = cameraLook:Dot(vectorToTarget)
                local angle = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))

                if angle < minAngle then
                    if isVisible(head, player.Character) then
                        minAngle = angle
                        bestTarget = player
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Ativação por tecla
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then
        isAiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then
        isAiming = false
        currentTarget = nil
    end
end)

-- Loop de atualização em 60Hz+
RS.RenderStepped:Connect(function()
    local mouseLoc = UIS:GetMouseLocation()
    FOVCircle.Position = mouseLoc
    FOVCircle.Radius = Config.FOV_Radius
    FOVCircle.Visible = Config.Enabled

    if Config.Enabled and isAiming then
        -- Se o alvo atual fugir ou morrer, busca outro
        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getBestTarget()
        end

        if currentTarget and currentTarget.Character then
            local part = currentTarget.Character:FindFirstChild(Config.TargetPart)
            if part then
                -- LÓGICA DE PREDIÇÃO E MOVIMENTO
                -- P = P0 + (V * t)
                local prediction = part.Position + (part.Velocity * Config.Prediction)
                
                -- Criamos uma matriz de rotação que olha para o alvo
                local targetCFrame = CFrame.new(Camera.CFrame.Position, prediction)
                
                -- Suavização (Lerp) para a câmera não dar "snap" instantâneo e parecer hack óbvio
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
                
                -- Opcional: Centraliza o mouse no centro da tela para jogos que usam Raycast do mouse
                if mousemoverel then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
                    if onScreen then
                        local diff = Vector2.new(screenPos.X, screenPos.Y) - mouseLoc
                        mousemoverel(diff.X * 0.4, diff.Y * 0.4)
                    end
                end
            end
        end
    end
end)
