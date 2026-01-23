local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// 1. CRIAÇÃO DA RAIZ (TOTALMENTE INDEPENDENTE)
local TargetParent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or 
                     game:GetService("CoreGui") or LocalPlayer.PlayerGui

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "Independent_PlayerManager"
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 100
MainGui.Parent = TargetParent

-- Definimos ParentGui como o MainGui que acabamos de criar
local ParentGui = MainGui 

--// CONFIGURAÇÕES DE PROFUNDIDADE
local MAX_ZINDEX = 5000

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

--// 2. PAINEL DE BACKPACK
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

--// 3. PAINEL PRINCIPAL
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

--// ESTRUTURA INTERNA (LeftSide, Search, List, RightSide)
local LeftSide = Instance.new("Frame", Master)
LeftSide.Size = UDim2.new(0, 170, 1, -30)
LeftSide.Position = UDim2.new(0, 15, 0, 15)
LeftSide.BackgroundTransparency = 1

local SearchFrame = Instance.new("Frame", LeftSide)
SearchFrame.Size = UDim2.new(1, 0, 0, 35)
SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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

local List = Instance.new("ScrollingFrame", LeftSide)
List.Size = UDim2.new(1, 0, 1, -45)
List.Position = UDim2.new(0, 0, 0, 45)
List.BackgroundTransparency = 1
List.ScrollBarThickness = 2
List.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
local ListLayout = Instance.new("UIListLayout", List)
ListLayout.Padding = UDim.new(0, 6)

local RightSide = Instance.new("Frame", Master)
RightSide.Size = UDim2.new(1, -210, 1, -30)
RightSide.Position = UDim2.new(0, 195, 0, 15)
RightSide.BackgroundTransparency = 1

local BigIcon = Instance.new("ImageLabel", RightSide)
BigIcon.Size = UDim2.new(0, 80, 0, 80)
BigIcon.Position = UDim2.new(0.5, -40, 0, 5)
BigIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", BigIcon).CornerRadius = UDim.new(1, 0)

local NameLabel = Instance.new("TextLabel", RightSide)
NameLabel.Size = UDim2.new(1, 0, 0, 25)
NameLabel.Position = UDim2.new(0, 0, 0, 90)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "Selecione"
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 14

local BtnScroll = Instance.new("ScrollingFrame", RightSide)
BtnScroll.Size = UDim2.new(1, 0, 1, -125)
BtnScroll.Position = UDim2.new(0, 0, 0, 120)
BtnScroll.BackgroundTransparency = 1
BtnScroll.ScrollBarThickness = 2
BtnScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
BtnScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local BtnLayout = Instance.new("UIListLayout", BtnScroll)
BtnLayout.Padding = UDim.new(0, 6)
BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// 4. LÓGICA DE FUNCIONALIDADES
local function CreateItemView(itemName, equipped)
    local Frame = Instance.new("Frame", BP_Container)
    Frame.Size = UDim2.new(0, 80, 0, 80)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", Frame)
    
    if equipped then
        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Color = Color3.fromRGB(0, 255, 150)
        Stroke.Thickness = 2
    end

    local ItemNameLabel = Instance.new("TextLabel", Frame)
    ItemNameLabel.Size = UDim2.new(1, -4, 0, 15)
    ItemNameLabel.BackgroundTransparency = 1
    ItemNameLabel.Text = itemName
    ItemNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ItemNameLabel.Font = Enum.Font.GothamMedium
    ItemNameLabel.TextSize = 8

    local Viewport = Instance.new("ViewportFrame", Frame)
    Viewport.Size = UDim2.new(1, 0, 0.8, 0)
    Viewport.BackgroundTransparency = 1
    Viewport.Ambient = Color3.fromRGB(200, 200, 200)

    local targetModel = ReplicatedStorage:FindFirstChild(itemName, true) or workspace:FindFirstChild(itemName, true)
    
    if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
        ItemNameLabel.Position = UDim2.new(0, 2, 1, -17)
        local clone = targetModel:Clone()
        clone.Parent = Viewport
        local cam = Instance.new("Camera", Viewport)
        Viewport.CurrentCamera = cam
        local cf, size = clone:IsA("Model") and clone:GetBoundingBox() or clone.CFrame, clone:IsA("Model") and clone:GetExtentsSize() or clone.Size
        local maxSide = math.max(size.X, size.Y, size.Z)
        cam.CFrame = CFrame.new(cf.Position + (cf.LookVector * (maxSide * 1.8)) + Vector3.new(0, maxSide/2, 0), cf.Position)
    else
        Viewport:Destroy()
        ItemNameLabel.Size = UDim2.new(1,0,1,0)
        ItemNameLabel.TextSize = 10
        ItemNameLabel.TextWrapped = true
    end
end

local function UpdateBackpackView(p)
    BP_Container:ClearAllChildren()
    Instance.new("UIListLayout", BP_Container).FillDirection = Enum.FillDirection.Horizontal
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

--// MOVIMENTAÇÃO E COMPONENTES
local SETTINGS = { THINK_DT = 0.08, STOP_DIST = 4, FAR_DIST = 45, TP_HEIGHT = 30, FLY_HEIGHT = 18, AIR_STATIC_HEIGHT = 25, FLY_SPEED = 60 }
local FOLLOW_STATE = { Enabled = false, Target = nil }
local BodyVel = Instance.new("BodyVelocity")
BodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
local BodyGyro = Instance.new("BodyGyro")
BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

task.spawn(function()
    while true do
        task.wait(SETTINGS.THINK_DT)
        if FOLLOW_STATE.Enabled and FOLLOW_STATE.Target and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = FOLLOW_STATE.Target.Character and FOLLOW_STATE.Target.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist > SETTINGS.STOP_DIST then
                    LocalPlayer.Character.Humanoid:MoveTo(targetRoot.Position)
                end
            end
        end
    end
end)

--// BOTÕES E FINALIZAÇÃO
local function CreateRow(p)
    local Row = Instance.new("TextButton", List)
    Row.Size = UDim2.new(1, -8, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Row.Text = p.DisplayName
    Row.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", Row)
    Row.MouseButton1Click:Connect(function()
        selectedPlayer = p
        NameLabel.Text = p.DisplayName
        BigIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
end

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton", BtnScroll)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() if selectedPlayer then callback(selectedPlayer) end end)
end

CreateBtn("Follow", function(p) FOLLOW_STATE.Enabled = not FOLLOW_STATE.Enabled; FOLLOW_STATE.Target = p end)
CreateBtn("Teleport", function(p) LocalPlayer.Character:PivotTo(p.Character:GetPivot()) end)
CreateBtn("View Backpack", function(p) UpdateBackpackView(p) end)

local function Refresh()
    for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateRow(p) end end
end

Players.PlayerAdded:Connect(Refresh)
Players.PlayerRemoving:Connect(Refresh)
Refresh()

--// GLOBAL TOGGLE
_G.TogglePlayerPanel = function()
    Master.Visible = not Master.Visible
    Master.GroupTransparency = Master.Visible and 0 or 1
end
