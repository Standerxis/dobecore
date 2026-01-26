local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- O círculo é criado apenas uma vez
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local segurandoBotao = false

local function getClosestPlayer()
    local target = nil
    -- CORREÇÃO: Usando a mesma variável que o Slider da UI altera
    local shortestDistance = _G.AimbotFOV or 100 

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mouseLocation = UIS:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude
                    
                    -- Verifica se está dentro do FOV configurado na UI
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

-- Input Listeners
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == _G.AimbotKey or input.KeyCode == _G.AimbotKey then
        segurandoBotao = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == _G.AimbotKey or input.KeyCode == _G.AimbotKey then
        segurandoBotao = false
    end
end)

RS.RenderStepped:Connect(function()
    -- CORREÇÃO: Sincronizando com os nomes exatos da sua UI
    FOVCircle.Visible = _G.ShowFOV or false
    FOVCircle.Radius = _G.AimbotFOV or 100
    FOVCircle.Color = _G.AimbotFOVColor or Color3.fromRGB(255, 255, 255)
    FOVCircle.Position = UIS:GetMouseLocation()

    -- Lógica de disparo
    if _G.AimbotEnabled and segurandoBotao then
        local targetPart = getClosestPlayer()
        if targetPart then
            local mouseLocation = UIS:GetMouseLocation()
            local pred = _G.PredictionAmount or 0.165
            local smooth = _G.AimbotSmoothness or 0.15
            
            local prediction = targetPart.Position + (targetPart.Velocity * pred)
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            
            if onScreen then
                local targetVector = Vector2.new(screenPos.X, screenPos.Y)
                
                if mousemoverel then
                    local mouseMoveVector = (targetVector - mouseLocation) * smooth
                    mousemoverel(mouseMoveVector.X, mouseMoveVector.Y)
                else
                    local lookAtGoal = CFrame.new(Camera.CFrame.Position, prediction)
                    Camera.CFrame = Camera.CFrame:Lerp(lookAtGoal, smooth)
                end
            end
        end
    end
end)
