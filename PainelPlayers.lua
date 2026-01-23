local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// 1. CRIAÇÃO DA RAIZ
local TargetParent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or game:GetService("CoreGui") or LocalPlayer.PlayerGui

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "Independent_PlayerManager"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.DisplayOrder = 100
MainGui.Parent = TargetParent

--// CONFIGURAÇÕES
local MAX_ZINDEX = 5000
local followBtnReference = nil
local spectateBtnReference = nil
local isSpectating = false
local selectedPlayer = nil
local FOLLOW_STATE = { Enabled = false, Target = nil }

--// FUNÇÃO DRAGGABLE
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

--// 2. PAINEL DE BACKPACK (PREMIUM DESIGN)
local BP_Master = Instance.new("Frame", MainGui)
BP_Master.Name = "BackpackView_Custom"
BP_Master.Size = UDim2.new(0, 320, 0, 160)
BP_Master.Position = UDim2.new(0.5, 235, 0.5, -80)
BP_Master.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
BP_Master.Visible = false
BP_Master.ZIndex = MAX_ZINDEX
Instance.new("UICorner", BP_Master).CornerRadius = UDim.new(0, 14)
local BP_Stroke = Instance.new("UIStroke", BP_Master)
BP_Stroke.Color = Color3.fromRGB(0, 150, 255)
BP_Stroke.Thickness = 1.5
BP_Stroke.Transparency = 0.5
MakeDraggable(BP_Master)

local BP_Title = Instance.new("TextLabel", BP_Master)
BP_Title.Size = UDim2.new(1, -40, 0, 40)
BP_Title.Position = UDim2.new(0, 15, 0, 0)
BP_Title.Text = "📦 INVENTÁRIO"
BP_Title.TextColor3 = Color3.fromRGB(255, 255, 255)
BP_Title.BackgroundTransparency = 1
BP_Title.Font = Enum.Font.GothamBold
BP_Title.TextSize = 14
BP_Title.TextXAlignment = Enum.TextXAlignment.Left
BP_Title.ZIndex = MAX_ZINDEX + 1

local CloseBP = Instance.new("TextButton", BP_Master)
CloseBP.Size = UDim2.new(0, 25, 0, 25)
CloseBP.Position = UDim2.new(1, -35, 0, 10)
CloseBP.Text = "×"
CloseBP.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBP.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBP.Font = Enum.Font.GothamBold
CloseBP.TextSize = 20
CloseBP.ZIndex = MAX_ZINDEX + 2
Instance.new("UICorner", CloseBP)
CloseBP.MouseButton1Click:Connect(function() BP_Master.Visible = false end)

local BP_Container = Instance.new("Frame", BP_Master)
BP_Container.Size = UDim2.new(1, -30, 1, -65)
BP_Container.Position = UDim2.new(0, 15, 0, 55)
BP_Container.BackgroundTransparency = 1
BP_Container.ZIndex = MAX_ZINDEX + 1
local BP_Layout = Instance.new("UIListLayout", BP_Container)
BP_Layout.FillDirection = Enum.FillDirection.Horizontal
BP_Layout.Padding = UDim.new(0, 10)
BP_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// 3. PAINEL PRINCIPAL
local Master = Instance.new("CanvasGroup", MainGui)
Master.Size = UDim2.new(0, 450, 0, 300)
Master.Position = UDim2.new(0.5, -225, 0.5, -150)
Master.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Master.Visible = false
Master.ZIndex = 1
Instance.new("UICorner", Master).CornerRadius = UDim.new(0, 12)
MakeDraggable(Master)
Instance.new("UIStroke", Master).Color = Color3.fromRGB(0, 150, 255)

--// ESTRUTURA INTERNA
local LeftSide = Instance.new("Frame", Master)
LeftSide.Size = UDim2.new(0, 170, 1, -30); LeftSide.Position = UDim2.new(0, 15, 0, 15); LeftSide.BackgroundTransparency = 1; LeftSide.ZIndex = 2

local SearchFrame = Instance.new("Frame", LeftSide)
SearchFrame.Size = UDim2.new(1, 0, 0, 35); SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); SearchFrame.ZIndex = 3
Instance.new("UICorner", SearchFrame)

local SearchInput = Instance.new("TextBox", SearchFrame)
SearchInput.Text = ""
SearchInput.Size = UDim2.new(1, -10, 1, 0); SearchInput.Position = UDim2.new(0, 5, 0, 0); SearchInput.BackgroundTransparency = 1
SearchInput.PlaceholderText = "Pesquisar..."; SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255); SearchInput.Font = Enum.Font.GothamMedium; SearchInput.TextSize = 13; SearchInput.ZIndex = 4

local List = Instance.new("ScrollingFrame", LeftSide)
List.Size = UDim2.new(1, 0, 1, -45); List.Position = UDim2.new(0, 0, 0, 45); List.BackgroundTransparency = 1; List.ZIndex = 3; List.ScrollBarThickness = 0
local ListLayout = Instance.new("UIListLayout", List); ListLayout.Padding = UDim.new(0, 6)

local RightSide = Instance.new("Frame", Master)
RightSide.Size = UDim2.new(1, -210, 1, -30); RightSide.Position = UDim2.new(0, 195, 0, 15); RightSide.BackgroundTransparency = 1; RightSide.ZIndex = 2

local BigIcon = Instance.new("ImageLabel", RightSide)
BigIcon.Size = UDim2.new(0, 80, 0, 80); BigIcon.Position = UDim2.new(0.5, -40, 0, 5); BigIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 35); BigIcon.ZIndex = 6
Instance.new("UICorner", BigIcon).CornerRadius = UDim.new(1, 0)

local NameLabel = Instance.new("TextLabel", RightSide)
NameLabel.Size = UDim2.new(1, 0, 0, 25); NameLabel.Position = UDim2.new(0, 0, 0, 90); NameLabel.BackgroundTransparency = 1; NameLabel.ZIndex = 6
NameLabel.Text = "Selecione"; NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255); NameLabel.Font = Enum.Font.GothamBold; NameLabel.TextSize = 14

local BtnScroll = Instance.new("ScrollingFrame", RightSide)
BtnScroll.Size = UDim2.new(1, 0, 1, -125); BtnScroll.Position = UDim2.new(0, 0, 0, 120); BtnScroll.BackgroundTransparency = 1; BtnScroll.ZIndex = 7; BtnScroll.ScrollBarThickness = 0
local BtnLayout = Instance.new("UIListLayout", BtnScroll); BtnLayout.Padding = UDim.new(0, 6); BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// LÓGICA DE FUNCIONALIDADES
local function CreateItemView(itemName, equipped)
    local Frame = Instance.new("Frame", BP_Container)
    Frame.Size = UDim2.new(0, 80, 0, 80); Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", Frame)
    if equipped then Instance.new("UIStroke", Frame).Color = Color3.fromRGB(0, 255, 150) end
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 1, 0); Label.Text = itemName; Label.TextColor3 = Color3.fromRGB(255, 255, 255); Label.Font = Enum.Font.GothamMedium; Label.TextSize = 10; Label.BackgroundTransparency = 1; Label.TextWrapped = true
end

local function UpdateBackpackView(p)
    BP_Container:ClearAllChildren()
    BP_Master.Visible = true
    local count = 0
    if p.Character then
        local tool = p.Character:FindFirstChildOfClass("Tool")
        if tool then CreateItemView(tool.Name, true); count += 1 end
    end
    for _, tool in pairs(p.Backpack:GetChildren()) do
        if count < 3 then CreateItemView(tool.Name, false); count += 1 end
    end
end

--// SPECTATE LOGIC
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
            spectateBtnReference.Text = "Stop Spectate"
            spectateBtnReference.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end
end

--// BOTÕES
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton", BtnScroll)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(45, 45, 50); b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.ZIndex = 8
    Instance.new("UICorner", b)
    if txt == "Follow" then followBtnReference = b elseif txt == "Spectate" then spectateBtnReference = b end
    b.MouseButton1Click:Connect(function() if selectedPlayer then callback(selectedPlayer) end end)
end

local FOLLOW_CONFIG = {
    Enabled = false,
    Target = nil,
    StopDistance = 5,
    FlyHeightThreshold = 15, -- Se o alvo estiver acima disso, voamos
    ThinkRate = 0.1
}

local isSpectating = false
local selectedPlayer = nil
local flying = false

--// COMPONENTES FÍSICOS PARA VOO
local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

--// 2. FUNÇÕES DE SUPORTE (LÓGICA HUMANA)
local function getCharacterData(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

local function jumpReaction()
    local _, hum, _ = getCharacterData(LocalPlayer)
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        task.wait(math.random(0.05, 0.15)) -- Delay humano
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

--// 3. SISTEMA DE VOO INTEGADO
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
        hum.PlatformStand = false
    end
end

--// 4. LOOP PRINCIPAL DE PENSAMENTO (BRAIN)
task.spawn(function()
    while task.wait(FOLLOW_CONFIG.ThinkRate) do
        if not FOLLOW_CONFIG.Enabled or not FOLLOW_CONFIG.Target then 
            if flying then toggleFly(false, getCharacterData(LocalPlayer)) end
            continue 
        end

        local myChar, myHum, myHRP = getCharacterData(LocalPlayer)
        local tChar, tHum, tHRP = getCharacterData(FOLLOW_CONFIG.Target)

        if not myHRP or not tHRP or not tHum then continue end

        local distance = (tHRP.Position - myHRP.Position).Magnitude
        local heightDiff = tHRP.Position.Y - myHRP.Position.Y
        
        -- LÓGICA DE PULO (Mimetismo)
        if tHum:GetState() == Enum.HumanoidStateType.Jumping or tHum:GetState() == Enum.HumanoidStateType.Freefall then
            if heightDiff > 2 and heightDiff < FOLLOW_CONFIG.FlyHeightThreshold then
                jumpReaction()
            end
        end

        -- LÓGICA DE VOO (Se o alvo estiver voando ou muito alto)
        local isTargetFloating = tHum.FloorMaterial == Enum.Material.Air and heightDiff > 10
        
        if isTargetFloating or heightDiff > FOLLOW_CONFIG.FlyHeightThreshold then
            if not flying then toggleFly(true, myHRP, myHum) end
            
            BG.CFrame = CFrame.new(myHRP.Position, tHRP.Position)
            local targetPos = tHRP.Position - (tHRP.CFrame.LookVector * 4)
            BV.Velocity = (targetPos - myHRP.Position).Unit * 50
        else
            if flying and heightDiff < 5 then toggleFly(false, myHRP, myHum) end
            
            -- MOVIMENTO TERRESTRE
            if distance > FOLLOW_CONFIG.StopDistance then
                myHum:MoveTo(tHRP.Position)
            end
        end

        -- ANTI-STUCK (Se estiver parado batendo na parede)
        if myHum.MoveDirection.Magnitude > 0 and myHRP.Velocity.Magnitude < 1 and not flying then
            jumpReaction()
        end
    end
end)

--// 5. INTEGRAÇÃO COM SEU BOTÃO DE FOLLOW
-- No seu script original, substitua a função do botão Follow por esta:
local function onFollowClick(p)
    if FOLLOW_CONFIG.Enabled and FOLLOW_CONFIG.Target == p then
        FOLLOW_CONFIG.Enabled = false
        FOLLOW_CONFIG.Target = nil
        print("Follow Desativado")
    else
        FOLLOW_CONFIG.Enabled = true
        FOLLOW_CONFIG.Target = p
        print("Seguindo: " .. p.Name)
    end
end

CreateBtn("Follow", function(p)
    -- Verifica se já está seguindo este player específico
    if FOLLOW_CONFIG.Enabled and FOLLOW_CONFIG.Target == p then
        -- Desativa o sistema
        FOLLOW_CONFIG.Enabled = false
        FOLLOW_CONFIG.Target = nil
        
        -- Feedback Visual (Botão volta ao normal)
        followBtnReference.Text = "Follow"
        followBtnReference.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    else
        -- Ativa o sistema para o player selecionado
        FOLLOW_CONFIG.Enabled = true
        FOLLOW_CONFIG.Target = p
        
        -- Feedback Visual (Botão fica vermelho indicando que pode parar)
        followBtnReference.Text = "Stop Follow"
        followBtnReference.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        
        -- Opcional: Avisar no chat ou console para teste
        print("Iniciando lógica complexa de seguimento em: " .. p.Name)
    end
end)

CreateBtn("Spectate", function(p) ToggleSpectate(p) end)
CreateBtn("Teleport", function(p) if p.Character then LocalPlayer.Character:PivotTo(p.Character:GetPivot()) end end)
CreateBtn("View Backpack", function(p) UpdateBackpackView(p) end)

--// LISTA DE PLAYERS
local function CreateRow(p)
    local Row = Instance.new("TextButton", List)
    Row.Size = UDim2.new(1, -8, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(35, 35, 40); Row.Text = ""; Row.ZIndex = 4; Instance.new("UICorner", Row)
    
    local MiniIcon = Instance.new("ImageLabel", Row)
    MiniIcon.Size = UDim2.new(0, 32, 0, 32); MiniIcon.Position = UDim2.new(0, 8, 0.5, -16); MiniIcon.BackgroundTransparency = 1; MiniIcon.ZIndex = 5
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)
    task.spawn(function() MiniIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)

    local PlayerName = Instance.new("TextLabel", Row)
    PlayerName.Size = UDim2.new(1, -55, 1, 0); PlayerName.Position = UDim2.new(0, 48, 0, 0); PlayerName.BackgroundTransparency = 1; PlayerName.Text = p.DisplayName; PlayerName.TextColor3 = Color3.fromRGB(220, 220, 220); PlayerName.Font = Enum.Font.GothamMedium; PlayerName.TextSize = 12; PlayerName.TextXAlignment = Enum.TextXAlignment.Left; PlayerName.ZIndex = 5

    Row.MouseButton1Click:Connect(function()
        selectedPlayer = p
        NameLabel.Text = p.DisplayName
        BigIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        
        -- Reset Buttons visual
        local isF = (FOLLOW_STATE.Enabled and FOLLOW_STATE.Target == p)
        followBtnReference.Text = isF and "Stop Follow" or "Follow"
        followBtnReference.BackgroundColor3 = isF and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(45, 45, 50)
    end)
end

--// REFRESH & LOOP
local function Refresh()
    for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in pairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer and (SearchInput.Text == "" or string.find(p.DisplayName:lower(), SearchInput.Text:lower())) then 
            CreateRow(p) 
        end 
    end
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(Refresh)
Players.PlayerAdded:Connect(Refresh); Players.PlayerRemoving:Connect(Refresh); Refresh()


Refresh()

_G.TogglePlayerPanel = function()
    Master.Visible = not Master.Visible
    Master.GroupTransparency = Master.Visible and 0 or 1
end
