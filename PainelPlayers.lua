local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// 1. CONFIGURAÇÕES E ESTADOS GLOBAIS
local FOLLOW = {
    Enabled = false,
    Target = nil
}

local isSpectating = false
local selectedPlayer = nil
local followBtnReference = nil
local spectateBtnReference = nil

--// 2. CHARACTER CACHE (Obrigatório para a lógica de Follow)
local Char, Hum, HRP

local function getWalkSpeed()
    return Hum and Hum.WalkSpeed or 16
end

local function SetupCharacter()
    Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Hum = Char:WaitForChild("Humanoid")
    HRP = Char:WaitForChild("HumanoidRootPart")
end

SetupCharacter()
LocalPlayer.CharacterAdded:Connect(SetupCharacter)

--// 3. RAIZ DA UI
local TargetParent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or game:GetService("CoreGui") or LocalPlayer.PlayerGui
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "Complex_PlayerManager"
MainGui.ResetOnSpawn = false
MainGui.Parent = TargetParent

--// FUNÇÕES AUXILIARES UI
local function MakeDraggable(frame)
    local dragging, dragStart, startPos
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

--// 4. PAINEL PRINCIPAL
local Master = Instance.new("CanvasGroup", MainGui)
Master.Size = UDim2.new(0, 450, 0, 300)
Master.Position = UDim2.new(0.5, -225, 0.5, -150)
Master.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Master.Visible = true
Instance.new("UICorner", Master).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Master).Color = Color3.fromRGB(0, 150, 255)
MakeDraggable(Master)

-- Lado Esquerdo (Lista)
local LeftSide = Instance.new("Frame", Master)
LeftSide.Size = UDim2.new(0, 170, 1, -30); LeftSide.Position = UDim2.new(0, 15, 0, 15); LeftSide.BackgroundTransparency = 1

local SearchInput = Instance.new("TextBox", LeftSide)
SearchInput.Size = UDim2.new(1, 0, 0, 35); SearchInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SearchInput.PlaceholderText = "Pesquisar..."; SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255); SearchInput.Font = Enum.Font.GothamMedium; SearchInput.TextSize = 13; SearchInput.Text = ""
Instance.new("UICorner", SearchInput)

local List = Instance.new("ScrollingFrame", LeftSide)
List.Size = UDim2.new(1, 0, 1, -45); List.Position = UDim2.new(0, 0, 0, 45); List.BackgroundTransparency = 1; List.ScrollBarThickness = 0
local ListLayout = Instance.new("UIListLayout", List); ListLayout.Padding = UDim.new(0, 6)

-- Lado Direito (Info)
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

--// 5. LÓGICA DO FOLLOW (CONFORME SOLICITADO)
local THINK_DT = 0.08
local STOP_DIST = 4
local FAR_DIST = 45
local TP_HEIGHT = 30
local FLY_HEIGHT = 18
local AIR_STATIC_HEIGHT = 25
local JUMP_OBS_HEIGHT = 4
local MAX_OBS_HEIGHT = 7
local WALK_SPEED = getWalkSpeed()
local FLY_SPEED = 60

local lastTargetPos
local stoppedTime = 0
local flying = false

local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

local function lerpTP(from, to)
    for i = 1, 16 do
        if not HRP then return end
        HRP.CFrame = from:Lerp(to, i / 16)
        RunService.Heartbeat:Wait()
    end
end

local function ray(dir, dist)
    local p = RaycastParams.new()
    p.FilterDescendantsInstances = {Char}
    p.FilterType = Enum.RaycastFilterType.Blacklist
    return workspace:Raycast(HRP.Position + Vector3.new(0, 1.5, 0), dir * dist, p)
end

local function groundDistance(pos)
    local p = RaycastParams.new()
    p.FilterDescendantsInstances = {Char}
    p.FilterType = Enum.RaycastFilterType.Blacklist
    local r = workspace:Raycast(pos, Vector3.new(0, -600, 0), p)
    return r and (pos.Y - r.Position.Y) or math.huge
end

local function isTargetStopped(thrp)
    if not lastTargetPos then
        lastTargetPos = thrp.Position
        stoppedTime = 0
        return false
    end
    local d = (thrp.Position - lastTargetPos).Magnitude
    lastTargetPos = thrp.Position
    if d < 0.05 then stoppedTime += THINK_DT else stoppedTime = 0 end
    return stoppedTime > 0.5
end

local function startFly()
    if flying or not HRP then return end
    flying = true
    BV.Parent = HRP
    BG.Parent = HRP
    Hum.PlatformStand = true
end

local function stopFly()
    if not flying then return end
    flying = false
    BV.Parent = nil
    BG.Parent = nil
    Hum.PlatformStand = false
end

local function flyHoverToTarget(THRP)
    startFly()
    local desiredPos = THRP.Position - THRP.CFrame.LookVector * 3
    local delta = desiredPos - HRP.Position
    local verticalVel = math.clamp(delta.Y * 2.2, -18, 18)
    local horizontal = Vector3.new(delta.X, 0, delta.Z)
    local hVel = horizontal.Magnitude > 1 and horizontal.Unit * math.clamp(horizontal.Magnitude * 2, 8, 28) or Vector3.zero
    BG.CFrame = CFrame.new(HRP.Position, THRP.Position)
    BV.Velocity = hVel + Vector3.new(0, verticalVel, 0)
end

task.spawn(function()
    while task.wait(THINK_DT) do
        if not FOLLOW.Enabled or not HRP or not Hum then stopFly() continue end
        if not FOLLOW.Target or not FOLLOW.Target.Character or not FOLLOW.Target.Character:FindFirstChild("HumanoidRootPart") then
            stopFly() continue
        end

        local THRP = FOLLOW.Target.Character.HumanoidRootPart
        local delta = THRP.Position - HRP.Position
        local dist = delta.Magnitude
        local heightDiff = THRP.Position.Y - HRP.Position.Y
        local targetGroundDist = groundDistance(THRP.Position)
        local stopped = isTargetStopped(THRP)

        if heightDiff > TP_HEIGHT and targetGroundDist < AIR_STATIC_HEIGHT then
            stopFly(); lerpTP(HRP.CFrame, CFrame.new(THRP.Position - delta.Unit * 4)) continue
        end

        if heightDiff > FLY_HEIGHT and not stopped and targetGroundDist > AIR_STATIC_HEIGHT then
            startFly()
            BG.CFrame = CFrame.new(HRP.Position, THRP.Position)
            local verticalVel = math.clamp(heightDiff * 1.2, -15, 30)
            BV.Velocity = delta.Unit * FLY_SPEED + Vector3.new(0, verticalVel, 0)
            continue
        end

        if heightDiff > FLY_HEIGHT and stopped and targetGroundDist > AIR_STATIC_HEIGHT then
            flyHoverToTarget(THRP) continue
        end

        if flying and heightDiff < 3 and dist < 8 then stopFly() end
        if dist > FAR_DIST then lerpTP(HRP.CFrame, CFrame.new(THRP.Position - delta.Unit * 5)) continue end

        local hit = ray(delta.Unit, 4)
        if hit then
            local obsHeight = hit.Instance.Position.Y - HRP.Position.Y
            if obsHeight >= JUMP_OBS_HEIGHT and obsHeight <= MAX_OBS_HEIGHT then
                Hum:ChangeState(Enum.HumanoidStateType.Jumping)
            elseif obsHeight > MAX_OBS_HEIGHT then
                lerpTP(HRP.CFrame, HRP.CFrame * CFrame.new(4, 0, 0)) continue
            end
        end

        if heightDiff > 3 and heightDiff < FLY_HEIGHT then
            Hum:ChangeState(Enum.HumanoidStateType.Jumping)
            Hum:MoveTo(THRP.Position) continue
        end

        if stopped then
            if dist > STOP_DIST then Hum:MoveTo(THRP.Position) end continue
        end

        if dist > STOP_DIST then
            Hum.WalkSpeed = getWalkSpeed()
            Hum:MoveTo(THRP.Position)
        end
    end
end)

--// 6. FUNÇÕES DOS BOTÕES E UI
local function ToggleSpectate(p)
    local Camera = workspace.CurrentCamera
    if isSpectating or not p then
        isSpectating = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        spectateBtnReference.Text = "Spectate"; spectateBtnReference.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    else
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            isSpectating = true
            Camera.CameraSubject = p.Character.Humanoid
            spectateBtnReference.Text = "Stop Spectate"; spectateBtnReference.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end
end

local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton", BtnScroll)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(45, 45, 50); b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 12
    Instance.new("UICorner", b)
    if txt == "Follow" then followBtnReference = b elseif txt == "Spectate" then spectateBtnReference = b end
    b.MouseButton1Click:Connect(function() if selectedPlayer then callback(selectedPlayer) end end)
end

CreateBtn("Follow", function(p)
    if FOLLOW.Enabled and FOLLOW.Target == p then
        FOLLOW.Enabled = false
        FOLLOW.Target = nil
        followBtnReference.Text = "Follow"; followBtnReference.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    else
        FOLLOW.Enabled = true
        FOLLOW.Target = p
        followBtnReference.Text = "Stop Follow"; followBtnReference.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

CreateBtn("Spectate", function(p) ToggleSpectate(p) end)
CreateBtn("Teleport", function(p) if p.Character then HRP.CFrame = p.Character:GetPivot() end end)

local function CreateRow(p)
    local Row = Instance.new("TextButton", List)
    Row.Size = UDim2.new(1, -8, 0, 45); Row.BackgroundColor3 = Color3.fromRGB(35, 35, 40); Row.Text = ""; Instance.new("UICorner", Row)
    local MiniIcon = Instance.new("ImageLabel", Row)
    MiniIcon.Size = UDim2.new(0, 32, 0, 32); MiniIcon.Position = UDim2.new(0, 8, 0.5, -16); MiniIcon.BackgroundTransparency = 1; Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)
    task.spawn(function() MiniIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
    local PlayerName = Instance.new("TextLabel", Row)
    PlayerName.Size = UDim2.new(1, -55, 1, 0); PlayerName.Position = UDim2.new(0, 48, 0, 0); PlayerName.BackgroundTransparency = 1; PlayerName.Text = p.DisplayName; PlayerName.TextColor3 = Color3.fromRGB(220, 220, 220); PlayerName.Font = Enum.Font.GothamMedium; PlayerName.TextSize = 12; PlayerName.TextXAlignment = Enum.TextXAlignment.Left
    
    Row.MouseButton1Click:Connect(function()
        selectedPlayer = p
        NameLabel.Text = p.DisplayName
        task.spawn(function() BigIcon.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
        followBtnReference.Text = (FOLLOW.Enabled and FOLLOW.Target == p) and "Stop Follow" or "Follow"
        followBtnReference.BackgroundColor3 = (FOLLOW.Enabled and FOLLOW.Target == p) and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(45, 45, 50)
    end)
end

local function Refresh()
    for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,p in pairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer and (SearchInput.Text == "" or string.find(p.DisplayName:lower(), SearchInput.Text:lower())) then CreateRow(p) end 
    end
end

Refresh()
SearchInput:GetPropertyChangedSignal("Text"):Connect(Refresh)
Players.PlayerAdded:Connect(Refresh); Players.PlayerRemoving:Connect(Refresh)

_G.TogglePlayerPanel = function() Master.Visible = not Master.Visible end
