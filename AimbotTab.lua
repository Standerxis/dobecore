
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 999

local segurandoBotao = false

local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.FOV or 100 

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
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

UIS.InputBegan:Connect(function(input)
    local key = _G.AimbotKey or Enum.UserInputType.MouseButton2
    if input.UserInputType == key or input.KeyCode == key then
        segurandoBotao = true
    end
end)

UIS.InputEnded:Connect(function(input)
    local key = _G.AimbotKey or Enum.UserInputType.MouseButton2
    if input.UserInputType == key or input.KeyCode == key then
        segurandoBotao = false
    end
end)

RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV or false
    FOVCircle.Radius = _G.FOV or 100
    FOVCircle.Color = _G.FOVColor or Color3.fromRGB(255, 255, 255)
    FOVCircle.Position = UIS:GetMouseLocation()

    if _G.AimbotEnabled and segurandoBotao then
        local targetPart = getClosestPlayer()
        if targetPart then
            local mouseLocation = UIS:GetMouseLocation()
            local prediction = targetPart.Position + (targetPart.Velocity * (_G.PredictionAmount or 0.165))
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            
            if onScreen then
                local targetVector = Vector2.new(screenPos.X, screenPos.Y)
                local mouseMoveVector = (targetVector - mouseLocation) * (_G.AimbotSmoothness or 0.15)
                
                if mousemoverel then
                    mousemoverel(mouseMoveVector.X, mouseMoveVector.Y)
                else
                    local lookAtGoal = CFrame.new(Camera.CFrame.Position, prediction)
                    Camera.CFrame = Camera.CFrame:Lerp(lookAtGoal, _G.AimbotSmoothness or 0.15)
                end
            end
        end
    end
end)
