local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações Globais
_G.AimbotEnabled = _G.AimbotEnabled or true
_G.AimbotFOV = _G.AimbotFOV or 150
_G.ShowFOV = _G.ShowFOV or true
_G.AimbotSmoothness = _G.AimbotSmoothness or 0.15 -- No mousemoverel, valores baixos são mais suaves
_G.AimbotKey = _G.AimbotKey or Enum.UserInputType.MouseButton2

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local segurandoBotao = false

local function getClosestPlayer()
    local target = nil
    local shortestDistance = _G.AimbotFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                -- Converte a posição 3D da cabeça para 2D na sua tela
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

RS.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = UIS:GetMouseLocation()

    if _G.AimbotEnabled and segurandoBotao then
        local targetPart = getClosestPlayer()
        
        if targetPart then
            local mouseLocation = UIS:GetMouseLocation()
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                -- Calcula a distância que o mouse precisa percorrer
                local targetVector = Vector2.new(screenPos.X, screenPos.Y)
                local mouseMoveVector = (targetVector - mouseLocation) * _G.AimbotSmoothness
                
                -- O segredo para a Terceira Pessoa: mover o cursor propriamente dito
                if mousemoverel then
                    mousemoverel(mouseMoveVector.X, mouseMoveVector.Y)
                else
                    -- Fallback caso o executor não tenha mousemoverel (menos preciso em 3ª pessoa)
                    local lookAtGoal = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(lookAtGoal, _G.AimbotSmoothness)
                end
            end
        end
    end
end)
