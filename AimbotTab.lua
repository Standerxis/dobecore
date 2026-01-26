-- // Configurações Iniciais via Globais (Sincronizadas com a UI)
_G.AimbotEnabled = false
_G.SilentAimEnabled = false
_G.AutoShoot = false
_G.FOV = 100
_G.FOVColor = Color3.fromRGB(255, 255, 255)
_G.ShowFOV = false
_G.AimbotSmoothness = 0.15
_G.PredictionAmount = 0.165
_G.TargetPart = "Head"
_G.AimbotKey = Enum.UserInputType.MouseButton2 

-- // Serviços
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Desenho do FOV (Overlay)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 999

-- // Função de Busca de Alvo Projetada no FOV
local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.TargetPart) then
            local part = player.Character[_G.TargetPart]
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local mouseLocation = UIS:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude
                    
                    if distance < shortestDistance then
                        target = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- // SILENT AIM: Hooking do Metamethod __index
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldIndex = gmt.__index

gmt.__index = newcclosure(function(self, key)
    if _G.SilentAimEnabled and not checkcaller() and self == Mouse and (key == "Hit" or key == "Target") then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild(_G.TargetPart) then
            local targetPart = targetPlayer.Character[_G.TargetPart]
            local prediction = targetPart.Position + (targetPart.Velocity * _G.PredictionAmount)
            
            return (key == "Hit" and CFrame.new(prediction) or targetPart)
        end
    end
    return oldIndex(self, key)
end)
setreadonly(gmt, true)

-- // LOOP PRINCIPAL (RenderStepped para suavidade máxima)
RS.RenderStepped:Connect(function()
    -- Atualização Visual do FOV
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    local targetPlayer = getClosestPlayer()

    if targetPlayer and targetPlayer.Character then
        local targetPart = targetPlayer.Character[_G.TargetPart]
        local prediction = targetPart.Position + (targetPart.Velocity * _G.PredictionAmount)
        
        -- AUTO-SHOOT (Triggerbot Integrado)
        if _G.AutoShoot then
            mouse1press()
            task.wait(0.02) -- Delay mínimo para registrar o hit
            mouse1release()
        end

        -- AIMBOT SUAVE (Movimentação de Câmera)
        if _G.AimbotEnabled and UIS:IsMouseButtonPressed(_G.AimbotKey) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            if onScreen then
                local mouseLocation = UIS:GetMouseLocation()
                local targetVector = Vector2.new(screenPos.X, screenPos.Y)
                local mouseMoveVector = (targetVector - mouseLocation) * _G.AimbotSmoothness
                
                if mousemoverel then
                    mousemoverel(mouseMoveVector.X, mouseMoveVector.Y)
                end
            end
        end
    end
end)
