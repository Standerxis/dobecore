-- // Configurações Globais
_G.AimbotEnabled = false
_G.HitboxEnabled = false
_G.AutoFire = false 
_G.AutoFirePrecision = 15

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

-- // Função de Clique (Auto-Fire)
local isClicking = false
local function RealClick(x, y)
    if isClicking then return end
    isClicking = true
    task.spawn(function()
        VirtualInputManager:SendMouseMoveEvent(x + math.random(-2,2), y + math.random(-2,2), game)
        task.wait(math.random(5,10)/1000)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(math.random(10,20)/1000)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        task.wait(0.1) 
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

-- // --- SISTEMA DE HITBOX EXPANDER ---
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

-- // --- LOOP DE RENDERIZAÇÃO ---
local lastTargetName = ""

RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = _G.FOVColor

    -- Procura o alvo o tempo todo (independente de clicar ou não)
    local target = getClosestPlayer()
    
    if target and target.Character then
        -- Print no console apenas quando mudar de alvo para não floodar
        if lastTargetName ~= target.Name then
            print("Jogador detectado no FOV: " .. target.Name)
            lastTargetName = target.Name
        end

        local part = target.Character:FindFirstChild(_G.TargetPart)
        if part then
            local prediction = part.Position + (part.Velocity * _G.PredictionAmount)
            local screenPos, onScreen = Camera:WorldToViewportPoint(prediction)
            
            if onScreen then
                local mouseLoc = UIS:GetMouseLocation()
                
                -- 1. Movimento do Aimbot (Só se estiver segurando o Direito)
                if _G.AimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    mousemoverel(
                        (screenPos.X - mouseLoc.X) * _G.AimbotSmoothness, 
                        (screenPos.Y - mouseLoc.Y) * _G.AimbotSmoothness
                    )
                end
                
                -- 2. Lógica de Auto-Fire (Independente de mirar, se estiver na precisão ele atira)
                if _G.AutoFire then
                    local distanceToTarget = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                    if distanceToTarget < (_G.AutoFirePrecision or 15) then 
                        RealClick(mouseLoc.X, mouseLoc.Y)
                    end
                end
            end
        end
    else
        lastTargetName = "" -- Reseta se não houver ninguém no FOV
    end
end)
