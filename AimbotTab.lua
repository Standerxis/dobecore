-- // Configurações Globais
_G.AimbotEnabled = false
_G.HitboxEnabled = false
_G.AutoFire = false 
_G.AutoFirePrecision = 15
_G.AutoInterval = 0.1 -- Intervalo entre cliques (Ex: 0.1 é rápido, 0.5 é lento)

_G.AimbotSmoothness = 0.15
_G.PredictionAmount = 0.165
_G.TargetPart = "Head" 

-- // Configurações de Hitbox
_G.HitboxPart = "HumanoidRootPart" 
_G.HitboxSize = 4
_G.HitboxTransparency = 0.7

_G.FOV = 100
_G.ShowFOV = false
_G.FOVColor = Color3.fromRGB(0, 255, 255)

local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Função de Clique (Auto-Fire) com Intervalo Configurável
local isClicking = false
local function RealClick(targetPos)
    if isClicking then return end
    isClicking = true
    task.spawn(function()
        -- Envia o clique na posição exata da tela
        VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, true, game, 1)
        task.wait(math.random(15, 30)/1000) -- Tempo de pressão (click down/up)
        VirtualInputManager:SendMouseButtonEvent(targetPos.X, targetPos.Y, 0, false, game, 1)
        
        -- Espera o intervalo definido antes de permitir o próximo clique
        task.wait(_G.AutoInterval) 
        isClicking = false
    end)
end

-- // Detecção Segura de Funções
local mousemoverel = mousemoverel or (Input and Input.MoveMouseRelative) or function() end

-- // Desenho do FOV
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

-- // --- SISTEMA DE HITBOX EXPANDER (Com Reset de Estado) ---
task.spawn(function()
    while true do
        task.wait(0.5) 
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetPart = player.Character:FindFirstChild(_G.HitboxPart)
                if targetPart and targetPart:IsA("BasePart") then
                    if _G.HitboxEnabled then
                        targetPart.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                        targetPart.Transparency = _G.HitboxTransparency
                        targetPart.CanCollide = false
                    else
                        -- Retorna ao tamanho padrão se a função for desligada
                        targetPart.Size = Vector3.new(2, 2, 1)
                        targetPart.Transparency = 0
                        targetPart.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- // --- LOOP DE RENDERIZAÇÃO (Aimbot + Auto-Fire) ---
local lastTargetName = ""

RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    local target = getClosestPlayer()
    
    if target and target.Character then
        if lastTargetName ~= target.Name then
            print("Alvo no FOV: " .. target.Name)
            lastTargetName = target.Name
        end

        local part = target.Character:FindFirstChild(_G.TargetPart)
        if part then
            local prediction = part.Position + (part.Velocity * _G.PredictionAmount)
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            
            if onScreen then
                local mouseLoc = UIS:GetMouseLocation()
                
                -- 1. Movimentação do Aimbot (Botão Direito)
                if _G.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    mousemoverel(
                        (screenPos.X - mouseLoc.X) * _G.AimbotSmoothness, 
                        (screenPos.Y - mouseLoc.Y) * _G.AimbotSmoothness
                    )
                end
                
                -- 2. Disparo Automático (Auto-Fire)
                if _G.AutoFire then
                    local distanceToTarget = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                    
                    -- Verifica se a mira está em cima do alvo baseado na precisão
                    if distanceToTarget <= (_G.AutoFirePrecision or 15) then 
                        RealClick(screenPos)
                    end
                end
            end
        end
    else
        lastTargetName = ""
    end
end)
