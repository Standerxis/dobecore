-- // Configurações Globais
print("teste")
_G.AimbotEnabled = false
_G.SilentAimEnabled = false
_G.AimbotSmoothness = 0.15
_G.PredictionAmount = 0.165
_G.TargetPart = "Head"
_G.SilentAimMethod = "Mouse.Hit" -- Padrão inicial
_G.FOV = 100
print("teste2")
_G.ShowFOV = false
print("teste1")
_G.FOVColor = Color3.fromRGB(255, 255, 255)
print("teste2")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
print("teste")
-- // Desenho do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
print("teste")
-- // Lógica de Busca de Alvo
local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.FOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.TargetPart) then
            local part = player.Character[_G.TargetPart]
            if player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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
print("teste")
-- // --- SISTEMA DE SILENT AIM UNIVERSAL ---
local gmt = getrawmetatable(game)
local oldIndex = gmt.__index
local oldNamecall = gmt.__namecall
setreadonly(gmt, false)
print("teste")
-- Hook para Mouse.Hit e Mouse.Target (Jogos Simples)
gmt.__index = newcclosure(function(self, key)
    if _G.SilentAimEnabled and _G.SilentAimMethod == "Mouse.Hit" and self == Mouse and not checkcaller() then
        local target = getClosestPlayer()
        if target and target.Character then
            local endpoint = target.Character[_G.TargetPart].Position + (target.Character[_G.TargetPart].Velocity * _G.PredictionAmount)
            if key == "Hit" then return CFrame.new(endpoint) end
            if key == "Target" then return target.Character[_G.TargetPart] end
        end
    end
    return oldIndex(self, key)
end)
print("teste")
-- Hook para Raycast e FindPartOnRay (Jogos Complexos/Modernos)
gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if _G.SilentAimEnabled and not checkcaller() then
        local target = getClosestPlayer()
        if target and target.Character then
            local endpoint = target.Character[_G.TargetPart].Position + (target.Character[_G.TargetPart].Velocity * _G.PredictionAmount)
            
            -- Redireciona Raycast moderno
            if method == "Raycast" and _G.SilentAimMethod == "Raycast" then
                args[2] = (endpoint - args[1]).Unit * 5000 -- Altera a direção do raio
                return oldNamecall(self, table.unpack(args))
            end
            
            -- Redireciona Métodos Antigos
            if (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") and _G.SilentAimMethod == "FindPartOnRay" then
                args[1] = Ray.new(Camera.CFrame.Position, (endpoint - Camera.CFrame.Position).Unit * 5000)
                return oldNamecall(self, table.unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(gmt, true)
print("teste")
-- // Loop Visual e Aimbot Suave
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    if _G.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character[_G.TargetPart]
            local prediction = part.Position + (part.Velocity * _G.PredictionAmount)
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            
            if onScreen and mousemoverel then
                local mouseLoc = UIS:GetMouseLocation()
                mousemoverel((screenPos.X - mouseLoc.X) * _G.AimbotSmoothness, (screenPos.Y - mouseLoc.Y) * _G.AimbotSmoothness)
            end
        end
    end
end)
print("teste")
