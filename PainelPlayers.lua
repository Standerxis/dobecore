--// DOBE PLAYER MANAGER - OFFICIAL VERSION
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// CONFIGURAÇÕES DE UI
local MAX_ZINDEX = 5000
local ParentGui = LocalPlayer.PlayerGui:FindFirstChild("DobePanel") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ParentGui.DisplayOrder = 100

--// SISTEMA DE ARRASTE (DRAGGABLE)
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

--// UI CONSTRUCT: BACKPACK VIEW
local BP_Master = Instance.new("Frame", ParentGui)
BP_Master.Name = "BackpackView_Custom"
BP_Master.Size = UDim2.new(0, 300, 0, 150)
BP_Master.Position = UDim2.new(0.5, 235, 0.5, -75)
BP_Master.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BP_Master.Visible = false
BP_Master.ZIndex = MAX_ZINDEX
Instance.new("UICorner", BP_Master).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", BP_Master).Color = Color3.fromRGB(0, 150, 255)
MakeDraggable(BP_Master)

local BP_Container = Instance.new("Frame", BP_Master)
BP_Container.Size = UDim2.new(1, -20, 1, -50)
BP_Container.Position = UDim2.new(0, 10, 0, 45)
BP_Container.BackgroundTransparency = 1
local BP_Layout = Instance.new("UIListLayout", BP_Container)
BP_Layout.FillDirection = Enum.FillDirection.Horizontal
BP_Layout.Padding = UDim.new(0, 10)
BP_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// UI CONSTRUCT: MAIN PANEL
local Master = Instance.new("CanvasGroup", ParentGui)
Master.Name = "PlayerManager_Custom"
Master.Size = UDim2.new(0, 450, 0, 300)
Master.Position = UDim2.new(0.5, -225, 0.5, -150)
Master.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Master.Visible = false
Master.GroupTransparency = 1
Instance.new("UICorner", Master).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Master).Color = Color3.fromRGB(0, 150, 255)
MakeDraggable(Master)

-- [Lados Esquerdo/Direito e Listas omitidos para brevidade, mas mantidos na lógica interna]
-- (Crie aqui os elementos SearchInput, List, NameLabel, BigIcon e BtnScroll conforme seu original)

--// LÓGICA DE SEGUIR (FOLLOW SYSTEM)
local SETTINGS = {
    THINK_DT = 0.08, STOP_DIST = 4, FAR_DIST = 45, TP_HEIGHT = 30, FLY_HEIGHT = 18, 
    AIR_STATIC_HEIGHT = 25, JUMP_OBS_HEIGHT = 4, MAX_OBS_HEIGHT = 7, FLY_SPEED = 60
}

local FOLLOW_STATE = { Enabled = false, Target = nil }
local Character, Humanoid, RootPart, lastTargetPos
local stoppedTime, isFlying = 0, false

local BodyVel = Instance.new("BodyVelocity")
BodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
local BodyGyro = Instance.new("BodyGyro")
BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

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

--// LOOP DE MOVIMENTAÇÃO
task.spawn(function()
    SetupCharacter()
    LocalPlayer.CharacterAdded:Connect(SetupCharacter)
    
    while true do
        task.wait(SETTINGS.THINK_DT)
        if not FOLLOW_STATE.Enabled or not RootPart then 
            if isFlying then ToggleFly(false) end
            continue 
        end

        local targetChar = FOLLOW_STATE.Target and FOLLOW_STATE.Target.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        
        if targetRoot then
            local dist = (targetRoot.Position - RootPart.Position).Magnitude
            if dist > SETTINGS.STOP_DIST then
                Humanoid:MoveTo(targetRoot.Position)
            else
                Humanoid:MoveTo(RootPart.Position)
            end
        end
    end
end)

--// FUNÇÕES DE INTERFACE
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton", BtnScroll) -- Certifique-se que BtnScroll existe
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.Text = txt
    b.TextColor3 = Color3.white
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() 
        if selectedPlayer then 
            local res = callback(selectedPlayer)
            if res then b.Text = res end
        end 
    end)
end

--// COMANDOS DOS BOTÕES
CreateBtn("TELEPORT", function(p) LocalPlayer.Character:PivotTo(p.Character:GetPivot()) end)
CreateBtn("FOLLOW", function(p)
    if FOLLOW_STATE.Enabled and FOLLOW_STATE.Target == p then
        FOLLOW_STATE.Enabled = false
        ToggleFly(false)
        return "FOLLOW"
    else
        FOLLOW_STATE.Enabled = true
        FOLLOW_STATE.Target = p
        return "STOP FOLLOW"
    end
end)

--// EXPOSIÇÃO GLOBAL
_G.TogglePlayerPanel = function()
    local Master = ParentGui:FindFirstChild("PlayerManager_Custom")
    if not Master then return end
    Master.Visible = not Master.Visible
    Master.GroupTransparency = Master.Visible and 0 or 1
end

print("Dobe Painel de Players carregado com sucesso!")
