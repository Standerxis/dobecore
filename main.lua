print("Key Mode: Keyless")
print("KeySystem Created by DobeHKL")
print("All Features Loaded")

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Standerxis/dobecore/refs/heads/main/lib.lua"
))()

--[LA PRA CIMA É UI]--

--[SERVICES]--
local Players = game:GetService("Players")
local ALLOWED_PLACE = 17274762379
local IS_ALLOWED = game.PlaceId == ALLOWED_PLACE
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer


local TweenService = game:GetService("TweenService")


local NotificationService = {}
NotificationService.__index = NotificationService

local LP = Players.LocalPlayer

local Gui = Instance.new("ScreenGui")
Gui.Name = "TopNotifications"
Gui.ResetOnSpawn = false
Gui.Parent = LP:WaitForChild("PlayerGui")

local Holder = Instance.new("Frame")
Holder.Size = UDim2.fromScale(1, 0)
Holder.Position = UDim2.fromOffset(0, 12)
Holder.BackgroundTransparency = 1
Holder.Parent = Gui

local Layout = Instance.new("UIListLayout")
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Holder

local Active = {}

local function createLabel(text)
	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(420, 34)
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	f.Position = UDim2.fromScale(0.5, 0)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(0.5, 0)
	

	local c = Instance.new("UICorner", f)
	c.CornerRadius = UDim.new(0, 8)

	local s = Instance.new("UIStroke", f)
	s.Thickness = 1
	s.Transparency = 0.6
	s.Parent = f

	local l = Instance.new("TextLabel")
	l.Size = UDim2.fromScale(1, 1)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(240, 240, 240)
	l.TextTransparency = 1
	l.TextSize = 14
	l.Font = Enum.Font.GothamMedium
	l.Parent = f

	return f, l
end

function NotificationService:Create(id, text)
	if Active[id] then return end

	local frame, label = createLabel(text)
	frame.Parent = Holder
	Active[id] = { Frame = frame, Label = label }

	TweenService:Create(
		frame,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.1 }
	):Play()

	TweenService:Create(
		label,
		TweenInfo.new(0.25),
		{ TextTransparency = 0 }
	):Play()
end

function NotificationService:Update(id, text)
	local n = Active[id]
	if not n then return end

	n.Label.Text = text
end

function NotificationService:Check(id, callback)
	local n = Active[id]
	if not n then return false end

	if callback then
		task.spawn(callback, n)
	end

	return true
end

function NotificationService:Remove(id)
	local n = Active[id]
	if not n then return end

	TweenService:Create(
		n.Frame,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	):Play()

	TweenService:Create(
		n.Label,
		TweenInfo.new(0.25),
		{ TextTransparency = 1 }
	):Play()

	task.delay(0.26, function()
		if n.Frame then n.Frame:Destroy() end
	end)

	Active[id] = nil
end

--[SCRIPT]--

local Window = Library:Window({
    Title = "DobeCore",
    Shadow = true,
    ServerTab = true
})

 --[area de funções/ferramentas]--
local function GetRemoteEvent()
	local ok, r = pcall(function()
		return ReplicatedStorage.Modules.Events.RemoteEvent
	end)
	return ok and r or nil
end

local function Center(gui)
	return gui.AbsolutePosition + gui.AbsoluteSize * 0.5
end

local function RealClick(x, y)
	VirtualInputManager:SendMouseMoveEvent(
		x + math.random(-2,2),
		y + math.random(-2,2),
		game
	)
	task.wait(math.random(8,14)/1000)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
	task.wait(math.random(12,20)/1000)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

 --[area de pesca]--

local ConfigPesca = {
    AutoPescaKey = Enum.KeyCode.K,
    AutoSellKey = Enum.KeyCode.Unknown,
    AutoRepairKey = Enum.KeyCode.Unknown,
}

if IS_ALLOWED then

local PescaTab = Window:Tab("Pesca","rbxassetid://10709770005")



PescaTab:Section("Utilizaveis")

PescaTab:Button("Caverna",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
	char:PivotTo(CFrame.new(5354.44, 22.73, -462.13))
end)

local SelectedRod

local RodList = {
		["Professional Rod"] = "Professional Rod",
		["Mush Rod"] = "Mush Rod",
		["Candy Rod"] = "Candy Rod",
		["Cyber Rod"] = "Cyber Rod",
		["Trident Rod"] = "Trident Rod",
	}

PescaTab:Dropdown("Compre uma vara!",{
			"Professional Rod / $100c",
			"Mush Rod / $340c",
			"Candy Rod / $900c",
			"Cyber Rod / $1700c",
			"Trident Rod / $11700c",
		},function(v)
        local name = string.match(v, "^(.-)%s*/")
			SelectedRod = RodList[name]
			if not SelectedRod then return end
			local char = Player.Character or Player.CharacterAdded:Wait()
			local save = char:GetPivot()
			local npc = Workspace.NPCS.Fisherman.HumanoidRootPart
			char:PivotTo(npc.CFrame)
			task.wait(0.2)
			local r = GetRemoteEvent()
			if r then r:FireServer("BuyFishingRod", SelectedRod) end
			task.wait(0.2)
			char:PivotTo(save)
end)

PescaTab:Button("Vender Peixes", function()
    if not Player then Player = Players.LocalPlayer end
			local char = Player.Character or Player.CharacterAdded:Wait()
			local savePos = char:GetPivot()
			local fisherman = Workspace:WaitForChild("NPCS"):WaitForChild("Fisherman")
			local fishermanHRP = fisherman:WaitForChild("HumanoidRootPart")

			char:PivotTo(fishermanHRP.CFrame)
			task.wait(0.2)
			local remote = GetRemoteEvent()
			if remote then
				pcall(function()
					remote:FireServer("SellAllFishes")
				end)
			else
				warn("RemoteEvent para vender peixes não encontrado.")
			end
			task.wait(0.2)
			char:PivotTo(savePos)
end)

--[[
    SCRIPT AUTOFISH FISCH - ADAPTADO PARA TODOS OS DISPOSITIVOS
    Otimizado para resoluções Mobile e Monitores UltraWide
]]

local S = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VIM = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService") -- Adicionado para precisão de clique
}
local Player = S.Players.LocalPlayer

-- ==========================================
-- CONFIGURAÇÃO E ESTADO
-- ==========================================
local Bot = {
    Enabled = false,
    Selling = false,
    MinigameActive = false,
    LastDelta = nil,
    LastClick = 0,
    LastHookClick = 0,
    HookCooldown = 0.6,
    Conn = nil
}

-- =========================
-- FUNÇÕES DE SUPORTE (CORRIGIDAS PARA ESCALA)
-- =========================
local function GetCenter(inst)
    if not inst then return Vector2.new(0,0) end
    -- Uso do AbsolutePosition garante que pegamos a posição real na tela, independente da escala do celular ou monitor
    local pos = inst.AbsolutePosition
    local size = inst.AbsoluteSize
    -- Adicionamos o GuiInset para que o clique ocorra exatamente onde o elemento visual está
    local inset = S.GuiService:GetGuiInset()
    return Vector2.new(pos.X + size.X / 2 + inset.X, pos.Y + size.Y / 2 + inset.Y)
end

local function Click(x, y)
    -- Simula o toque/clique na posição exata calculada
    S.VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    S.VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

local function GetRemote()
    return S.ReplicatedStorage:FindFirstChild("Modules") 
           and S.ReplicatedStorage.Modules:FindFirstChild("Events") 
           and S.ReplicatedStorage.Modules.Events:FindFirstChild("RemoteEvent")
end

local function GetFishStats()
    local gui = Player.PlayerGui:FindFirstChild("FishInventoryScreenGui")
    local label = gui and gui:FindFirstChild("TextLabel", true)
    if label then
        local cur, max = label.Text:match("(%d+)%s*/%s*(%d+)")
        return tonumber(cur), tonumber(max)
    end
    return nil, nil
end

local function EquipRod()
    local char = Player.Character
    if not char then return end
    
    local rod = char:FindFirstChild("Fishing Rod")
    if not rod then
        rod = Player.Backpack:FindFirstChild("Fishing Rod")
        if rod then 
            rod.Parent = char 
            task.wait(0.5)
        end
    end
end

-- =========================
-- LÓGICA DE EXECUÇÃO
-- =========================
local function DoAction(action)
    local r = GetRemote()
    if not r then return end
    
    if action == "Sell" then
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local npc = workspace:FindFirstChild("NPCS") and workspace.NPCS:FindFirstChild("Fisherman")
        
        if root and npc and npc:FindFirstChild("HumanoidRootPart") then
            local oldPos = root.CFrame
            Bot.Selling = true
            
            char:PivotTo(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3))
            task.wait(0.6)
            r:FireServer("SellAllFishes")
            task.wait(0.5)
            r:FireServer("RepairAllFishingRods")
            task.wait(0.6)
            
            char:PivotTo(oldPos)
            task.wait(0.5)
            Bot.Selling = false
            
            EquipRod()
            task.wait(0.3)
            r:FireServer("Throw", 1)
        end
    elseif action == "Throw" then
        EquipRod()
        task.wait(0.2)
        r:FireServer("Throw", 1)
    end
end

-- =========================
-- LOOP PRINCIPAL
-- =========================
local function StartBot()
    if Bot.Conn then Bot.Conn:Disconnect() end
    
    Bot.Selling = false
    Bot.MinigameActive = false
    
    DoAction("Throw")

    task.spawn(function()
        while Bot.Enabled do
            if not Bot.Selling then
                local cur, max = GetFishStats()
                if cur and max and cur >= max then
                    DoAction("Sell")
                end
            end
            task.wait(2)
        end
    end)

    Bot.Conn = S.RunService.Heartbeat:Connect(function()
        if not Bot.Enabled or Bot.Selling then return end

        local gui = Player.PlayerGui
        
        -- Fisgada (Hook) - Adaptado para Mobile/PC
        local hook = gui:FindFirstChild("HookMeter")
        if hook and (os.clock() - Bot.LastHookClick >= Bot.HookCooldown) then
            local mid = hook:FindFirstChild("MiddleCircle", true)
            if mid and mid.Visible then
                Bot.LastHookClick = os.clock()
                local c = GetCenter(mid)
                Click(c.X, c.Y)
            end
        end

        -- Minigame de Puxar
        local catch = gui:FindFirstChild("CatchIndicator")
        local img = catch and catch:FindFirstChild("ImageButton")
        if img then
            local moving, target
            for _, v in ipairs(img:GetDescendants()) do
                if v:IsA("Frame") then
                    -- Cores do Fisch para detecção
                    if v.BackgroundColor3 == Color3.fromRGB(242, 84, 84) then moving = v
                    elseif v.BackgroundColor3 == Color3.fromRGB(67, 200, 120) then target = v end
                end
            end

            if moving and target then
                Bot.MinigameActive = true
                local mX = GetCenter(moving).X
                local targetPos = GetCenter(target)
                local delta = mX - targetPos.X

                -- Lógica de clique baseada na inversão de direção (mais estável em telas grandes)
                if Bot.LastDelta and math.sign(Bot.LastDelta) ~= math.sign(delta) and (tick() - Bot.LastClick > 0.1) then
                    Bot.LastClick = tick()
                    Click(targetPos.X, targetPos.Y)
                end
                Bot.LastDelta = delta
            end
        elseif Bot.MinigameActive then
            Bot.MinigameActive = false
            Bot.LastDelta = nil
            task.wait(1.2)
            local r = GetRemote()
            if r then r:FireServer("FishDecision", true) end
            
            task.wait(1.0)
            if Bot.Enabled and not Bot.Selling then 
                DoAction("Throw") 
            end
        end
    end)
end

-- =========================
-- UI TOGGLE (Integração com sua aba)
-- =========================
PescaTab:Toggle("Autofish Full", false, function(state)
    Bot.Enabled = state
    if state then
        StartBot()
    else
        if Bot.Conn then 
            Bot.Conn:Disconnect() 
            Bot.Conn = nil 
        end
    end
end, {
    Keybind = { Value = ConfigPesca.AutoPescaKey }
})
-- [TRECHO DO TELEPORT]
local TeleportTab = Window:Tab("Teleport","rbxassetid://10734886004")

TeleportTab:Section("Listas")

local Npcs = {
    ["Fishing NPC"] = CFrame.new(4992.8, 179.9, -79.2),
    ["Event NPC"] = CFrame.new(5109.0, 192.1, -212.1),
    ["Quest NPC"] = CFrame.new(5241.0, 191.7, -98.8),
}

-- Removida a vírgula extra aqui

if IS_ALLOWED then
TeleportTab:Dropdown("NPCs", {"Fishing NPC", "Event NPC", "Quest NPC"}, function(v)
    local char = Player.Character or Player.CharacterAdded:Wait()
    if char and Npcs[v] then
        char:PivotTo(Npcs[v])
    end
end)
end

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

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
    -- Se clicar no mesmo player que já está seguindo, ele desativa
    if FOLLOW.Enabled and FOLLOW.Target == p then
        FOLLOW.Enabled = false
        FOLLOW.Target = nil
        stopFly()
        if Hum then Hum:Move(Vector3.zero, false) end
        return "Follow Player"
    else
        -- Ativa o follow para o player selecionado
        FOLLOW.Enabled = true
        FOLLOW.Target = p
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

TeleportTab:Button("Gerenciar Players", function()
    _G.TogglePlayerPanel()
end)


if IS_ALLOWED then
TeleportTab:Section("Localizacoes")


TeleportTab:Button("Praça",function()
    if not Player then Player = Players.LocalPlayer end
			local char = Player.Character or Player.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			local CavernaCF = CFrame.new(5101.650391, 192.079605, -46.108219)
			hrp:PivotTo(CavernaCF)
end)

TeleportTab:Button("Céu",function()
    if not Player then Player = Players.LocalPlayer end
			local char = Player.Character or Player.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			local CeuCF = CFrame.new(5155.737793, 446.781555, -178.841934)
			hrp:PivotTo(CeuCF)
end)
end

ConfigTeleport = {
    TpSave = Enum.KeyCode.Unknown,
    SaveTp = Enum.KeyCode.Unknown
}


local TeleportFolder = "DobeiOS_Teleports"
local SelectedTP = nil
local TPName = "Position"
local HttpService = game:GetService("HttpService")


if makefolder and isfolder and not isfolder(TeleportFolder) then
    makefolder(TeleportFolder)
end

local function GetTeleports()
    if not listfiles then return {} end
    local files = listfiles(TeleportFolder)
    local names = {}

    for _, file in pairs(files) do
        local name = file:match("([^/]+)%.json$")
        if name then
            table.insert(names, name)
        end
    end

    return names
end

TeleportTab:Section("TELEPORT SALVO")

TeleportTab:Input("Nome da Posição", "Base", function(text)
    TPName = text
end)

local TPDropdown = TeleportTab:Dropdown("Posições Salvas", GetTeleports(), function(val)
    SelectedTP = val
end)

TeleportTab:Button("Atualizar Lista", function()
    TPDropdown:Refresh(GetTeleports())
end)

TeleportTab:Button("Salvar Posição Atual", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        NotificationService:Create("TpErr1", "❌ Personagem não encontrado")
        task.wait(1.5)
        NotificationService:Remove("TpErr1")
        return
    end

    local cf = hrp.CFrame

    local data = {
        Components = { cf:GetComponents() }
    }

    writefile(
        TeleportFolder .. "/" .. TPName .. ".json",
        HttpService:JSONEncode(data)
    )

    NotificationService:Create("TpSave", "✅ Posição '" .. TPName .. "' salva!")
    task.wait(1.2)
    NotificationService:Remove("TpSave")

    TPDropdown:Refresh(GetTeleports())
end)

TeleportTab:Button("Teleportar para Posição", function()
    if not SelectedTP then
        NotificationService:Create("TpErr2", "❌ Nenhuma posição selecionada")
        task.wait(1.5)
        NotificationService:Remove("TpErr2")
        return
    end

    local path = TeleportFolder .. "/" .. SelectedTP .. ".json"
    if not isfile(path) then return end

    local decoded = HttpService:JSONDecode(readfile(path))
    local cf = CFrame.new(unpack(decoded.Components))

    local char = LocalPlayer.Character
    if char then
        char:PivotTo(cf)
    end

    NotificationService:Create("TpOK", "✅ Teleportado para '" .. SelectedTP .. "'")
    task.wait(1.2)
    NotificationService:Remove("TpOK")
end,{
    Keybind = {Value = ConfigTeleport.TpSave}
})

TeleportTab:Button("Deletar Posição", function()
    if not SelectedTP then return end

    local path = TeleportFolder .. "/" .. SelectedTP .. ".json"
    if isfile(path) then
        delfile(path)
    end

    SelectedTP = nil
    TPDropdown:Refresh(GetTeleports())

    NotificationService:Create("TpDel", "🗑️ Posição deletada")
    task.wait(1.2)
    NotificationService:Remove("TpDel")
end)


local VisualTab = Window:Tab("Visuals","rbxassetid://10723346959")

local VisualConfig = {
    CorEspSk = Color3.fromRGB(0, 255, 120),
    CorEspName = Color3.fromRGB(255, 255, 255),
    TeclaEsp = Enum.KeyCode.Unknown
}

VisualTab:Section("Screen Functions")

local function getCamera()
    return workspace.CurrentCamera
end

_G.ESP = _G.ESP or {
    Enabled = false, -- Refere-se ao Skeleton
    ShowName = false, -- Refere-se ao Name
    conn = nil,
    Skeletons = {},
    NameTags = {},
    ColorSkeleton = VisualConfig.CorEspSk,
    ColorName = VisualConfig.CorEspName,
    RGBEnabled = false,
    RGBHue = 0,
    RGBSpeed = 0.25
}

-- Gerenciador de Cores RGB
if not _G.ESP.RGBConn then
    _G.ESP.RGBConn = RunService.RenderStepped:Connect(function(dt)
        if _G.ESP.RGBEnabled then
            _G.ESP.RGBHue = (_G.ESP.RGBHue + dt * _G.ESP.RGBSpeed) % 1
        end
    end)
end

local function getESPColor(defaultColor)
    if _G.ESP.RGBEnabled then
        return Color3.fromHSV(_G.ESP.RGBHue, 1, 1)
    end
    return defaultColor
end

-- Limpeza de ESP
local function removeEsp(plr)
    if _G.ESP.Skeletons[plr] then
        for _, l in ipairs(_G.ESP.Skeletons[plr]) do
            pcall(function() l:Remove() end)
        end
        _G.ESP.Skeletons[plr] = nil
    end
    if _G.ESP.NameTags[plr] then
        pcall(function() _G.ESP.NameTags[plr]:Remove() end)
        _G.ESP.NameTags[plr] = nil
    end
end

Players.PlayerRemoving:Connect(removeEsp)

-- FUNÇÃO PRINCIPAL DE ATUALIZAÇÃO (Loop Único)
local function UpdateESP()
    -- Se ambos estiverem desligados, desconecta o loop e limpa tudo
    if not _G.ESP.Enabled and not _G.ESP.ShowName then
        if _G.ESP.conn then
            _G.ESP.conn:Disconnect()
            _G.ESP.conn = nil
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            removeEsp(plr)
        end
        return
    end

    -- Se algum estiver ligado e o loop não existir, cria o loop
    if not _G.ESP.conn then
        _G.ESP.conn = RunService.RenderStepped:Connect(function()
            local Camera = getCamera()
            local LocalPlayer = Players.LocalPlayer

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local char = plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if char and hum and hrp and hum.Health > 0 then
                        -- Lógica do Skeleton
                        if _G.ESP.Enabled then
                            if not _G.ESP.Skeletons[plr] then
                                _G.ESP.Skeletons[plr] = {}
                                for i = 1, 15 do
                                    local l = Drawing.new("Line")
                                    l.Thickness = 2
                                    l.Transparency = 1
                                    table.insert(_G.ESP.Skeletons[plr], l)
                                end
                            end

                            local parts = {
                                Head = char:FindFirstChild("Head"),
                                UpperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
                                LowerTorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso"),
                                LUA = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
                                LLA = char:FindFirstChild("LeftLowerArm") or char:FindFirstChild("Left Arm"),
                                LH  = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"),
                                RUA = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
                                RLA = char:FindFirstChild("RightLowerArm") or char:FindFirstChild("Right Arm"),
                                RH  = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"),
                                LUL = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
                                LLL = char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg"),
                                LF  = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg"),
                                RUL = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
                                RLL = char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg"),
                                RF  = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg"),
                            }

                            local lines = _G.ESP.Skeletons[plr]
                            local function drawLine(i, p1, p2)
                                if p1 and p2 then
                                    local a, v1 = Camera:WorldToViewportPoint(p1.Position)
                                    local b, v2 = Camera:WorldToViewportPoint(p2.Position)
                                    if v1 and v2 then
                                        lines[i].From = Vector2.new(a.X, a.Y)
                                        lines[i].To = Vector2.new(b.X, b.Y)
                                        lines[i].Color = getESPColor(_G.ESP.ColorSkeleton)
                                        lines[i].Visible = true
                                        return
                                    end
                                end
                                lines[i].Visible = false
                            end

                            drawLine(1, parts.Head, parts.UpperTorso)
                            drawLine(2, parts.UpperTorso, parts.LowerTorso)
                            drawLine(3, parts.UpperTorso, parts.LUA)
                            drawLine(4, parts.LUA, parts.LLA)
                            drawLine(5, parts.LLA, parts.LH)
                            drawLine(6, parts.UpperTorso, parts.RUA)
                            drawLine(7, parts.RUA, parts.RLA)
                            drawLine(8, parts.RLA, parts.RH)
                            drawLine(9, parts.LowerTorso, parts.LUL)
                            drawLine(10, parts.LUL, parts.LLL)
                            drawLine(11, parts.LLL, parts.LF)
                            drawLine(12, parts.LowerTorso, parts.RUL)
                            drawLine(13, parts.RUL, parts.RLL)
                            drawLine(14, parts.RLL, parts.RF)
                        else
                            -- Se Skeleton desligado, oculta as linhas existentes
                            if _G.ESP.Skeletons[plr] then
                                for _, l in ipairs(_G.ESP.Skeletons[plr]) do l.Visible = false end
                            end
                        end

                        -- Lógica do Name
                        if _G.ESP.ShowName then
                            if not _G.ESP.NameTags[plr] then
                                local t = Drawing.new("Text")
                                t.Size = 16
                                t.Center = true
                                t.Outline = true
                                _G.ESP.NameTags[plr] = t
                            end

                            local head = char:FindFirstChild("Head")
                            local tag = _G.ESP.NameTags[plr]
                            if head and tag then
                                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                                if vis then
                                    tag.Text = plr.Name
                                    tag.Position = Vector2.new(pos.X, pos.Y - 30)
                                    tag.Color = getESPColor(_G.ESP.ColorName)
                                    tag.Visible = true
                                else
                                    tag.Visible = false
                                end
                            end
                        else
                            -- Se Name desligado, oculta o texto
                            if _G.ESP.NameTags[plr] then _G.ESP.NameTags[plr].Visible = false end
                        end
                    else
                        removeEsp(plr)
                    end
                end
            end
        end)
    end
end

-- Toggles da UI
VisualTab:Toggle("Show Names", false, function(state, extra)
    if state == "Color" then
        _G.ESP.ColorName = extra
        return
    end
    _G.ESP.ShowName = state
    UpdateESP() -- Atualiza o estado do loop
end, {
    Color = VisualConfig.CorEspName
})

VisualTab:Toggle("Esp Skeleton", false, function(state, extra)
    if state == "Color" then
        _G.ESP.ColorSkeleton = extra
        return
    end
    _G.ESP.Enabled = state
    UpdateESP() -- Atualiza o estado do loop
end, {
    Color = VisualConfig.CorEspSk,
    Keybind = { Value = VisualConfig.TeclaEsp }
})



local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

_G.ESP = _G.ESP or {}
_G.ESP.PathEnabled = _G.ESP.PathEnabled or false
_G.ESP.PathConn = _G.ESP.PathConn or nil
_G.ESP.PathPoints = _G.ESP.PathPoints or {}
_G.ESP.PathLines = _G.ESP.PathLines or {}
_G.ESP.ColorPath = _G.ESP.ColorPath or Color3.fromRGB(255, 255, 255)
_G.ESP.PathStep = _G.ESP.PathStep or 3

local function getCamera()
	return workspace.CurrentCamera
end

local function getPathColor()
	if _G.ESP.RGBEnabled then
		return Color3.fromHSV(_G.ESP.RGBHue, 1, 1)
	end
	return _G.ESP.ColorPath
end

local function clearPath()
	if _G.ESP.PathLines then
		for _, line in ipairs(_G.ESP.PathLines) do
			pcall(function() line:Remove() end)
		end
	end
	table.clear(_G.ESP.PathLines)
	table.clear(_G.ESP.PathPoints)
end

VisualTab:Toggle("Path ESP", false, function(state, extra)
	if state == "Color" then
		_G.ESP.ColorPath = extra
		return
	end

	_G.ESP.PathEnabled = state

	if state then
		if _G.ESP.PathConn then return end

		_G.ESP.PathConn = RunService.RenderStepped:Connect(function()
			if not _G.ESP.PathEnabled then
				clearPath()
				return
			end

			local cam = getCamera()
			if not cam then return end

			local char = Player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				for _, line in ipairs(_G.ESP.PathLines) do
					line.Visible = false
				end
				return
			end

			local lastPoint = _G.ESP.PathPoints[#_G.ESP.PathPoints]
			if not lastPoint or (hrp.Position - lastPoint).Magnitude >= _G.ESP.PathStep then
				table.insert(_G.ESP.PathPoints, hrp.Position)
				if #_G.ESP.PathPoints > 80 then
					table.remove(_G.ESP.PathPoints, 1)
				end
			end

			for i = 1, #_G.ESP.PathPoints - 1 do
				if not _G.ESP.PathLines[i] then
					local l = Drawing.new("Line")
					l.Thickness = 2.5
					l.Transparency = 1
					_G.ESP.PathLines[i] = l
				end

				local p1, v1 = cam:WorldToViewportPoint(_G.ESP.PathPoints[i])
				local p2, v2 = cam:WorldToViewportPoint(_G.ESP.PathPoints[i + 1])

				local line = _G.ESP.PathLines[i]
				if v1 or v2 then
					line.From = Vector2.new(p1.X, p1.Y)
					line.To = Vector2.new(p2.X, p2.Y)
					line.Color = getPathColor()
					line.Visible = true
				else
					line.Visible = false
				end
			end

			for i = #_G.ESP.PathPoints, #_G.ESP.PathLines do
				if _G.ESP.PathLines[i] then
					_G.ESP.PathLines[i].Visible = false
				end
			end
		end)
	else
		if _G.ESP.PathConn then
			pcall(function() _G.ESP.PathConn:Disconnect() end)
			_G.ESP.PathConn = nil
		end
		clearPath()
	end
end, {
	Color = VisualConfig.CorPath or Color3.fromRGB(255, 255, 255),
	Flag = "Path_ESP_Flag"
})

VisualTab:Slider("Path Density", 1, 10, 3, function(value)
	_G.ESP.PathStep = value
end, {
	Flag = "Path_Density_Value"
})

if IS_ALLOWED then
VisualTab:Section("Visual Injections")
end
local CoinsVisual = nil
local MinutesVisual = nil

local LoopEnabled = false
local Connections = {}

local function DisconnectAll()
	for _, c in ipairs(Connections) do
		c:Disconnect()
	end
	table.clear(Connections)
end

local function StartLoop()
	DisconnectAll()

	if CoinsVisual then
		table.insert(Connections,
			Player:GetAttributeChangedSignal("Credits"):Connect(function()
				if LoopEnabled then
					pcall(function()
						Player:SetAttribute("Credits", CoinsVisual)
					end)
				end
			end)
		)
	end

	if Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Minutes") then
		table.insert(Connections,
			Player.leaderstats.Minutes:GetPropertyChangedSignal("Value"):Connect(function()
				if LoopEnabled and MinutesVisual then
					pcall(function()
						Player.leaderstats.Minutes.Value = MinutesVisual
					end)
				end
			end)
		)
	end
end

if IS_ALLOWED then
    VisualTab:Input("Moedas","0",function(text)
        local num = tonumber(text)
			if num then
				CoinsVisual = num
				if LoopEnabled then
					pcall(function()
						Player:SetAttribute("Credits", num)
					end)
				end
			else
				NotificationService:Create("MoedasError","❌ Isso não é um numero válido!")
                task.wait(1.2)
                NotificationService:Remove("MoedasError")
			end
        end)

        VisualTab:Input("Minutos","0",function(text)
            local num = tonumber(text)
			if num and Player:FindFirstChild("leaderstats") and Player.leaderstats:FindFirstChild("Minutes") then
				MinutesVisual = num
				if LoopEnabled then
					pcall(function()
						Player.leaderstats.Minutes.Value = num
					end)
				end
                else
				NotificationService:Create("MinutoError","❌ Isso não é um numero válido!")
                task.wait(1.2)
                NotificationService:Remove("MinutoError")
			end
        end)

        VisualTab:Toggle("Loop Atualization",true,function(state)
            LoopEnabled = state

			if state then
				StartLoop()
			else
				DisconnectAll()
			end
        end)
    end
    
VisualTab:Section("Visual Tools")

local RunService = game:GetService("RunService")

-- Variáveis de Controle
local HideName = false
local HideAllNamesEnabled = false
local AllNamesConnections = {}

-- Função para esconder nome de um personagem específico
local function hide(char, shouldHide)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if shouldHide then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.NameDisplayDistance = 0
        else
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            hum.NameDisplayDistance = 100
        end
    end
    
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BillboardGui") then
            v.Enabled = not shouldHide
        end
    end
end

-- Loop para garantir que o SEU nome continue escondido (caso o jogo tente resetar)
RunService.RenderStepped:Connect(function()
    if HideName and player.Character then
        hide(player.Character, true)
    end
end)

-- Toggle: Esconder MEU Nome
VisualTab:Toggle("Hide Name", false, function(state)
    HideName = state
    if not state and player.Character then
        hide(player.Character, false) -- Restaura se desligar
    end
end)

-- --- Lógica para Esconder TODOS os Nomes ---

local function ClearConnections()
    for _, conn in ipairs(AllNamesConnections) do
        conn:Disconnect()
    end
    table.clear(AllNamesConnections)
end

local function ApplyToAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            hide(p.Character, HideAllNamesEnabled)
        end
    end
end

VisualTab:Toggle("Hide All Names", false, function(state)
    HideAllNamesEnabled = state
    ClearConnections() -- Limpa conexões antigas para não acumular

    if state then
        ApplyToAll()
        -- Monitora novos jogadores que entrarem ou spawnarem
        local conn1 = Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                hide(char, true)
            end)
        end)
        
        -- Monitora personagens de quem já está no servidor
        for _, p in ipairs(Players:GetPlayers()) do
            local conn2 = p.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                hide(char, true)
            end)
            table.insert(AllNamesConnections, conn2)
        end
        table.insert(AllNamesConnections, conn1)
    else
        ApplyToAll() -- Restaura os nomes de todos
    end
end)

local player = Players.LocalPlayer

local HideAllPlayersEnabled = false
local PlayerConnections = {}

-- Função para alterar a visibilidade de um personagem
local function setCharacterVisibility(char, visible)
    if not char then return end
    
    -- Define a transparência (0 para visível, 1 para invisível)
    local transparency = visible and 0 or 1
    
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            -- Ignora a HumanoidRootPart para evitar problemas visuais estranhos
            if v.Name ~= "HumanoidRootPart" then
                v.Transparency = transparency
            end
        elseif v:IsA("BillboardGui") then
            v.Enabled = visible
        end
    end

    -- Esconde o nome no Humanoid também
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = visible and Enum.HumanoidDisplayDistanceType.Viewer or Enum.HumanoidDisplayDistanceType.None
    end
end

-- Limpa as conexões para evitar LAG
local function ClearPlayerConnections()
    for _, conn in ipairs(PlayerConnections) do
        conn:Disconnect()
    end
    table.clear(PlayerConnections)
end

-- Aplica a visibilidade a todos, exceto VOCÊ
local function ApplyVisibilityToOthers()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            setCharacterVisibility(p.Character, not HideAllPlayersEnabled)
        end
    end
end

VisualTab:Toggle("Hide All Characters", false, function(state)
    HideAllPlayersEnabled = state
    ClearPlayerConnections()

    if state then
        ApplyVisibilityToOthers()
        
        -- Monitora novos jogadores ou respawns
        local conn1 = Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5) -- Espera carregar as partes do corpo
                if HideAllPlayersEnabled then
                    setCharacterVisibility(char, false)
                end
            end)
        end)
        
        -- Monitora respawn de quem já está no servidor
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local conn2 = p.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if HideAllPlayersEnabled then
                        setCharacterVisibility(char, false)
                    end
                end)
                table.insert(PlayerConnections, conn2)
            end
        end
        table.insert(PlayerConnections, conn1)
    else
        -- Se desligar, mostra todo mundo de volta
        ApplyVisibilityToOthers()
    end
end)

local function SetTag(nametag, color, font)
    local Character = workspace.Characters:FindFirstChild(player.Name)
    
    if Character and Character:FindFirstChild("BillboardGui") then
        local TagTxt = Character.BillboardGui.Container.Tag

        TagTxt.Text = nametag
        TagTxt.TextColor3 = color
        -- Define a fonte (se não passar nenhuma no argumento, ele usa GothamBold como padrão)
        TagTxt.Font = font or Enum.Font.GothamBold
    else
        warn("Personagem ou BillboardGui não encontrado!")
    end
end

if IS_ALLOWED then
local TagPanel = Library:CreateMiniPanel({Name = "Tags Manager", Size = UDim2.fromOffset(300, 200)})

TagPanel:AddButton("Witch", function()
    SetTag("Witch",Color3.fromRGB(255, 6, 209),Enum.Font.IndieFlower)
end, Color3.fromRGB(255, 6, 209))
TagPanel:AddButton("Vip", function()
    SetTag("Vip",Color3.fromRGB(255, 225, 75),Enum.Font.Highway)
end, Color3.fromRGB(255, 225, 75))
TagPanel:AddButton("Santa", function()
    SetTag("Santa",Color3.fromRGB(199, 61, 63),Enum.Font.Creepster)
end, Color3.fromRGB(199, 61, 63))
TagPanel:AddButton("Cupid", function()
    SetTag("Cupid",Color3.fromRGB(255, 128, 249),Enum.Font.Highway)
end, Color3.fromRGB(255, 128, 249))


VisualTab:Button("Gerenciar Tags", function()
    TagPanel:Toggle()
end)
end


local Char, Hum, HRP
local Camera = workspace.CurrentCamera

-- Configurações Iniciais
local ConfigExploit = {
    FlyKey = Enum.KeyCode.Unknown,
    invisibleKey = Enum.KeyCode.Unknown,
    NoclipKey = Enum.KeyCode.Unknown,
    WalkspeedKey = Enum.KeyCode.Unknown,
    ClickTPKey = Enum.KeyCode.Unknown -- Alterado de Unknown para F para teste
}
local SPEED = 60
local VERTICAL_SPEED = 45
local flying = false

-- Referências de Movimento
local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e6, 1e6, 1e6) -- Força aumentada para estabilidade

local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
BG.D = 100 -- Suavidade do giro

local function SetupChar()
    Char = player.Character or player.CharacterAdded:Wait()
    Hum = Char:WaitForChild("Humanoid")
    HRP = Char:WaitForChild("HumanoidRootPart")
end

SetupChar()
LP.CharacterAdded:Connect(SetupChar)

-- =========================
-- LÓGICA DE MOVIMENTO (LOOP)
-- =========================
RunService.RenderStepped:Connect(function()
    if flying and HRP and Hum then
        local direction = Vector3.zero
        
        -- Cálculo de direção baseado na Câmera
        local lookVec = Camera.CFrame.LookVector
        local rightVec = Camera.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - lookVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - rightVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + rightVec end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end

        BV.Velocity = direction * SPEED
        BG.CFrame = Camera.CFrame
    end
end)

local function startFly()
    if not HRP then return end
    flying = true
    BV.Parent = HRP
    BG.Parent = HRP
    Hum.PlatformStand = true
end

local function stopFly()
    flying = false
    BV.Parent = nil
    BG.Parent = nil
    Hum.PlatformStand = false
end

-- =========================
-- INTERFACE (MERCURYLIB)
-- =========================
local ExploitTab = Window:Tab("Exploit", "rbxassetid://10734981995")

ExploitTab:Section("Movements")

ExploitTab:Toggle("Fly", false, function(state)
    -- Se o MercuryLib já envia o estado (true/false) no argumento 'state'
    if state then
        startFly()
    else
        stopFly()
    end
end, {
    Keybind = {Value = ConfigExploit.FlyKey}
})

ExploitTab:Slider("Fly Speed", 10, 400, 60, function(v)
    SPEED = v
    VERTICAL_SPEED = v * 0.75
end)

-- =========================
-- VARIÁVEIS DE ESTADO
-- =========================
local spinning = false
local spinSpeed = 20
local invisible = false
local currentOffset = Vector3.new(0, 1000, 0) -- Distância que seu corpo real "foge"

-- =========================
-- LÓGICA DE SPIN (GIRO)
-- =========================
RunService.RenderStepped:Connect(function()
    if spinning and HRP then
        HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
    end
end)

-- =========================
-- LOGICA DE INVISIBILIDADE (SEM RESET)
-- =========================
-- Este loop mantém seu corpo real longe enquanto o "fantasma" que você controla interage com o map

-- =========================
-- UI
-- =========================

ExploitTab:Toggle("Spin Bot", false, function(state)
    spinning = state
end)

ExploitTab:Slider("Spin Speed", 10, 500, 20, function(v)
    spinSpeed = v
end)


Noclip = false

local function apply(char)
	for _,v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Physics)
	end
end

local function restore(char)
	for _,v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
		end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
end

RunService.Stepped:Connect(function()
	if not Noclip then return end
	local char = player.Character
	if char then
		apply(char)
	end
end)

player.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	if Noclip then
		apply(char)
	end
end)

local NoclipEnabled = false

RunService.Stepped:Connect(function()
	if not NoclipEnabled then return end
	if not player.Character then return end

	for _,v in ipairs(player.Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

ExploitTab:Toggle("Noclip", false, function(state)
	NoclipEnabled = state

	if not state and player.Character then
		for _, v in ipairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end
end, {
	Keybind = { Value = ConfigExploit.NoclipKey }
})

local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()

-- Variável de controle
_G.ClickTPEnabled = false

ExploitTab:Toggle("Click Teleport", false, function(state)
    _G.ClickTPEnabled = state
end, {
    -- Você pode definir uma tecla padrão aqui se desejar
    Keybind = { Value = ConfigExploit.ClickTPKey } 
})

-- Lógica de execução do Teleporte
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Verifica se o Toggle está ativo e se o clique foi o botão esquerdo
    if _G.ClickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local character = game:GetService("Players").LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Define o destino (onde o mouse está apontando no mundo 3D)
            -- Adicionamos +3 no eixo Y para o player não nascer "dentro" do chão
            local targetPos = Mouse.Hit.Position + Vector3.new(0, 3, 0)
            
            character:PivotTo(CFrame.new(targetPos))
        end
    end
end)

local WalkSpeedEnabled = false
local WalkSpeedValue = 16
local WalkSpeedConn

local function applySpeed(char)
	if not WalkSpeedEnabled then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = WalkSpeedValue
	end
end

ExploitTab:Toggle("WalkSpeed", false, function(state)
	WalkSpeedEnabled = state

	if state then
		local player = Players.LocalPlayer

		if player.Character then
			applySpeed(player.Character)
		end

		if not WalkSpeedConn then
			WalkSpeedConn = player.CharacterAdded:Connect(applySpeed)
		end
	else
		if WalkSpeedConn then
			WalkSpeedConn:Disconnect()
			WalkSpeedConn = nil
		end

		local player = Players.LocalPlayer
		if player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = 16
			end
		end
	end
end,{
    Keybind = {Value = ConfigExploit.WalkspeedKey}
})

ExploitTab:Slider("WalkSpeed Value", 1, 500, 16, function(value)
	WalkSpeedValue = value

	local player = Players.LocalPlayer
	if WalkSpeedEnabled and player.Character then
		applySpeed(player.Character)
	end
end)



-- =========================
-- RAGE TP
-- =========================

local RageConfig = {
    RageEnemy = Enum.KeyCode.Unknown
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

local LP = Players.LocalPlayer

local rageTP = false
local rageMode = "All"
local rageDelay = 0

local rageIndex = 1
local lastTP = 0

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function isEnemy(plr)
    if not LP.Team or not plr.Team then
        return plr ~= LP
    end
    return plr.Team ~= LP.Team
end

local function getValidPlayers()
    local list = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP
        and isEnemy(plr)
        and plr.Character
        and getHRP(plr.Character) then
            table.insert(list, plr)
        end
    end

    return list
end

local function getNearestPlayer()
    local hrp = getHRP(LP.Character)
    if not hrp then return nil end

    local nearest, dist = nil, math.huge

    for _, plr in ipairs(getValidPlayers()) do
        local thrp = getHRP(plr.Character)
        local d = (hrp.Position - thrp.Position).Magnitude

        if d < dist then
            dist = d
            nearest = plr
        end
    end

    return nearest
end

RunService.Heartbeat:Connect(function()
    if not rageTP then return end

    local char = LP.Character
    local HRP = getHRP(char)
    if not HRP then return end

    if rageDelay > 0 and (tick() - lastTP) < rageDelay then return end

    local targets = getValidPlayers()
    if #targets == 0 then return end

    local target

    if rageMode == "Random" then
        target = targets[math.random(1, #targets)]

    elseif rageMode == "Nearest" then
        target = getNearestPlayer()

    else
        if rageIndex > #targets then
            rageIndex = 1
        end

        target = targets[rageIndex]
        rageIndex += 1
    end

    if target and target.Character then
        local thrp = getHRP(target.Character)
        if thrp then
            HRP.CFrame =
                thrp.CFrame *
                CFrame.new(math.random(-2, 2), 0, math.random(-2, 2))

            lastTP = tick()
        end
    end
end)

-- =========================
-- UI
-- =========================

ExploitTab:Section("Enemy Rage TP")

ExploitTab:Toggle("Enemy Rage TP", false, function(v)
    rageTP = v
end,
{
    Keybind = {Value = RageConfig.RageEnemy}
})

ExploitTab:Dropdown("Rage Mode", {"All", "Random", "Nearest"}, function(v)
    rageMode = v
end)

ExploitTab:Slider("Rage Delay", 0, 1, 0, function(v)
    rageDelay = v
end)


local rageTPSpin = false

ExploitTab:Toggle("Rage TP + Spin", false, function(state)
    rageTPSpin = state

    if state then
        rageTP = true
        spinning = true
    else
        rageTP = false
        spinning = false
    end
end)



-- =========================
-- SERVICES
-- =========================

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- =========================
-- CONFIG
-- =========================
local MAX_ZINDEX = 5000
local ParentGui = Library.ScreenGui

if ParentGui:IsA("ScreenGui") then
    ParentGui.DisplayOrder = 100
end

-- =========================
-- DRAG
-- =========================
local function MakeDraggable(frame)
    local dragging, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- =========================
-- MAIN PANEL
-- =========================
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

-- =========================
-- LEFT SIDE
-- =========================
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
Instance.new("UIListLayout", List).Padding = UDim.new(0, 6)

-- =========================
-- RIGHT SIDE
-- =========================
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
Instance.new("UIListLayout", BtnScroll).Padding = UDim.new(0, 6)

-- =========================
-- PLAYER LIST
-- =========================
local selectedPlayer = nil

local function Select(p)
    selectedPlayer = p
    NameLabel.Text = p.DisplayName
    BigIcon.Image = Players:GetUserThumbnailAsync(
        p.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size420x420
    )
end

local function CreateRow(p)
    local Row = Instance.new("TextButton", List)
    Row:SetAttribute("Username", p.Name:lower())
    Row:SetAttribute("DisplayName", p.DisplayName:lower())
    Row.Size = UDim2.new(1, -8, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Row.Text = ""
    Row.ZIndex = MAX_ZINDEX + 1
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local MiniIcon = Instance.new("ImageLabel", Row)
    MiniIcon.Size = UDim2.new(0, 30, 0, 30)
    MiniIcon.Position = UDim2.new(0, 5, 0.5, -15)
    MiniIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MiniIcon.ZIndex = MAX_ZINDEX + 2
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        MiniIcon.Image = Players:GetUserThumbnailAsync(
            p.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size48x48
        )
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

    Row.MouseButton1Click:Connect(function()
        Select(p)
    end)
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
-- RAGE TP
-- =========================
local RAGE_TP = {
    Enabled = false,
    Target = nil,
    Delay = 0
}

local ORBIT = {
    Enabled = false,
    Target = nil,
    Radius = 6,
    Speed = 4,
    Height = 0,
    Angle = 0
}


task.spawn(function()
    while true do
        task.wait(RAGE_TP.Delay)
        if not RAGE_TP.Enabled or not RAGE_TP.Target then continue end

        local HRP = getHRP()
        if not HRP then continue end

        local char = RAGE_TP.Target.Character
        local thrp = char and char:FindFirstChild("HumanoidRootPart")
        if not thrp then continue end

        HRP.CFrame = thrp.CFrame * CFrame.new(
            math.random(-2, 2),
            0,
            math.random(-2, 2)
        )
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not ORBIT.Enabled or not ORBIT.Target then return end

    local HRP = getHRP()
    if not HRP then return end

    local char = ORBIT.Target.Character
    local thrp = char and char:FindFirstChild("HumanoidRootPart")
    if not thrp then return end

    ORBIT.Angle += dt * ORBIT.Speed

    local offset = Vector3.new(
        math.cos(ORBIT.Angle) * ORBIT.Radius,
        ORBIT.Height,
        math.sin(ORBIT.Angle) * ORBIT.Radius
    )

    HRP.CFrame = CFrame.new(thrp.Position + offset, thrp.Position)
end)


CreateBtn("RAGE TP (Target)", function(p)
    if RAGE_TP.Enabled and RAGE_TP.Target == p then
        RAGE_TP.Enabled = false
        RAGE_TP.Target = nil
        return "RAGE TP (Target)"
    else
        RAGE_TP.Enabled = true
        RAGE_TP.Target = p
        return "STOP RAGE TP"
    end
end)

CreateBtn("ORBIT PLAYER", function(p)
    if ORBIT.Enabled and ORBIT.Target == p then
        ORBIT.Enabled = false
        ORBIT.Target = nil
        return "ORBIT PLAYER"
    else
        ORBIT.Enabled = true
        ORBIT.Target = p
        ORBIT.Angle = 0
        return "STOP ORBIT"
    end
end)


-- =========================
-- REFRESH
-- =========================
local function Refresh()
    for _, v in pairs(List:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            CreateRow(p)
        end
    end
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
Players.PlayerRemoving:Connect(Refresh)

Refresh()

-- =========================
-- TOGGLE
-- =========================
_G.TogglePlayerPanel2 = function()
    local open = not Master.Visible
    if open then
        Master.Visible = true
        TweenService:Create(
            Master,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { GroupTransparency = 0 }
        ):Play()
    else
        local t = TweenService:Create(
            Master,
            TweenInfo.new(0.3),
            { GroupTransparency = 1 }
        )
        t:Play()
        t.Completed:Connect(function()
            Master.Visible = false
        end)
    end
end

ExploitTab:Button("Gerenciar Players", function()
    _G.TogglePlayerPanel2()
end)

ExploitTab:Section("Sync")

ConfigSync ={
    DesyncKey = Enum.KeyCode.Unknown
}

local fakeLag = false
local lagDelay = 0.15
local lastCF

RunService.Heartbeat:Connect(function(dt)
    if fakeLag and HRP then
        if not lastCF then
            lastCF = HRP.CFrame
        end
        HRP.CFrame = lastCF
        task.delay(lagDelay, function()
            if HRP then
                lastCF = HRP.CFrame
            end
        end)
    end
end)

ExploitTab:Toggle("Desync / Fake Lag", false, function(v)
    fakeLag = v
end,{
    Keybind = {Value = ConfigSync.DesyncKey}
})

local targetStrafe = false
local strafeRadius = 6
local strafeSpeed = 3
local strafeTarget

RunService.Heartbeat:Connect(function(dt)
    if targetStrafe and strafeTarget and HRP then
        local hrpT = strafeTarget.Character and strafeTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrpT then
            local angle = tick() * strafeSpeed
            local offset = Vector3.new(
                math.cos(angle) * strafeRadius,
                0,
                math.sin(angle) * strafeRadius
            )
            HRP.CFrame = hrpT.CFrame * CFrame.new(offset)
        end
    end
end)

ExploitTab:Toggle("Target Strafe", false, function(v)
    targetStrafe = v
end)

local fling = false
local flingPower = 8000

local AV = Instance.new("BodyAngularVelocity")
AV.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
AV.AngularVelocity = Vector3.new(0, flingPower, 0)

ExploitTab:Toggle("Body Fling", false, function(v)
    fling = v
    if v and HRP then
        AV.Parent = HRP
    else
        AV.Parent = nil
    end
end)


ConfigVital ={
    DashKey = Enum.KeyCode.Unknown,
    AntKb = Enum.KeyCode.Unknown,
    FakeLag = Enum.KeyCode.Unknown,
    CrashKey = Enum.KeyCode.Unknown
}

ExploitTab:Section("Vital")

local freezeSelf = false

RunService.Stepped:Connect(function()
    if freezeSelf and HRP then
        HRP.Anchored = true
    elseif HRP then
        HRP.Anchored = false
    end
end)

ExploitTab:Toggle("Freeze Self", false, function(v)
    freezeSelf = v
end,{
    Keybind = {Value = ConfigVital.FakeLag}
})


local antiKB = false

RunService.Heartbeat:Connect(function()
    if antiKB and HRP then
        HRP.AssemblyLinearVelocity = Vector3.zero
    end
end)

ExploitTab:Toggle("Anti Knockback", false, function(v)
    antiKB = v
end,{
    Keybind = {Value = ConfigVital.AntKb}
})


local dashForce = 120
local dashCooldown = false

local function dash()
    if dashCooldown or not HRP then return end
    dashCooldown = true

    HRP.AssemblyLinearVelocity =
        Camera.CFrame.LookVector * dashForce

    task.delay(0.4, function()
        dashCooldown = false
    end)
end

ExploitTab:Button("Dash", function()
    dash()
end,{
    Keybind = {Value = ConfigVital.DashKey}
})

-- SERVICES
-- =========================
-- BRUTE OVERDRIVE v2
-- ANTI-RESPAWN + SCALE TO CRASH
-- =========================
local RS, UIS, Plr = game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Players").LocalPlayer
local Enabled, Conn = false, nil

-- Variáveis de controle
local lastPos = nil
local clickCount, lastClick = 0, 0
local CLICK_WINDOW = 0.5 

local function ToggleAnti(state)
    Enabled = state
    
    if Conn then Conn:Disconnect(); Conn = nil end
    
    if state then
        -- Salva a posição exata antes de começar o "caos"
        local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            lastPos = hrp.CFrame 
            print("Posição salva!")
        end
    else
        -- Quando desativar, retorna o jogador para onde ele estava
        local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp and lastPos then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Reseta a velocidade para não ser arremessado
            hrp.CFrame = lastPos
            print("Retornado à posição original.")
        end
        return
    end

    Conn = RS.Heartbeat:Connect(function()
        local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not Enabled then 
            if Conn then Conn:Disconnect(); Conn = nil end 
            return 
        end

        -- Sua lógica de Overdrive
        hrp.AssemblyLinearVelocity = Vector3.new(math.random(-1e7, 1e7), 1e7, math.random(-1e7, 1e7))

        local frame = math.floor(tick() * 60) % 3
        if frame == 0 then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 50000, 0)
        elseif frame == 1 then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -50000, 0)
        else
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(360)), 0)
        end
    end)
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not Enabled then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local now = tick()
        if now - lastClick > CLICK_WINDOW then clickCount = 1 else clickCount += 1 end
        lastClick = now
        
        if clickCount >= 3 then
            ToggleAnti(false)
        end
    end
end)



ExploitTab:Toggle("Crash/Bug (Best Mobile Crasher)",false,function(state)
ToggleAnti(state)
end,{
    Keybind = {Value = ConfigVital.CrashKey}
})


local MiscTab = Window:Tab("Misc","rbxassetid://10709782582")

local ConfigMisc = {
    
}

MiscTab:Section("Tools")

MiscTab:Button("Rejoin",function()
		local placeId = game.PlaceId
		local jobId = game.JobId -- mantém o mesmo servidor

		TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end)

do
	_G.AntiAfkConnection = _G.AntiAfkConnection or nil

	MiscTab:Toggle("AFK Bypass", false, function(state)
		if not Player then Player = Players.LocalPlayer end

		if state then
			if not _G.AntiAfkConnection then
				_G.AntiAfkConnection = Player.Idled:Connect(function()
					local VirtualUser = game:GetService("VirtualUser")
					VirtualUser:CaptureController()
					VirtualUser:ClickButton2(Vector2.new())
				end)
			end
		else
			if _G.AntiAfkConnection then
				_G.AntiAfkConnection:Disconnect()
				_G.AntiAfkConnection = nil
			end
		end
	end)
end

MiscTab:Button("Copy CFrame + Rotate",function()
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local p = hrp.Position

local text = string.format(
    "%.6f, %.6f, %.6f",
    p.X,
    p.Y,
    p.Z)
    setclipboard(text)
end)

MiscTab:Section("Loads")

MiscTab:Button("Dex Explorer V5",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/Dex/refs/heads/master/main.lua"))()
end)

MiscTab:Button("Infinity Yeld",function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
end)

MiscTab:Button("Remote Spy (Require 90% Sunc Executor)",function()
loadstring(game:HttpGetAsync("https://github.com/richie0866/remote-spy/releases/latest/download/RemoteSpy.lua"))()
end)


Library:CreateSettings(Window)

print("Requires: DobeInsert, Executors: ALL, InjectionMode: Direct")
print("Internal game, qol: 70%")
print("All Cores loaded")

