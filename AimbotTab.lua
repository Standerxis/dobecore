-- // Configurações Globais (Integre com sua UI)
_G.AimbotEnabled = true
_G.HitboxEnabled = true -- Expander de Hitbox

_G.AimbotSmoothness = 0.15
_G.PredictionAmount = 0.165
_G.TargetPart = "Head" 

-- // Configurações de Hitbox (Operação Segura)
_G.HitboxPart = "HumanoidRootPart" 
_G.HitboxSize = 4 -- Tamanho moderado para evitar detecção visual/física
_G.HitboxTransparency = 0.7

_G.FOV = 100
_G.ShowFOV = true
_G.FOVColor = Color3.fromRGB(0, 255, 255)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Detecção Segura de Funções (Não manipula serviços proibidos)
local mousemoverel = mousemoverel or (Input and Input.MoveMouseRelative) or function() end

-- // Desenho do FOV (Utiliza Drawing API, geralmente ignorada por Disallowed Services)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Visible = false
FOVCircle.ZIndex = 999

-- // Função de Detecção Otimizada
local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(_G.TargetPart)
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if part and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mouseLoc = UIS:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
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

-- // --- SISTEMA DE HITBOX EXPANDER (Operação Externa Segura) ---
-- Esta função altera propriedades físicas simples, o que raramente causa Disallowed Services
task.spawn(function()
    while true do
        task.wait(1) 
        if _G.HitboxEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local target = player.Character:FindFirstChild(_G.HitboxPart)
                    if target and target:IsA("BasePart") then
                        target.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                        target.Transparency = _G.HitboxTransparency
                        target.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- // --- LOOP DE RENDERIZAÇÃO (Bypass Mode) ---
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    -- Aimbot Baseado em Câmera/Mouse (Não usa Hooks de Metatable)
    if _G.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(_G.TargetPart)
            if part then
                local prediction = part.Position + (part.Velocity * _G.PredictionAmount)
                local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
                
                if onScreen then
                    local mouseLoc = UIS:GetMouseLocation()
                    -- O segredo do bypass aqui é o Smoothness: movimentos suaves não disparam heurísticas
                    mousemoverel(
                        (screenPos.X - mouseLoc.X) * _G.AimbotSmoothness, 
                        (screenPos.Y - mouseLoc.Y) * _G.AimbotSmoothness
                    )
                end
            end
        end
    end
end)
