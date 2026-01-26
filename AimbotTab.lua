local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local Config = {
    Enabled = true,
    TeamCheck = true,
    FOV = 150,
    ShowFOV = true, -- Se falso, o círculo nunca aparece
    Smoothness = 0.15, 
    PredictionAmount = 0.165,
    TargetPart = "Head",
    Key = Enum.UserInputType.MouseButton2
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Visible = false -- Começa invisível

local currentTarget = nil
local isAiming = false

local function isVisible(part, character)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500, rayParams)
    return result == nil
end

local function getBestTarget()
    local mousePos = UIS:GetMouseLocation()
    local closestDist = Config.FOV
    local selected = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local part = char:FindFirstChild(Config.TargetPart)
            local hum = char:FindFirstChildOfClass("Humanoid")

            if part and hum and hum.Health > 0 then
                if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
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

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then
        isAiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Key or input.KeyCode == Config.Key then
        isAiming = false
        currentTarget = nil
        FOVCircle.Visible = false -- Esconde o círculo ao soltar o botão
    end
end)

RS.RenderStepped:Connect(function()
    local mouseLocation = UIS:GetMouseLocation()
    
    -- Lógica do Círculo vinculada ao isAiming
    if Config.ShowFOV and isAiming then
        FOVCircle.Visible = true
        FOVCircle.Radius = Config.FOV
        FOVCircle.Position = mouseLocation
    else
        FOVCircle.Visible = false
    end

    if Config.Enabled and isAiming then
        if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            currentTarget = getBestTarget()
        end

        if currentTarget and currentTarget.Character then
            local targetPart = currentTarget.Character:FindFirstChild(Config.TargetPart)
            if targetPart then
                local prediction = targetPart.Position + (targetPart.Velocity * Config.PredictionAmount)
                
                -- Sistema de CFrame (Ideal para 1ª e 3ª pessoa)
                local lookAtCFrame = CFrame.new(Camera.CFrame.Position, prediction)
                Camera.CFrame = Camera.CFrame:Lerp(lookAtCFrame, Config.Smoothness)
            end
        end
    end
end)
