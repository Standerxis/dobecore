-- // Configurações Globais (Garante que existam)
_G.AimbotEnabled = _G.AimbotEnabled or false
_G.FOV = _G.FOV or 100
_G.ShowFOV = _G.ShowFOV or false
_G.FOVColor = _G.FOVColor or Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

print("--- [SISTEMA] Iniciando Aimbot Debug Mode ---")

-- // Criar Círculo
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local segurandoBotao = false

-- // Função de busca de alvo
local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.FOV or 100
    local mouseLoc = UIS:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                if distance < shortestDistance then
                    target = player.Character.Head
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- // Loop de Atualização (RenderStepped)
RS.RenderStepped:Connect(function()
    -- SEÇÃO DE DEBUG DO FOV
    if FOVCircle then
        -- Forçamos a visibilidade baseada na global
        FOVCircle.Visible = (_G.ShowFOV == true)
        FOVCircle.Radius = _G.FOV or 100
        FOVCircle.Color = _G.FOVColor or Color3.fromRGB(255, 255, 255)
        FOVCircle.Position = UIS:GetMouseLocation()
    end

    -- Lógica do Aim
    if _G.AimbotEnabled and segurandoBotao then
        local target = getClosestPlayer()
        if target then
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen and mousemoverel then
                local mouseLoc = UIS:GetMouseLocation()
                local moveX = (screenPos.X - mouseLoc.X) * (_G.AimbotSmoothness or 0.15)
                local moveY = (screenPos.Y - mouseLoc.Y) * (_G.AimbotSmoothness or 0.15)
                mousemoverel(moveX, moveY)
            end
        end
    end
end)

-- // Inputs
UIS.InputBegan:Connect(function(i, p) 
    if p then return end 
    if i.UserInputType == (_G.AimbotKey or Enum.UserInputType.MouseButton2) then segurandoBotao = true end 
end)
UIS.InputEnded:Connect(function(i) 
    if i.UserInputType == (_G.AimbotKey or Enum.UserInputType.MouseButton2) then segurandoBotao = false end 
end)

-- // LOOP DE PRINT (Roda a cada 3 segundos para não floodar)
task.spawn(function()
    while task.wait(3) do
        print(string.format("[DEBUG] Aimbot: %s | ShowFOV: %s | Raio: %d", 
            tostring(_G.AimbotEnabled), tostring(_G.ShowFOV), _G.FOV))
    end
end)
