local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Configuração do Círculo de FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local segurandoBotao = false

local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.AimbotFOV or 100

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    
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

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == (_G.AimbotKey or Enum.UserInputType.MouseButton2) then
        segurandoBotao = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == (_G.AimbotKey or Enum.UserInputType.MouseButton2) then
        segurandoBotao = false
    end
end)

RS.RenderStepped:Connect(function()
    -- Atualiza o Círculo Visual
    FOVCircle.Visible = _G.ShowFOV or false
    FOVCircle.Radius = _G.AimbotFOV or 100
    FOVCircle.Color = _G.AimbotFOVColor or Color3.fromRGB(255, 255, 255)
    FOVCircle.Position = UIS:GetMouseLocation()

    if _G.AimbotEnabled and segurandoBotao then
        local targetPart = getClosestPlayer()
        if targetPart then
            -- Suavidade: quanto maior o número, mais lento/suave o movimento
            local smoothness = _G.AimbotSmoothness or 0.1 
            
            -- Em vez de teleportar a câmera, vamos rotacionar ela suavemente para o alvo
            local lookAt = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, smoothness)
        end
    end
end)
