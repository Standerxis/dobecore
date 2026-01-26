local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações Padrão
_G.AimbotEnabled = _G.AimbotEnabled or true
_G.AimbotFOV = _G.AimbotFOV or 150
_G.AimbotSmoothness = _G.AimbotSmoothness or 0.15
_G.ShowFOV = _G.ShowFOV or true
-- Se não houver tecla definida, o padrão será o Botão Direito (MouseButton2)
_G.AimbotKey = _G.AimbotKey or Enum.UserInputType.MouseButton2

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Transparency = 1
FOVCircle.Filled = false

local segurandoBotao = false

local function isVisible(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, targetPart.Parent}
    
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, params)
    return result == nil
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

-- Lógica de Entrada Corrigida
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- Verifica se a bind atual é Unknown. Se for, usa o Botão Direito como Fallback.
    local activeBind = (_G.AimbotKey == Enum.KeyCode.Unknown) and Enum.UserInputType.MouseButton2 or _G.AimbotKey
    
    if input.KeyCode == activeBind or input.UserInputType == activeBind then
        segurandoBotao = true
    end
end)

UIS.InputEnded:Connect(function(input)
    local activeBind = (_G.AimbotKey == Enum.KeyCode.Unknown) and Enum.UserInputType.MouseButton2 or _G.AimbotKey
    
    if input.KeyCode == activeBind or input.UserInputType == activeBind then
        segurandoBotao = false
    end
end)

RS.RenderStepped:Connect(function()
    local mouseLocation = UIS:GetMouseLocation()
    
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = mouseLocation
    FOVCircle.Color = _G.AimbotFOVColor or Color3.fromRGB(255, 255, 255)

    if _G.AimbotEnabled and segurandoBotao then
        local targetData = getClosestPlayer()
        
        if targetData then
            if mousemoverel then
                local mouseMoveX = (targetData.screenPos.X - mouseLocation.X) * _G.AimbotSmoothness
                local mouseMoveY = (targetData.screenPos.Y - mouseLocation.Y) * _G.AimbotSmoothness
                mousemoverel(mouseMoveX, mouseMoveY)
            else
                local lookAt = CFrame.new(Camera.CFrame.Position, targetData.part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness)
            end
        end
    end
end)
