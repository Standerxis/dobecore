local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Standerxis/dobecore/refs/heads/main/lib.lua"
))()
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


--// CONFIGURAÇÕES DE PROFUNDIDADE
local MAX_ZINDEX = 5000
local ParentGui = Library.ScreenGui 

if ParentGui:IsA("ScreenGui") then
    ParentGui.DisplayOrder = 100 
end

--// FUNÇÃO REUTILIZÁVEL PARA TORNAR DRAGGABLE
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

--// PAINEL DE BACKPACK (CORRIGIDO E DRAGGABLE)
local BP_Master = Instance.new("Frame", ParentGui)
BP_Master.Name = "BackpackView_Custom"
BP_Master.Size = UDim2.new(0, 300, 0, 150)
BP_Master.Position = UDim2.new(0.5, 235, 0.5, -75)
BP_Master.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BP_Master.Visible = false
BP_Master.ZIndex = MAX_ZINDEX
Instance.new("UICorner", BP_Master).CornerRadius = UDim.new(0, 10)
local BP_Stroke = Instance.new("UIStroke", BP_Master)
BP_Stroke.Color = Color3.fromRGB(0, 150, 255)
BP_Stroke.Thickness = 2
MakeDraggable(BP_Master)

local BP_Title = Instance.new("TextLabel", BP_Master)
BP_Title.Size = UDim2.new(1, -30, 0, 30)
BP_Title.Position = UDim2.new(0, 10, 0, 0)
BP_Title.Text = "INVENTÁRIO (Limite 3)"
BP_Title.TextColor3 = Color3.fromRGB(255, 255, 255)
BP_Title.BackgroundTransparency = 1
BP_Title.Font = Enum.Font.GothamBold
BP_Title.TextSize = 13
BP_Title.TextXAlignment = Enum.TextXAlignment.Left
BP_Title.ZIndex = MAX_ZINDEX + 1

local CloseBP = Instance.new("TextButton", BP_Master)
CloseBP.Size = UDim2.new(0, 25, 0, 25)
CloseBP.Position = UDim2.new(1, -30, 0, 5)
CloseBP.Text = "X"
CloseBP.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBP.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBP.Font = Enum.Font.GothamBold
CloseBP.ZIndex = MAX_ZINDEX + 2
Instance.new("UICorner", CloseBP)
CloseBP.MouseButton1Click:Connect(function() BP_Master.Visible = false end)

local BP_Container = Instance.new("Frame", BP_Master)
BP_Container.Size = UDim2.new(1, -20, 1, -50)
BP_Container.Position = UDim2.new(0, 10, 0, 45)
BP_Container.BackgroundTransparency = 1
BP_Container.ZIndex = MAX_ZINDEX + 1

local BP_Layout = Instance.new("UIListLayout", BP_Container)
BP_Layout.FillDirection = Enum.FillDirection.Horizontal
BP_Layout.Padding = UDim.new(0, 10)
BP_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// PAINEL PRINCIPAL
local Master = Instance.new("CanvasGroup", ParentGui)
Master.Name = "PlayerManager_Custom"
Master.Size = UDim2.new(0, 450, 0, 300)
Master.Position = UDim2.new(0.5, -225, 0.5, -150)
Master.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Master.ZIndex = MAX_ZINDEX
Master.Visible = false
Master.GroupTransparency = 1
Instance.new("UICorner", Master).CornerRadius = UDim.new(0, 12)
MakeDraggable(Master)

local MasterStroke = Instance.new("UIStroke", Master)
MasterStroke.Color = Color3.fromRGB(0, 150, 255)
MasterStroke.Thickness = 2
MasterStroke.ZIndex = MAX_ZINDEX

--// LADO ESQUERDO
local LeftSide = Instance.new("Frame", Master)
LeftSide.Size = UDim2.new(0, 170, 1, -30)
LeftSide.Position = UDim2.new(0, 15, 0, 15)
LeftSide.BackgroundTransparency = 1
LeftSide.ZIndex = MAX_ZINDEX

local SearchFrame = Instance.new("Frame", LeftSide)
SearchFrame.Size = UDim2.new(1, 0, 0, 35)
SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SearchFrame.ZIndex = MAX_ZINDEX
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)

local SearchInput = Instance.new("TextBox", SearchFrame)
SearchInput.Size = UDim2.new(1, -10, 1, 0)
SearchInput.Position = UDim2.new(0, 5, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.Text = ""
SearchInput.PlaceholderText = "Pesquisar..."
SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.TextSize = 13
SearchInput.ZIndex = MAX_ZINDEX + 1

local List = Instance.new("ScrollingFrame", LeftSide)
List.Size = UDim2.new(1, 0, 1, -45)
List.Position = UDim2.new(0, 0, 0, 45)
List.BackgroundTransparency = 1
List.ScrollBarThickness = 2
List.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
List.ZIndex = MAX_ZINDEX
local ListLayout = Instance.new("UIListLayout", List)
ListLayout.Padding = UDim.new(0, 6)

--// LADO DIREITO
local RightSide = Instance.new("Frame", Master)
RightSide.Size = UDim2.new(1, -210, 1, -30)
RightSide.Position = UDim2.new(0, 195, 0, 15)
RightSide.BackgroundTransparency = 1
RightSide.ZIndex = MAX_ZINDEX

local BigIcon = Instance.new("ImageLabel", RightSide)
BigIcon.Size = UDim2.new(0, 80, 0, 80)
BigIcon.Position = UDim2.new(0.5, -40, 0, 5)
BigIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BigIcon.ZIndex = MAX_ZINDEX
Instance.new("UICorner", BigIcon).CornerRadius = UDim.new(1, 0)

local NameLabel = Instance.new("TextLabel", RightSide)
NameLabel.Size = UDim2.new(1, 0, 0, 25)
NameLabel.Position = UDim2.new(0, 0, 0, 90)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "Selecione"
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 14
NameLabel.ZIndex = MAX_ZINDEX

local BtnScroll = Instance.new("ScrollingFrame", RightSide)
BtnScroll.Size = UDim2.new(1, 0, 1, -125)
BtnScroll.Position = UDim2.new(0, 0, 0, 120)
BtnScroll.BackgroundTransparency = 1
BtnScroll.ScrollBarThickness = 2
BtnScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
BtnScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
BtnScroll.ZIndex = MAX_ZINDEX
local BtnLayout = Instance.new("UIListLayout", BtnScroll)
BtnLayout.Padding = UDim.new(0, 6)
BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// LÓGICA DA VIEWPORT PROFISSIONAL (A MÁGICA)
local function CreateItemView(itemName, equipped)
    local Frame = Instance.new("Frame", BP_Container)
    Frame.Size = UDim2.new(0, 80, 0, 80)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Frame.ZIndex = MAX_ZINDEX + 2
    Instance.new("UICorner", Frame)
    
    if equipped then
        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Color = Color3.fromRGB(0, 255, 150)
        Stroke.Thickness = 2
    end

    -- Label do nome do item
    local ItemNameLabel = Instance.new("TextLabel", Frame)
    ItemNameLabel.Size = UDim2.new(1, -4, 0, 15)
    ItemNameLabel.BackgroundTransparency = 1
    ItemNameLabel.Text = itemName
    ItemNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ItemNameLabel.Font = Enum.Font.GothamMedium
    ItemNameLabel.TextSize = 8
    ItemNameLabel.ZIndex = MAX_ZINDEX + 5

    local Viewport = Instance.new("ViewportFrame", Frame)
    Viewport.Size = UDim2.new(1, 0, 0.8, 0)
    Viewport.Position = UDim2.new(0,0,0,0)
    Viewport.BackgroundTransparency = 1
    Viewport.ZIndex = MAX_ZINDEX + 3
    Viewport.Ambient = Color3.fromRGB(200, 200, 200)

    -- MAGIA PARA ACHAR O MODELO COMPLETO
    local targetModel = ReplicatedStorage:FindFirstChild(itemName, true) or workspace:FindFirstChild(itemName, true)
    
    if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
        -- POSIÇÃO SE ENCONTRAR MODELO: Nome embaixo
        ItemNameLabel.Position = UDim2.new(0, 2, 1, -17)
        ItemNameLabel.TextYAlignment = Enum.TextYAlignment.Bottom

        local clone = targetModel:Clone()
        clone.Parent = Viewport
        
        local cam = Instance.new("Camera", Viewport)
        Viewport.CurrentCamera = cam
        
        local cf, size
        if clone:IsA("Model") then
            cf, size = clone:GetBoundingBox()
        else
            cf = clone.CFrame
            size = clone.Size
        end
        
        local maxSide = math.max(size.X, size.Y, size.Z)
        local distance = maxSide * 1.8 
        cam.CFrame = CFrame.new(cf.Position + (cf.LookVector * distance) + Vector3.new(0, distance/2, 0), cf.Position)
    else
        -- POSIÇÃO SE NÃO ENCONTRAR: Nome no meio
        Viewport:Destroy() -- Remove viewport vazia
        ItemNameLabel.Size = UDim2.new(1,0,1,0)
        ItemNameLabel.Position = UDim2.new(0,0,0,0)
        ItemNameLabel.TextSize = 10
        ItemNameLabel.TextWrapped = true
        ItemNameLabel.TextYAlignment = Enum.TextYAlignment.Center
    end
end

local lastTarget = nil
local function UpdateBackpackView(p)
    -- Lógica de Toggle: Se clicar no mesmo cara, fecha.
    if BP_Master.Visible and lastTarget == p then
        BP_Master.Visible = false
        return
    end

    lastTarget = p
    for _, v in pairs(BP_Container:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end end
    BP_Master.Visible = true
    
    local count = 0
    if p.Character then
        local tool = p.Character:FindFirstChildOfClass("Tool")
        if tool then CreateItemView(tool.Name, true); count += 1 end
    end
    for _, tool in pairs(p.Backpack:GetChildren()) do
        if count < 3 then CreateItemView(tool.Name, false); count += 1 end
    end

    if count == 0 then
        local none = Instance.new("TextLabel", BP_Container)
        none.Size = UDim2.new(1,0,1,0)
        none.BackgroundTransparency = 1
        none.Text = "NENHUM ITEM"
        none.TextColor3 = Color3.fromRGB(100,100,100)
        none.Font = Enum.Font.Gotham
        none.TextSize = 12
    end
end

--// OUTRAS FUNÇÕES ORIGINAIS
local isSpectating = false
local function ToggleSpectate(p)
    isSpectating = not isSpectating
    if isSpectating then
        workspace.CurrentCamera.CameraSubject = p.Character:FindFirstChild("Humanoid")
        return "UNSPECTATE"
    else
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        return "SPECTATE"
    end
end

local selectedPlayer = nil
local function Select(p)
    selectedPlayer = p
    NameLabel.Text = p.DisplayName
    BigIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    BP_Master.Visible = false
end

local function CreateRow(p)
    local Row = Instance.new("TextButton", List)
    Row:SetAttribute("Username", p.Name:lower())
    Row:SetAttribute("DisplayName", p.DisplayName:lower())

    Row.Size = UDim2.new(1, -8, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Row.Text = ""; Row.ZIndex = MAX_ZINDEX + 1
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local MiniIcon = Instance.new("ImageLabel", Row)
    MiniIcon.Size = UDim2.new(0, 30, 0, 30)
    MiniIcon.Position = UDim2.new(0, 5, 0.5, -15)
    MiniIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MiniIcon.ZIndex = MAX_ZINDEX + 2
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        MiniIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)

    local Text = Instance.new("TextLabel", Row)
    Text.Name = "PlayerNameLabel"
    Text.Size = UDim2.new(1, -45, 1, 0)
    Text.Position = UDim2.new(0, 40, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = p.DisplayName
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 11
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.ZIndex = MAX_ZINDEX + 2

    Row.MouseButton1Click:Connect(function() Select(p) end)
end

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton", BtnScroll)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.ZIndex = MAX_ZINDEX + 1
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() 
        if selectedPlayer then 
            local res = callback(selectedPlayer)
            if res then b.Text = res end
        end 
    end)
end


-- =========================
-- CONFIGURAÇÕES
-- =========================
local SETTINGS = {
    THINK_DT = 0.08,
    STOP_DIST = 4,
    FAR_DIST = 45,
    TP_HEIGHT = 30,
    FLY_HEIGHT = 18,
    AIR_STATIC_HEIGHT = 25,
    JUMP_OBS_HEIGHT = 4,
    MAX_OBS_HEIGHT = 7,
    FLY_SPEED = 60
}

local FOLLOW_STATE = {
    Enabled = false,
    Target = nil
}

-- Variáveis de Estado
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart
local lastTargetPos
local stoppedTime = 0
local isFlying = false

-- Raycast Params Reutilizável
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- =========================
-- COMPONENTES FÍSICOS
-- =========================
local BodyVel = Instance.new("BodyVelocity")
BodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)

local BodyGyro = Instance.new("BodyGyro")
BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

-- =========================
-- FUNÇÕES AUXILIARES
-- =========================

local function SetupCharacter(newChar)
    Character = newChar or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    rayParams.FilterDescendantsInstances = {Character}
end

local function ToggleFly(state)
    isFlying = state
    BodyVel.Parent = state and RootPart or nil
    BodyGyro.Parent = state and RootPart or nil
    if Humanoid then Humanoid.PlatformStand = state end
end

local function GetGroundDistance(pos)
    local result = Workspace:Raycast(pos, Vector3.new(0, -600, 0), rayParams)
    return result and (pos.Y - result.Position.Y) or math.huge
end

local function CheckTargetStopped(targetPos)
    if not lastTargetPos then 
        lastTargetPos = targetPos
        return false 
    end
    
    local movedDist = (targetPos - lastTargetPos).Magnitude
    lastTargetPos = targetPos
    
    if movedDist < 0.05 then
        stoppedTime += SETTINGS.THINK_DT
    else
        stoppedTime = 0
    end
    return stoppedTime > 0.5
end

-- =========================
-- LÓGICA DE MOVIMENTAÇÃO
-- =========================

local function TeleportTo(targetCFrame)
    ToggleFly(false)
    for i = 1, 16 do
        if not RootPart or not FOLLOW_STATE.Enabled then break end
        RootPart.CFrame = RootPart.CFrame:Lerp(targetCFrame, i / 16)
        RunService.Heartbeat:Wait()
    end
end

local function HandleFlight(targetRoot)
    ToggleFly(true)
    local isStopped = CheckTargetStopped(targetRoot.Position)
    
    local lookPos = targetRoot.Position
    local diff = targetRoot.Position - RootPart.Position
    
    if isStopped then
        -- Pairar próximo ao alvo
        local desiredPos = targetRoot.Position - targetRoot.CFrame.LookVector * 3
        local delta = desiredPos - RootPart.Position
        BodyVel.Velocity = Vector3.new(delta.X * 2, delta.Y * 2.2, delta.Z * 2)
    else
        -- Voo direto
        local verticalVel = math.clamp(diff.Y * 1.2, -15, 30)
        BodyVel.Velocity = diff.Unit * SETTINGS.FLY_SPEED + Vector3.new(0, verticalVel, 0)
    end
    
    BodyGyro.CFrame = CFrame.new(RootPart.Position, lookPos)
end

-- =========================
-- LOOP PRINCIPAL
-- =========================

SetupCharacter()
LocalPlayer.CharacterAdded:Connect(SetupCharacter)

task.spawn(function()
    while true do
        task.wait(SETTINGS.THINK_DT)

        if not FOLLOW_STATE.Enabled or not RootPart or not Humanoid then
            if isFlying then ToggleFly(false) end
            continue
        end

        local targetChar = FOLLOW_STATE.Target and FOLLOW_STATE.Target.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if not targetRoot then
            if isFlying then ToggleFly(false) end
            continue
        end

        local delta = targetRoot.Position - RootPart.Position
        local distance = delta.Magnitude
        local heightDiff = targetRoot.Position.Y - RootPart.Position.Y
        local targetGroundDist = GetGroundDistance(targetRoot.Position)

        -- 1. Teleporte (Muito longe ou muito alto)
        if (heightDiff > SETTINGS.TP_HEIGHT and targetGroundDist < SETTINGS.AIR_STATIC_HEIGHT) or distance > SETTINGS.FAR_DIST then
            TeleportTo(CFrame.new(targetRoot.Position - delta.Unit * 4))
            continue
        end

        -- 2. Voo (Alvo no ar)
        if heightDiff > SETTINGS.FLY_HEIGHT and targetGroundDist > SETTINGS.AIR_STATIC_HEIGHT then
            HandleFlight(targetRoot)
            continue
        end

        -- 3. Pousar
        if isFlying and heightDiff < 3 and distance < 8 then
            ToggleFly(false)
        end

        -- 4. Obstáculos e Pulo
        local rayResult = Workspace:Raycast(RootPart.Position + Vector3.new(0, 1.5, 0), delta.Unit * 4, rayParams)
        if rayResult then
            local obsHeight = rayResult.Instance.Position.Y - RootPart.Position.Y
            if obsHeight >= SETTINGS.JUMP_OBS_HEIGHT and obsHeight <= SETTINGS.MAX_OBS_HEIGHT then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end

        -- 5. Caminhada Base
        if distance > SETTINGS.STOP_DIST then
            Humanoid:MoveTo(targetRoot.Position)
        else
            Humanoid:MoveTo(RootPart.Position)
        end
    end
end)

-- =========================
-- INTERFACE / BOTÕES
-- =========================

-- (Supondo que CreateBtn e selectedPlayer já existam no seu script de UI)

CreateBtn("Follow Player", function(p)
    if FOLLOW_STATE.Enabled and FOLLOW_STATE.Target == p then
        FOLLOW_STATE.Enabled = false
        FOLLOW_STATE.Target = nil
        ToggleFly(false) -- Função correta definida no seu script
        if Humanoid then Humanoid:Move(Vector3.zero, false) end
        return "Follow Player"
    else
        FOLLOW_STATE.Enabled = true
        FOLLOW_STATE.Target = p
        return "Stop Follow"
    end
end)

--// BOTÕES
CreateBtn("TELEPORT", function(p) LocalPlayer.Character:PivotTo(p.Character:GetPivot()) end)
CreateBtn("SPECTATE", function(p) return ToggleSpectate(p) end)
CreateBtn("VIEW BACKPACK (beta)", function(p) UpdateBackpackView(p) end)

--// LÓGICA DE ATUALIZAÇÃO
local function Refresh()
    for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateRow(p) end end
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local t = SearchInput.Text:lower()

    for _, v in pairs(List:GetChildren()) do
        if v:IsA("TextButton") then
            local user = v:GetAttribute("Username")
            local display = v:GetAttribute("DisplayName")

            v.Visible =
                (user and user:find(t)) or
                (display and display:find(t))
        end
    end
end)


Players.PlayerAdded:Connect(Refresh)
Players.PlayerRemoving:Connect(function(p) 
    if selectedPlayer == p then selectedPlayer = nil; BP_Master.Visible = false end 
    Refresh() 
end)

--// ANIMAÇÕES ORIGINAIS MANTIDAS
_G.TogglePlayerPanel = function()
    local isOpen = not Master.Visible
    if isOpen then
        Master.Visible = true
        TweenService:Create(Master, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {GroupTransparency = 0, Position = UDim2.new(0.5, -225, 0.5, -150)}):Play()
    else
        BP_Master.Visible = false
        local t = TweenService:Create(Master, TweenInfo.new(0.3), {GroupTransparency = 1, Position = UDim2.new(0.5, -225, 0.5, -100)})
        t:Play(); t.Completed:Connect(function() if Master.GroupTransparency == 1 then Master.Visible = false end end)
    end
end

Refresh()
