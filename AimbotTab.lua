local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações Globais (Lidas pela sua UI)
_G.AimbotEnabled = _G.AimbotEnabled or true
_G.AimbotFOV = _G.AimbotFOV or 150
_G.AimbotSmoothness = _G.AimbotSmoothness or 0.15 -- Se quiser que grude instantâneo, use 1.0
_G.ShowFOV = _G.ShowFOV or true
_G.AimbotKey = _G.AimbotKey or Enum.UserInputType.MouseButton2
_G.AimbotFOVColor = _G.AimbotFOVColor or Color3.fromRGB(255, 255, 255)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Transparency = 1
FOVCircle.Filled = false

local segurandoBotao = false

-- Função para verificar se o inimigo está atrás da parede
local function isVisible(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, targetPart.Parent}
    
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, params)
    return result == nil
end

-- Busca o jogador mais próximo do CURSOR
local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.AimbotFOV
    local mousePos = UIS:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                -- Projetamos a cabeça 3D para o ponto 2D da tela
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen and isVisible(head) then
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        target = {part = head, screenPos = Vector2.new(pos.X, pos.Y)}
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- Gerenciamento de Teclas
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local activeBind = (_G.AimbotKey == Enum.KeyCode.Unknown) and Enum.UserInputType.MouseButton2 or _G.AimbotKey
    if input.KeyCode == activeBind or input.UserInputType == activeBind then
        segurandoBotao = true
    end
end)

UIS.InputEnded:Connect(function(input)
    local activeBind = (_G.AimbotKey == Enum.KeyCode.Unknown) and Enum.UserInputType.MouseButton2 or _G.AimbotKey
    if input.KeyCode == activeBind or input.UserInputType == activeBind then
        segurandoBotao = false
    end
end)

-- Loop de Atualização (RenderStepped roda antes de cada frame)
RS.RenderStepped:Connect(function()
    local mouseLocation = UIS:GetMouseLocation()
    
    -- Atualização Visual do FOV
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = mouseLocation
    FOVCircle.Color = _G.AimbotFOVColor

    if _G.AimbotEnabled and segurandoBotao then
        local targetData = getClosestPlayer()
        
        if targetData then
            -- O Cálculo do Delta: Diferença entre a cabeça e o mouse atual
            -- Usamos LaTeX para representar a variação necessária:
            -- $\Delta X = (X_{alvo} - X_{mouse}) \cdot suavidade$
            
            local moveX = (targetData.screenPos.X - mouseLocation.X) * (_G.AimbotSmoothness or 0.2)
            local moveY = (targetData.screenPos.Y - mouseLocation.Y) * (_G.AimbotSmoothness or 0.2)

            if mousemoverel then
                -- mousemoverel é "físico", ele ignora se você está em 1ª ou 3ª pessoa.
                -- Ele move o cursor X pixels a partir de onde ele já está.
                mousemoverel(moveX, moveY)
            else
                -- Fallback para executores que não suportam movimentação relativa
                local lookAt = CFrame.new(Camera.CFrame.Position, targetData.part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness or 0.1)
            end
        end
    end
end)
