local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Inicialização de Variáveis Globais (caso não estejam definidas)
_G.AimbotEnabled = _G.AimbotEnabled or true
_G.AimbotFOV = _G.AimbotFOV or 150
_G.ShowFOV = _G.ShowFOV or true
_G.AimbotSmoothness = _G.AimbotSmoothness or 0.15 -- Ajuste entre 0.1 e 0.3
_G.AimbotKey = _G.AimbotKey or Enum.UserInputType.MouseButton2

-- Configuração do Círculo de FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local segurandoBotao = false

-- Função para encontrar o alvo mais próximo do centro da tela
local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.AimbotFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local mouseLocation = UIS:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude
                    
                    if distance < shortestDistance then
                        target = head
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- Detecção de Clique
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == _G.AimbotKey or input.KeyCode == _G.AimbotKey then
        segurandoBotao = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == _G.AimbotKey or input.KeyCode == _G.AimbotKey then
        segurandoBotao = false
    end
end)

-- Loop de Renderização (Onde a mágica acontece)
RS.RenderStepped:Connect(function()
    -- Gerenciamento do Círculo de FOV
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Color = _G.AimbotFOVColor or Color3.fromRGB(255, 255, 255)
    FOVCircle.Position = UIS:GetMouseLocation()

    if _G.AimbotEnabled and segurandoBotao then
        local targetPart = getClosestPlayer()
        
        if targetPart then
            -- Para cravar em 3ª pessoa, precisamos alinhar a Câmera com a posição do alvo
            -- Usamos a posição atual da câmera para manter o zoom e o ângulo, mas giramos para o alvo
            local lookAtGoal = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            
            -- O Lerp faz a suavidade. Se quiser 100% cravado instantâneo, use Smoothness = 1
            Camera.CFrame = Camera.CFrame:Lerp(lookAtGoal, _G.AimbotSmoothness)
        end
    end
end)
