-- // CONFIGURAÇÕES INICIAIS (Globais)
_G.AimbotEnabled = false
_G.SilentAimEnabled = false
_G.HitboxEnabled = false
_G.HitboxSize = 2
_G.HitboxPart = "Head"
_G.HitboxTransparency = 0.5
_G.AimbotSmoothness = 0.15
_G.PredictionAmount = 0.165
_G.TargetPart = "Head"
_G.SilentAimMethod = "Mouse.Hit"
_G.FOV = 100
_G.ShowFOV = false
_G.FOVColor = Color3.fromRGB(255, 255, 255)
_G.AimbotKey = Enum.UserInputType.MouseButton2

-- // SERVIÇOS
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local mousemoverel = mousemoverel or (Input and Input.MoveMouseRelative) or function() end

-- // DESENHO DO FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Visible = false
FOVCircle.ZIndex = 999

-- // LÓGICA DE HITBOX EXPANDER
task.spawn(function()
    while task.wait(0.5) do
        if _G.HitboxEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local part = player.Character:FindFirstChild(_G.HitboxPart)
                    if part then
                        part.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                        part.Transparency = _G.HitboxTransparency
                        part.CanCollide = false -- Evita que jogadores fiquem presos nas hitboxes
                    end
                end
            end
        end
    end
end)

-- Função para resetar Hitboxes (importante para não bugar o jogo)
local function ResetHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            local torso = player.Character:FindFirstChild("HumanoidRootPart")
            if head then head.Size = Vector3.new(2, 1, 1) head.Transparency = 0 end
            if torso then torso.Size = Vector3.new(2, 2, 1) torso.Transparency = 1 end
        end
    end
end

-- // LÓGICA DE BUSCA DE ALVO
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
                    local distance = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
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

-- // --- SILENT AIM HOOKS ---
local function ApplySilentAim()
    local success, gmt = pcall(getrawmetatable, game)
    if not success then return end
    local oldIndex = gmt.__index
    local oldNamecall = gmt.__namecall
    setreadonly(gmt, false)

    gmt.__index = newcclosure(function(self, key)
        if _G.SilentAimEnabled and not checkcaller() and self == Mouse and (key == "Hit" or key == "Target") then
            local target = getClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(_G.TargetPart)
                if part and _G.SilentAimMethod == "Mouse.Hit" then
                    local endpoint = part.Position + (part.Velocity * _G.PredictionAmount)
                    return (key == "Hit" and CFrame.new(endpoint) or part)
                end
            end
        end
        return oldIndex(self, key)
    end)

    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if _G.SilentAimEnabled and not checkcaller() then
            local target = getClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(_G.TargetPart)
                if part then
                    local endpoint = part.Position + (part.Velocity * _G.PredictionAmount)
                    if method == "Raycast" and _G.SilentAimMethod == "Raycast" then
                        args[2] = (endpoint - args[1]).Unit * 5000
                        return oldNamecall(self, table.unpack(args))
                    elseif method:find("FindPartOnRay") and _G.SilentAimMethod == "FindPartOnRay" then
                        args[1] = Ray.new(Camera.CFrame.Position, (endpoint - Camera.CFrame.Position).Unit * 5000)
                        return oldNamecall(self, table.unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end
ApplySilentAim()

-- // LOOP PRINCIPAL
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    if _G.AimbotEnabled and UIS:IsMouseButtonPressed(_G.AimbotKey) then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(_G.TargetPart)
            if part then
                local prediction = part.Position + (part.Velocity * _G.PredictionAmount)
                local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
                if onScreen then
                    local mouseLoc = UIS:GetMouseLocation()
                    mousemoverel((screenPos.X - mouseLoc.X) * _G.AimbotSmoothness, (screenPos.Y - mouseLoc.Y) * _G.AimbotSmoothness)
                end
            end
        end
    end
end)
