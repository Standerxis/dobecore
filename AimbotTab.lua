-- // Configurações Globais
_G.AimbotEnabled = true
_G.SilentAimEnabled = true
_G.AutoShoot = true
_G.FOV = 150
_G.ShowFOV = true
_G.PredictionAmount = 0.165 -- Ajuste dependendo da velocidade do projétil do jogo
_G.Smoothness = 0.1 -- Para o Aimbot suave
_G.TargetPart = "Head" -- "Head", "HumanoidRootPart", etc.

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Desenho do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 999

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

-- // Silent Aim Logic (Hooking)
-- Nota: Isso redireciona a propriedade 'Hit' e 'Target' do Mouse
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNamecall = gmt.__index

gmt.__index = newcclosure(function(self, key)
    if _G.SilentAimEnabled and self == Mouse and (key == "Hit" or key == "Target") then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character then
            local endpoint = targetPlayer.Character[_G.TargetPart].Position + (targetPlayer.Character[_G.TargetPart].Velocity * _G.PredictionAmount)
            return (key == "Hit" and CFrame.new(endpoint) or targetPlayer.Character[_G.TargetPart])
        end
    end
    return oldNamecall(self, key)
end)
setreadonly(gmt, true)

-- // Loop Principal
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)

    local targetPlayer = getClosestPlayer()

    if targetPlayer and targetPlayer.Character then
        local targetPart = targetPlayer.Character[_G.TargetPart]
        local prediction = targetPart.Position + (targetPart.Velocity * _G.PredictionAmount)
        
        -- Auto-Shoot (Clicker)
        if _G.AutoShoot then
            -- Simula o clique se houver um alvo válido no FOV
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end

        -- Aimbot Suave (Opcional, se quiser que a câmera siga além do Silent Aim)
        if _G.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            if onScreen then
                local mouseLocation = UIS:GetMouseLocation()
                local targetVector = Vector2.new(screenPos.X, screenPos.Y)
                local mouseMoveVector = (targetVector - mouseLocation) * _G.Smoothness
                
                if mousemoverel then
                    mousemoverel(mouseMoveVector.X, mouseMoveVector.Y)
                end
            end
        end
    end
end)
