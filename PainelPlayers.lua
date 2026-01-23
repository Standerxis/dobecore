local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// 1. CONFIGURAÇÕES E ESTADOS GLOBAIS
local FOLLOW_CONFIG = {
    Enabled = false,
    Target = nil,
    StopDistance = 5,
    FlyHeightThreshold = 15,
    ThinkRate = 0.05 -- Mais rápido para maior precisão
}

local isSpectating = false
local selectedPlayer = nil
local flying = false
local followBtnReference = nil
local spectateBtnReference = nil
local MAX_ZINDEX = 5000

--// COMPONENTES FÍSICOS PARA VOO
local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

--// 2. CRIAÇÃO DA RAIZ DA UI
local TargetParent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or game:GetService("CoreGui") or LocalPlayer.PlayerGui
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "Complex_PlayerManager"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.DisplayOrder = 100
MainGui.Parent = TargetParent

--// FUNÇÕES AUXILIARES
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local function getCharacterData(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

--// 3. PAINEL PRINCIPAL (GUI)
local Master = Instance.new("CanvasGroup", MainGui)
Master.Size = UDim2.new(0, 450, 0, 300)
Master.Position = UDim2.new(0.5, -225, 0.5, -150)
Master.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Master.Visible = false
Instance.new("UICorner", Master).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Master).Color = Color3.fromRGB(0, 150, 255)
MakeDraggable(Master)

-- Lado Esquerdo (Lista)
local LeftSide = Instance.new("Frame", Master)
LeftSide.Size = UDim2.new(0, 170, 1, -30); LeftSide.Position = UDim2.new(0, 15, 0, 15); LeftSide.BackgroundTransparency = 1

local SearchInput = Instance.new("TextBox", LeftSide)
SearchInput.Size = UDim2.new(1, 0, 0, 35); SearchInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SearchInput.PlaceholderText = "Pesquisar..."; SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255); SearchInput.Font = Enum.Font.GothamMedium; SearchInput.TextSize = 13
Instance.new("UICorner", SearchInput)

local List = Instance.new("ScrollingFrame", LeftSide)
List.Size = UDim2.new(1, 0, 1, -45); List.Position = UDim2.new(0, 0, 0, 45); List.BackgroundTransparency = 1; List.ScrollBarThickness = 0
local ListLayout = Instance.new("UIListLayout", List); ListLayout.Padding = UDim.new(0, 6)

-- Lado Direito (Info/Ações)
local RightSide = Instance.new("Frame", Master)
RightSide.Size = UDim2.new(1, -210, 1, -30); RightSide.Position = UDim2.new(0, 195, 0, 15); RightSide.BackgroundTransparency = 1

local BigIcon = Instance.new("ImageLabel", RightSide)
BigIcon.Size = UDim2.new(0, 80, 0, 80); BigIcon.Position = UDim2.new(0.5, -40, 0, 5); BigIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", BigIcon).CornerRadius = UDim.new(1, 0)

local NameLabel = Instance.new("TextLabel", RightSide)
NameLabel.Size = UDim2.new(1, 0, 0, 25); NameLabel.Position = UDim2.new(0, 0, 0, 90); NameLabel.BackgroundTransparency = 1
NameLabel.Text = "Selecione"; NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255); NameLabel.Font = Enum.Font.GothamBold; NameLabel.TextSize = 14

local BtnScroll = Instance.new("ScrollingFrame", RightSide)
BtnScroll.Size = UDim2.new(1, 0, 1, -125); BtnScroll.Position = UDim2.new(0, 0, 0, 120); BtnScroll.BackgroundTransparency = 1; BtnScroll.ScrollBarThickness = 0
local BtnLayout = Instance.new("UIListLayout", BtnScroll); BtnLayout.Padding = UDim.new(0, 6); BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// 4. LÓGICAS DE MOVIMENTO (THINKING)
local function jumpReaction()
    local _, hum, _ = getCharacterData(LocalPlayer)
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        task.wait(math.random(0.05, 0.12)) -- Reação humana
        hum.Jump = true
    end
end

local function toggleFly(state, hrp, hum)
    if state then
        flying = true
        BV.Parent = hrp
        BG.Parent = hrp
        hum.PlatformStand = true
    else
        flying = false
        BV.Parent = nil
        BG.Parent = nil
        if hum then hum.PlatformStand = false end
    end
end

--// LOOP DE MOVIMENTO COMPLEXO
task.spawn(function()
    while task.wait(FOLLOW_CONFIG.ThinkRate) do
        local myChar, myHum, myHRP = getCharacterData(LocalPlayer)
        
        if not FOLLOW_CONFIG.Enabled or not FOLLOW_CONFIG.Target or not myHRP then 
            if flying then toggleFly(false, myHRP, myHum) end
            continue 
        end

        local tChar, tHum, tHRP = getCharacterData(FOLLOW_CONFIG.Target)
        if not tHRP or not tHum then continue end

        local distance = (tHRP.Position - myHRP.Position).Magnitude
        local heightDiff = tHRP.Position.Y - myHRP.Position.Y
        
        -- Mimetismo de Pulo
        if tHum:GetState() == Enum.HumanoidStateType.Jumping and distance < 20 then
            jumpReaction()
        end

        -- Lógica de Voo/Caminhada
        local isTargetFloating = tHum.FloorMaterial == Enum.Material.Air and heightDiff > 10
        
        if isTargetFloating or heightDiff > FOLLOW_CONFIG.FlyHeightThreshold then
            if not flying then toggleFly(true, myHRP, myHum) end
            BG.CFrame = CFrame.new(myHRP.Position, tHRP.Position)
            local targetPos = tHRP.Position - (tHRP.CFrame.LookVector * 4)
            BV.Velocity = (targetPos - myHRP.Position).Unit * 60
        else
            if flying and heightDiff < 5 then toggleFly(false, myHRP, myHum) end
            if distance > FOLLOW_CONFIG.StopDistance then
                myHum:MoveTo(tHRP.Position)
            end
        end

        -- Anti-Stuck
        if myHum.MoveDirection.Magnitude > 0 and myHRP.Velocity.Magnitude < 1 and not flying then
            jumpReaction()
        end
    end
end)

--// 5. FUNÇÕES DOS BOTÕES
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton", BtnScroll)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(45, 45, 50); b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 12
    Instance.new("UICorner", b)
    if txt == "Follow" then followBtnReference = b elseif txt == "Spectate" then spectateBtnReference = b end
    b.MouseButton1Click:Connect(function() if selectedPlayer then callback(selectedPlayer) end end)
end

--// SPECTATE
local function ToggleSpectate(p)
    local Camera = workspace.CurrentCamera
    if isSpectating or not p then
        isSpectating = false
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        if spectateBtnReference then spectateBtnReference.Text = "Spectate"; spectateBtnReference.BackgroundColor3 = Color3.fromRGB(45, 45, 50) end
    else
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            isSpectating = true
            Camera.CameraSubject = p.Character.Humanoid
            spectateBtnReference.Text = "Stop Spectate"; spectateBtnReference.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end
end

-- Criação dos botões de ação
CreateBtn("Follow", function(p)
    if FOLLOW_CONFIG.Enabled and FOLLOW_CONFIG.Target == p then
        FOLLOW_CONFIG.Enabled = false
        FOLLOW_CONFIG.Target = nil
        followBtnReference.Text = "Follow"; followBtnReference.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    else
        FOLLOW_CONFIG.Enabled = true
        FOLLOW_CONFIG.Target = p
        followBtnReference.Text = "Stop Follow"; followBtnReference.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

CreateBtn("Spectate", function(p) ToggleSpectate(p) end)
CreateBtn("Teleport", function(p) if p.Character then LocalPlayer.Character:PivotTo(p.Character:GetPivot()) end end)

--// 6. LISTA DE PLAYERS E ATUALIZAÇÃO
local function CreateRow(p)
    local Row = Instance.new("TextButton", List)
    Row.Size = UDim2.new(1, -8, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(35, 35, 40); Row.Text = ""; Instance.new("UICorner", Row)
    
    local MiniIcon = Instance.new("ImageLabel", Row)
    MiniIcon.Size = UDim2.new(0, 32, 0, 32); MiniIcon.Position = UDim2.new(0, 8, 0.5, -16); MiniIcon.BackgroundTransparency = 1
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)
    task.spawn(function() MiniIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)

    local PlayerName = Instance.new("TextLabel", Row)
    PlayerName.Size = UDim2.new(1, -55, 1, 0); PlayerName.Position = UDim2.new(0, 48, 0, 0); PlayerName.BackgroundTransparency = 1; PlayerName.Text = p.DisplayName; PlayerName.TextColor3 = Color3.fromRGB(220, 220, 220); PlayerName.Font = Enum.Font.GothamMedium; PlayerName.TextSize = 12; PlayerName.TextXAlignment = Enum.TextXAlignment.Left

    Row.MouseButton1Click:Connect(function()
        selectedPlayer = p
        NameLabel.Text = p.DisplayName
        BigIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        
        -- Atualiza visual do botão Follow baseado no novo player selecionado
        if FOLLOW_CONFIG.Enabled and FOLLOW_CONFIG.Target == p then
            followBtnReference.Text = "Stop Follow"; followBtnReference.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        else
            followBtnReference.Text = "Follow"; followBtnReference.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        end
    end)
end

local function Refresh()
    for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in pairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer and (SearchInput.Text == "" or string.find(p.DisplayName:lower(), SearchInput.Text:lower())) then 
            CreateRow(p) 
        end 
    end
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(Refresh)
Players.PlayerAdded:Connect(Refresh); Players.PlayerRemoving:Connect(Refresh)
Refresh()

-- Tecla para abrir (Fim da página ou Custom)
_G.TogglePlayerPanel = function()
    Master.Visible = not Master.Visible
end

-- Exemplo: Abrir com a tecla 'L'
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.L then
        _G.TogglePlayerPanel()
    end
end)
