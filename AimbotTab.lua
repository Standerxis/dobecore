local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações Padrão (Caso não definidas via UI)
_G.AimbotEnabled = _G.AimbotEnabled or true
_G.AimbotFOV = _G.AimbotFOV or 150
_G.AimbotSmoothness = _G.AimbotSmoothness or 0.15 -- Menor = Mais suave
_G.ShowFOV = _G.ShowFOV or true

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Transparency = 1
FOVCircle.Filled = false

local segurandoBotao = false

-- Função para checar se há obstáculos entre você e o alvo
local function isVisible(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, targetPart.Parent} -- Ignora você e o alvo
    
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, params)
    
    return result == nil -- Se for nil, não bateu em nada (visível)
end

local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.AimbotFOV
    local mousePos = UIS:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen and isVisible(head) then
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        target = {part = head, screenPos = Vector2.new(pos.X, pos.Y)}
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- Detecção de ativação (Aceita KeyCode ou Mouse)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- Pega a bind atual (seja ela Mouse ou Tecla)
    local currentBind = _G.AimbotKey 
    
    if currentBind and currentBind ~= Enum.KeyCode.Unknown then
        if input.KeyCode == currentBind or input.UserInputType == currentBind then
            segurandoBotao = true
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    local currentBind = _G.AimbotKey 
    
    if currentBind and currentBind ~= Enum.KeyCode.Unknown then
        if input.KeyCode == currentBind or input.UserInputType == currentBind then
            segurandoBotao = false
        end
    end
end)

RS.RenderStepped:Connect(function()
    local mouseLocation = UIS:GetMouseLocation()
    
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = mouseLocation
    FOVCircle.Color = _G.AimbotFOVColor or Color3.fromRGB(255, 0, 0)

    if _G.AimbotEnabled and segurandoBotao then
        local targetData = getClosestPlayer()
        
        if targetData then
            if mousemoverel then
                -- Método 1: Movimento Relativo (Melhor para anti-cheat e suavidade)
                local mouseMoveX = (targetData.screenPos.X - mouseLocation.X) * _G.AimbotSmoothness
                local mouseMoveY = (targetData.screenPos.Y - mouseLocation.Y) * _G.AimbotSmoothness
                mousemoverel(mouseMoveX, mouseMoveY)
            else
                -- Método 2: CFrame Lerp (Garante foco direto em 3ª pessoa)
                local lookAt = CFrame.new(Camera.CFrame.Position, targetData.part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness)
            end
        end
    end
end)
