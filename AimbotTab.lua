-- // Configurações Globais
_G.AimbotEnabled = _G.AimbotEnabled or false
_G.FOV = _G.FOV or 100
_G.FOVColor = _G.FOVColor or Color3.fromRGB(255, 255, 255)
_G.ShowFOV = _G.ShowFOV or false
_G.AimbotSmoothness = _G.AimbotSmoothness or 0.15
_G.AimbotKey = _G.AimbotKey or Enum.UserInputType.MouseButton2
_G.PredictionAmount = _G.PredictionAmount or 0.165

-- // Serviços
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

print("--- [DEBUG] Script Iniciado ---")

-- // Inicialização do Círculo de FOV
local FOVCircle
local drawingSuccess, err = pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false
    return FOVCircle
end)

if not drawingSuccess or not FOVCircle then
    warn("--- [ERRO] Executor não suporta Drawing Lib! O FOV não aparecerá. ---")
else
    print("--- [DEBUG] Drawing Lib carregada com sucesso. ---")
end

local segurandoBotao = false
local lastFovState = _G.ShowFOV

-- // Função para encontrar o alvo mais próximo
local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mouseLocation = UIS:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude
                    
                    if distance < shortestDistance then
                        target = head
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- // Detecção de Input
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local key = _G.AimbotKey
    if input.UserInputType == key or input.KeyCode == key then
        segurandoBotao = true
        -- print("[DEBUG] Botão pressionado")
    end
end)

UIS.InputEnded:Connect(function(input)
    local key = _G.AimbotKey
    if input.UserInputType == key or input.KeyCode == key then
        segurandoBotao = false
        -- print("[DEBUG] Botão solto")
    end
end)

-- // Loop de Renderização
RS.RenderStepped:Connect(function()
    -- Debug de estado do FOV (Só printa quando muda)
    if _G.ShowFOV ~= lastFovState then
        print("[DEBUG] ShowFOV mudou para: " .. tostring(_G.ShowFOV))
        lastFovState = _G.ShowFOV
    end

    -- Atualização Visual do FOV
    if FOVCircle then
        FOVCircle.Visible = _G.ShowFOV
        FOVCircle.Radius = _G.FOV
        FOVCircle.Color = _G.FOVColor
        FOVCircle.Position = UIS:GetMouseLocation()
    end

    -- Lógica do Aimbot
    if _G.AimbotEnabled and segurandoBotao then
        local targetPart = getClosestPlayer()
        
        if targetPart then
            local pred = _G.PredictionAmount
            local smooth = _G.AimbotSmoothness
            
            local rootPart = targetPart.Parent:FindFirstChild("HumanoidRootPart")
            local velocity = rootPart and rootPart.Velocity or Vector3.new(0,0,0)
            
            local prediction = targetPart.Position + (velocity * pred)
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            
            if onScreen then
                local mouseLocation = UIS:GetMouseLocation()
                local targetVector = Vector2.new(screenPos.X, screenPos.Y)
                
                if mousemoverel then
                    local moveX = (targetVector.X - mouseLocation.X) * smooth
                    local moveY = (targetVector.Y - mouseLocation.Y) * smooth
                    mousemoverel(moveX, moveY)
                else
                    local lookAtGoal = CFrame.new(Camera.CFrame.Position, prediction)
                    Camera.CFrame = Camera.CFrame:Lerp(lookAtGoal, smooth)
                end
            end
        end
    end
end)
