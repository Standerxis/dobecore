-- // Configurações Globais
print("Iniciando Configurações...")
_G.AimbotEnabled = false
_G.SilentAimEnabled = false
_G.AimbotSmoothness = 0.15
_G.PredictionAmount = 0.165
_G.TargetPart = "Head"
_G.SilentAimMethod = "Mouse.Hit"
_G.FOV = 100
_G.ShowFOV = false
_G.FOVColor = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

print("Serviços carregados com sucesso.")

-- // Desenho do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Visible = false
FOVCircle.ZIndex = 999

-- // Lógica de Busca de Alvo
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

-- // --- SISTEMA DE SILENT AIM COM PROTEÇÃO ---
print("Tentando aplicar Silent Aim Hooks...")

local success, err = pcall(function()
    local gmt = getrawmetatable(game)
    local oldIndex = gmt.__index
    local oldNamecall = gmt.__namecall
    setreadonly(gmt, false)

    gmt.__index = newcclosure(function(self, key)
        if _G.SilentAimEnabled and _G.SilentAimMethod == "Mouse.Hit" and self == Mouse and not checkcaller() then
            local target = getClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(_G.TargetPart)
                if part then
                    local endpoint = part.Position + (part.Velocity * _G.PredictionAmount)
                    if key == "Hit" then return CFrame.new(endpoint) end
                    if key == "Target" then return part end
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
                    end
                    
                    if (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") and _G.SilentAimMethod == "FindPartOnRay" then
                        args[1] = Ray.new(Camera.CFrame.Position, (endpoint - Camera.CFrame.Position).Unit * 5000)
                        return oldNamecall(self, table.unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end)

if not success then
    warn("Erro ao carregar Silent Aim (Metatable bloqueada): " .. tostring(err))
else
    print("Silent Aim Hooks aplicados!")
end

-- // Loop Visual e Aimbot Suave
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    if _G.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(_G.TargetPart)
            if part then
                local prediction = part.Position + (part.Velocity * _G.PredictionAmount)
                local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
                
                if onScreen and mousemoverel then
                    local mouseLoc = UIS:GetMouseLocation()
                    pcall(function()
                        mousemoverel((screenPos.X - mouseLoc.X) * _G.AimbotSmoothness, (screenPos.Y - mouseLoc.Y) * _G.AimbotSmoothness)
                    end)
                end
            end
        end
    end
end)

print("Script carregado até o fim.")
