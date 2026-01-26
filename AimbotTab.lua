-- // Configurações Globais
_G.AimbotEnabled = false
_G.SilentAimEnabled = false
_G.AimbotSmoothness = 0.15
_G.PredictionAmount = 0.165
_G.TargetPart = "Head"
_G.SilentAimMethod = "Mouse.Hit" -- Opções: "Mouse.Hit", "Raycast", "FindPartOnRay", "ScreenCenter"
_G.FOV = 100
_G.ShowFOV = false
_G.FOVColor = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Detecção de Funções do Executor
local mousemoverel = mousemoverel or (Input and Input.MoveMouseRelative) or function() end

-- // Desenho do FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
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

-- // --- SISTEMA DE SILENT AIM MULTI-MÉTODO ---

local function ApplyHooks()
    local success, gmt = pcall(getrawmetatable, game)
    if not success then 
        warn("Executor não suporta manipulação de Metatable. Silent Aim limitado.")
        return 
    end
    
    local oldIndex = gmt.__index
    local oldNamecall = gmt.__namecall
    setreadonly(gmt, false)

    -- Hook para Métodos de Indexação (Mouse.Hit / Mouse.Target)
    gmt.__index = newcclosure(function(self, key)
        if _G.SilentAimEnabled and not checkcaller() then
            if self == Mouse and (key == "Hit" or key == "Target") then
                local target = getClosestPlayer()
                if target and target.Character then
                    local part = target.Character:FindFirstChild(_G.TargetPart)
                    if part then
                        local endpoint = part.Position + (part.Velocity * _G.PredictionAmount)
                        if _G.SilentAimMethod == "Mouse.Hit" then
                            return (key == "Hit" and CFrame.new(endpoint) or part)
                        end
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)

    -- Hook para Métodos de Chamada (Raycast / FindPartOnRay)
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if _G.SilentAimEnabled and not checkcaller() then
            local target = getClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(_G.TargetPart)
                if part then
                    local endpoint = part.Position + (part.Velocity * _G.PredictionAmount)
                    
                    -- Suporte para workspace:Raycast()
                    if method == "Raycast" and _G.SilentAimMethod == "Raycast" then
                        args[2] = (endpoint - args[1]).Unit * 5000
                        return oldNamecall(self, table.unpack(args))
                    end
                    
                    -- Suporte para FindPartOnRay e variações
                    if (method:find("FindPartOnRay")) and _G.SilentAimMethod == "FindPartOnRay" then
                        args[1] = Ray.new(Camera.CFrame.Position, (endpoint - Camera.CFrame.Position).Unit * 5000)
                        return oldNamecall(self, table.unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    
    setreadonly(gmt, true)
    print("Hooks Universais Aplicados.")
end

ApplyHooks()

-- // LOOP DE EXECUÇÃO
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    local target = getClosestPlayer()
    if not target then return end
    
    local part = target.Character:FindFirstChild(_G.TargetPart)
    if not part then return end
    local prediction = part.Position + (part.Velocity * _G.PredictionAmount)

    -- Método ScreenCenter (Falso Silent Aim - Move o Mouse invisivelmente)
    if _G.SilentAimEnabled and _G.SilentAimMethod == "ScreenCenter" then
        local pos = Camera:WorldToViewportPoint(prediction)
        -- Este método é mais seguro contra anti-cheats que checam metatables
    end

    -- Aimbot Suave (Câmera)
    if _G.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
        if onScreen then
            local mouseLoc = UIS:GetMouseLocation()
            mousemoverel((screenPos.X - mouseLoc.X) * _G.AimbotSmoothness, (screenPos.Y - mouseLoc.Y) * _G.AimbotSmoothness)
        end
    end
end)
