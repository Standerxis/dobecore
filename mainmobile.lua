--[[

_G.SystemCore = {}
_G.SystemCore.Cache = {}
_G.SystemCore.Threads = {}
_G.SystemCore.Internal = {}

function _G.SystemCore:Init()
    local seed = math.random(100000,999999)
    self.Cache["seed"] = seed
    return seed
end

function _G.SystemCore:Encrypt(v)
    local r = ""
    for i = 1, #tostring(v) do
        r = r .. string.char(math.random(33,126))
    end
    return r
end

function _G.SystemCore:Decrypt(v)
    return tostring(v):reverse()
end

function _G.SystemCore:Sync()
    for i = 1, 50 do
        self.Cache[i] = math.random()
    end
end

function _G.SystemCore.Internal:Ping()
    local x = 0
    for i = 1, 1000 do
        x = x + math.sin(i)
    end
    return x
end

function _G.SystemCore.Internal:Heartbeat()
    local t = tick()
    repeat
        t = t + math.random()
    until t > tick() + 0.01
end

_G.Loader = {}
_G.Loader.Version = "v"..math.random(100,999)
_G.Loader.Status = false

function _G.Loader:Load()
    self.Status = not self.Status
    return self.Status
end

function _G.Loader:Validate(k)
    if not k then
        return false
    end
    local s = 0
    for i = 1, #k do
        s = s + string.byte(k,i)
    end
    return s % 2 == 0
end

_G.AntiDump = {}

function _G.AntiDump:Check()
    local env = getfenv and getfenv(0) or {}
    for i,v in pairs(env) do
        if tostring(i):lower():find("dump") then
            return false
        end
    end
    return true
end

function _G.AntiDump:Loop()
    for i = 1, math.random(10,40) do
        coroutine.wrap(function()
            local a = 0
            for j = 1, 500 do
                a = a + math.random()
            end
        end)()
    end
end

_G.Memory = {}

for i = 1, 200 do
    _G.Memory[i] = {
        key = tostring(math.random())..tostring(os.clock()),
        value = math.random(1,999999)
    }
end

function _G.Memory:Flush()
    for i in pairs(self) do
        self[i] = nil
    end
end

function _G.Memory:Randomize()
    local t = {}
    for i = 1, 100 do
        t[i] = math.random()
    end
    return t
end

function FakeFunction_A()
    local x = 0
    for i = 1, 10000 do
        x = x + i
    end
    return x
end

function FakeFunction_B()
    local str = ""
    for i = 1, 200 do
        str = str .. string.char(math.random(65,90))
    end
    return str
end

function FakeFunction_C()
    return FakeFunction_A() .. tostring(FakeFunction_B())
end

for i = 1, 100 do
    _G["FUNC_"..i] = function()
        return math.random() * os.clock()
    end
end

-- fake anti reverse
local function __internal_runtime_validator__()
    local t = {}
    for i = 1, 300 do
        t[i] = math.random()
    end
    return t[math.random(1,#t)]
end

__internal_runtime_validator__()

]]
-- ==========================================
-- FUNÇÃO NEED PREMIUM
-- ==========================================

getgenv().NeedPremium = function(callback)
    -- Verifica se a variável global IsPremium é verdadeira
    if getgenv().IsPremium == true then
        -- Se for premium, executa a função (o código que você colocar dentro)
        callback()
    else
        -- Se não for premium, avisa o jogador
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Dobe Panel",
            Text = "Esta função é restrita para usuários PREMIUM.",
            Icon = "rbxassetid://12345678", -- Opcional: ID de um ícone
            Duration = 5
        })

        -- Caso queira que o KeySystem abra novamente se não for premium:
        -- (Isso assume que o script do KeySystem pode ser chamado novamente)
        warn("Acesso negado: Usuário não possui licença Premium.")
    end
end

-- ==========================================
-- EXEMPLO DE COMO USAR NO SEU SCRIPT:
-- ==========================================

--[[
NeedPremium(function()
    print("Executando Aimbot Premium...")
    -- Coloque aqui o código da sua função premium
end)
--]]

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


PescaTab:Section("Autos Mobile")

--[[
    SCRIPT AUTOFISH FISCH - VERSÃO MOBILE OTIMIZADA
    Simulação de Toque Real e Compensação de Inset
]]

local S = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VIM = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    UserInputService = game:GetService("UserInputService")
}
local Player = S.Players.LocalPlayer

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
-- FUNÇÕES DE SUPORTE MOBILE
-- =========================

local function GetCenter(inst)
    if not inst then return Vector2.new(0,0) end
    -- AbsolutePosition no mobile já considera a escala da tela corretamente
    return Vector2.new(inst.AbsolutePosition.X + inst.AbsoluteSize.X / 2, inst.AbsolutePosition.Y + inst.AbsoluteSize.Y / 2)
end

local function MobileClick(x, y)
    local inset = S.GuiService:GetGuiInset()
    -- Adiciona um pequeno "jitter" de 1-2 pixels para parecer um toque humano real
    local finalX = x + inset.X + math.random(-1, 1)
    local finalY = y + inset.Y + math.random(-1, 1)
    
    -- Simula o Início do Toque (Touch Start)
    S.VIM:SendTouchEvent(0, 0, finalX, finalY) 
    task.wait(math.random(3, 7) / 100) -- Tempo de pressão variável (humano)
    -- Simula o Fim do Toque (Touch End)
    S.VIM:SendTouchEvent(0, 2, finalX, finalY)
end

local function GetRemote()
    return S.ReplicatedStorage:FindFirstChild("Modules") 
           and S.ReplicatedStorage.Modules:FindFirstChild("Events") 
           and S.ReplicatedStorage.Modules.Events:FindFirstChild("RemoteEvent")
end

-- Restante das funções de lógica (Equipar, Vender, Stats) permanecem similares
-- mas agora chamam o MobileClick quando necessário.

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
    local rod = char:FindFirstChild("Fishing Rod") or Player.Backpack:FindFirstChild("Fishing Rod")
    if rod and rod.Parent ~= char then 
        rod.Parent = char 
        task.wait(0.5)
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
            task.wait(0.8)
            r:FireServer("SellAllFishes")
            task.wait(0.5)
            r:FireServer("RepairAllFishingRods")
            task.wait(0.8)
            char:PivotTo(oldPos)
            task.wait(0.5)
            Bot.Selling = false
            EquipRod()
            task.wait(0.3)
            r:FireServer("Throw", 1)
        end
    elseif action == "Throw" then
        EquipRod()
        task.wait(0.3)
        r:FireServer("Throw", 1)
    end
end

-- =========================
-- LOOP PRINCIPAL (AJUSTADO PARA TOQUE)
-- =========================

local function StartBot()
    if Bot.Conn then Bot.Conn:Disconnect() end
    Bot.Selling = false
    Bot.MinigameActive = false

    DoAction("Throw")

    -- Check de inventário
    task.spawn(function()
        while Bot.Enabled do
            if not Bot.Selling then
                local cur, max = GetFishStats()
                if cur and max and cur >= max then
                    DoAction("Sell")
                end
            end
            task.wait(5) -- Aumentado para economizar bateria/processamento no mobile
        end
    end)

    Bot.Conn = S.RunService.Heartbeat:Connect(function()
        if not Bot.Enabled or Bot.Selling then return end

        local gui = Player.PlayerGui
        
        -- Fisgada (Hook)
        local hook = gui:FindFirstChild("HookMeter")
        if hook and (os.clock() - Bot.LastHookClick >= Bot.HookCooldown) then
            local mid = hook:FindFirstChild("MiddleCircle", true)
            if mid and mid.Visible then
                Bot.LastHookClick = os.clock()
                local c = GetCenter(mid)
                MobileClick(c.X, c.Y)
            end
        end

        -- Minigame de Puxar
        local catch = gui:FindFirstChild("CatchIndicator")
        local img = catch and catch:FindFirstChild("ImageButton")
        if img then
            local moving, target
            for _, v in ipairs(img:GetDescendants()) do
                if v:IsA("Frame") then
                    if v.BackgroundColor3 == Color3.fromRGB(242, 84, 84) then moving = v
                    elseif v.BackgroundColor3 == Color3.fromRGB(67, 200, 120) then target = v end
                end
            end

            if moving and target then
                Bot.MinigameActive = true
                local mX = GetCenter(moving).X
                local tX = GetCenter(target).X
                local delta = mX - tX

                -- Lógica de clique baseada na inversão de direção (Mobile Safe)
                if Bot.LastDelta and math.sign(Bot.LastDelta) ~= math.sign(delta) and tick() - Bot.LastClick > 0.08 then
                    Bot.LastClick = tick()
                    MobileClick(tX, GetCenter(target).Y)
                end
                Bot.LastDelta = delta
            end
        elseif Bot.MinigameActive then
            Bot.MinigameActive = false
            Bot.LastDelta = nil
            task.wait(1.5)
            local r = GetRemote()
            if r then r:FireServer("FishDecision", true) end
            
            task.wait(1.2)
            if Bot.Enabled and not Bot.Selling then 
                DoAction("Throw") 
            end
        end
    end)
end

-- =========================
-- UI TOGGLE
-- =========================
PescaTab:Toggle("Autofish Mobile", false, function(state)
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

PescaTab:Section("Autos")

local S = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VIM = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService")
}
local Player = S.Players.LocalPlayer

local Bot = {
    Autofish = false,
    Autosell = false,
    Autorepair = false,
    Selling = false,
    MinigameActive = false,
    LastDelta = nil,
    LastClick = 0,
    LastHookClick = 0,
    HookCooldown = 0.6,
    Conn = nil
}

-- =========================
-- FUNÇÕES DE SUPORTE
-- =========================
local function GetRemote()
    return S.ReplicatedStorage:FindFirstChild("Modules") 
           and S.ReplicatedStorage.Modules:FindFirstChild("Events") 
           and S.ReplicatedStorage.Modules.Events:FindFirstChild("RemoteEvent")
end

local function EquipRod()
    local char = Player.Character
    if not char then return nil end
    local rod = char:FindFirstChild("Fishing Rod") or Player.Backpack:FindFirstChild("Fishing Rod")
    if rod then 
        rod.Parent = char 
        return rod
    end
    return nil
end

-- Função centralizada para lançar a vara
local function ThrowRod()
    if not Bot.Autofish or Bot.Selling then return end
    
    local r = GetRemote()
    if r then
        EquipRod()
        task.wait(0.3) -- Delay necessário para o servidor reconhecer a vara na mão
        r:FireServer("Throw", 1)
    end
end

local function GetCenter(inst)
    if not inst then return Vector2.new(0,0) end
    return Vector2.new(inst.AbsolutePosition.X + inst.AbsoluteSize.X / 2, inst.AbsolutePosition.Y + inst.AbsoluteSize.Y / 2)
end

local function Click(x, y)
    local inset = S.GuiService:GetGuiInset()
    S.VIM:SendMouseButtonEvent(x + inset.X, y + inset.Y, 0, true, game, 1)
    task.wait(0.05)
    S.VIM:SendMouseButtonEvent(x + inset.X, y + inset.Y, 0, false, game, 1)
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

-- =========================
-- LÓGICA MERCANTE (SELL/REPAIR)
-- =========================
local function GoToMerchant()
    local r = GetRemote()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local npc = workspace:FindFirstChild("NPCS") and workspace.NPCS:FindFirstChild("Fisherman")
    
    if root and npc and npc:FindFirstChild("HumanoidRootPart") and r then
        local oldPos = root.CFrame
        Bot.Selling = true
        
        char:PivotTo(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3))
        task.wait(0.8)
        
        if Bot.Autosell then
            r:FireServer("SellAllFishes")
            task.wait(0.5)
        end
        
        if Bot.Autorepair then
            r:FireServer("RepairAllFishingRods")
            task.wait(0.5)
        end
        
        char:PivotTo(oldPos)
        task.wait(0.8)
        Bot.Selling = false
        
        -- Após voltar do vendedor, lança a vara novamente
        if Bot.Autofish then
            ThrowRod()
        end
    end
end

-- =========================
-- LOOP E HEARTBEAT
-- =========================
local function StartLogic()
    if Bot.Conn then return end -- Evita duplicar o loop

    -- Monitor de Mochila
    task.spawn(function()
        while (Bot.Autofish or Bot.Autosell or Bot.Autorepair) do
            if not Bot.Selling then
                local cur, max = GetFishStats()
                if cur and max and cur >= max then
                    if Bot.Autosell or Bot.Autorepair then
                        GoToMerchant()
                    end
                end
            end
            task.wait(2)
        end
        if Bot.Conn then Bot.Conn:Disconnect() Bot.Conn = nil end
    end)

    Bot.Conn = S.RunService.Heartbeat:Connect(function()
        if not Bot.Autofish or Bot.Selling then return end

        local gui = Player.PlayerGui
        
        -- 1. Fisgada (Hook)
        local hook = gui:FindFirstChild("HookMeter")
        if hook and (os.clock() - Bot.LastHookClick >= Bot.HookCooldown) then
            local mid = hook:FindFirstChild("MiddleCircle", true)
            if mid then
                Bot.LastHookClick = os.clock()
                local c = GetCenter(mid)
                Click(c.X, c.Y)
            end
        end

        -- 2. Minigame (Reel)
        local catch = gui:FindFirstChild("CatchIndicator")
        local img = catch and catch:FindFirstChild("ImageButton")
        if img then
            local moving, target
            for _, v in ipairs(img:GetDescendants()) do
                if v:IsA("Frame") then
                    if v.BackgroundColor3 == Color3.fromRGB(242, 84, 84) then moving = v
                    elseif v.BackgroundColor3 == Color3.fromRGB(67, 200, 120) then target = v end
                end
            end

            if moving and target then
                Bot.MinigameActive = true
                local mX = GetCenter(moving).X
                local tX = GetCenter(target).X
                local delta = mX - tX

                if Bot.LastDelta and math.sign(Bot.LastDelta) ~= math.sign(delta) and tick() - Bot.LastClick > 0.1 then
                    Bot.LastClick = tick()
                    Click(tX, GetCenter(target).Y)
                end
                Bot.LastDelta = delta
            end
        elseif Bot.MinigameActive then
            -- Fim do Minigame
            Bot.MinigameActive = false
            Bot.LastDelta = nil
            task.wait(1.5)
            local r = GetRemote()
            if r then r:FireServer("FishDecision", true) end
            
            task.wait(1.5) -- Espera a animação de pegar o peixe sumir
            ThrowRod()
        end
    end)
end

-- =========================
-- INTERFACE (TOGGLES)
-- =========================

PescaTab:Toggle("Auto Fish", false, function(state)
    Bot.Autofish = state
    if state then 
        StartLogic()
        task.wait(0.5)
        ThrowRod() 
    end
end)

PescaTab:Toggle("Auto Sell", false, function(state)
    Bot.Autosell = state
    if state then StartLogic() end
end)

PescaTab:Toggle("Auto Repair", false, function(state)
    Bot.Autorepair = state
    if state then StartLogic() end
end)
end
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

loadstring(game:HttpGet("https://raw.githubusercontent.com/Standerxis/dobecore/refs/heads/main/PainelPlayers.lua"))()

ConfigTeleport = {
    TpSave = Enum.KeyCode.Unknown,
    SaveTp = Enum.KeyCode.Unknown,
    OpenPlayer = Enum.KeyCode.Unknown
}


TeleportTab:Button("Gerenciar Players", function()
    _G.TogglePlayerPanel()
end,{
    Keybind = {Value = ConfigTeleport.OpenPlayer}
})



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
    TeclaEsp = Enum.KeyCode.Unknown,
    CorHuBplr = Color3.fromRGB(3, 111, 252)
}

VisualTab:Section("Core")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configuração Global
_G.HubUsersESP = _G.HubUsersESP or {
    Enabled = false,
    RGBEnabled = false,
    Color = VisualConfig.CorHuBplr,
    RGBHue = 0,
    RGBSpeed = 0.25,
    Highlights = {}
}

--- ### Gerenciador de Cores RGB ### ---
if not _G.HubUsersESP.RGBConn then
    _G.HubUsersESP.RGBConn = RunService.RenderStepped:Connect(function(dt)
        if _G.HubUsersESP.RGBEnabled then
            _G.HubUsersESP.RGBHue = (_G.HubUsersESP.RGBHue + dt * _G.HubUsersESP.RGBSpeed) % 1
        end
    end)
end

local function getCurrentColor()
    if _G.HubUsersESP.RGBEnabled then
        return Color3.fromHSV(_G.HubUsersESP.RGBHue, 1, 1)
    end
    return _G.HubUsersESP.Color
end

--- ### Lógica do Highlight ### ---

local function removeHighlight(plr)
    if _G.HubUsersESP.Highlights[plr] then
        _G.HubUsersESP.Highlights[plr]:Destroy()
        _G.HubUsersESP.Highlights[plr] = nil
    end
end

local function UpdateHubUsers()
    if not _G.HubUsersESP.Enabled then
        for plr, _ in pairs(_G.HubUsersESP.Highlights) do
            removeHighlight(plr)
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            local char = plr.Character
            -- Verifica se o jogador tem a Tag do seu sistema no Head
            local hasTag = char and char:FindFirstChild("Head") and char.Head:FindFirstChild("DobeTag")

            if char and hasTag then
                if not _G.HubUsersESP.Highlights[plr] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "HubUserHighlight"
                    hl.Adornee = char
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    _G.HubUsersESP.Highlights[plr] = hl
                end

                -- Atualiza a cor em tempo real (suporta RGB)
                local color = getCurrentColor()
                local hl = _G.HubUsersESP.Highlights[plr]
                hl.FillColor = color
                hl.OutlineColor = color
            else
                removeHighlight(plr)
            end
        end
    end
end

-- Loop de atualização leve (não precisa ser RenderStepped para Highlights)
task.spawn(function()
    while true do
        UpdateHubUsers()
        task.wait(0.1) -- Atualiza 10 vezes por segundo, suficiente para o efeito
    end
end)

-- Limpeza ao sair
Players.PlayerRemoving:Connect(removeHighlight)

--- ### Integração com sua UI ### ---

VisualTab:Toggle("Show Hub Users", false, function(state, extra)
    if state == "Color" then
        _G.HubUsersESP.Color = extra
        return
    end
    
    _G.HubUsersESP.Enabled = state
end, {
    Color = VisualConfig.CorHuBplr
})

VisualTab:Section("Screen Functions")

local KeybindListGui = Instance.new("ScreenGui", game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
KeybindListGui.Name = "KeybindList"

local KeybindFrame = Instance.new("Frame", KeybindListGui)
KeybindFrame.Position = UDim2.new(1, -150, 0.5, -100)
KeybindFrame.Size = UDim2.fromOffset(140, 200)
KeybindFrame.BackgroundTransparency = 1
KeybindFrame.Visible = false 

local UIList = Instance.new("UIListLayout", KeybindFrame)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)

-- Tornamos a função global na Library para facilitar a chamada
function Library:UpdateKeybindRender()
    -- Limpa a lista atual
    for _, child in pairs(KeybindFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    -- Se o Toggle estiver ligado, reconstrói a lista
    if _G.ShowKeybinds then
        for flag, keyName in pairs(Library.Flags.Binds) do
            if keyName ~= "Unknown" and keyName ~= "None" then
                local bLabel = Instance.new("TextLabel", KeybindFrame)
                bLabel.Size = UDim2.new(1, 0, 0, 20)
                bLabel.BackgroundTransparency = 0.8
                bLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                bLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                bLabel.Text = " " .. flag .. ": [" .. keyName .. "]"
                bLabel.Font = Enum.Font.GothamMedium
                bLabel.TextSize = 12
                bLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local Corner = Instance.new("UICorner", bLabel)
                Corner.CornerRadius = UDim.new(0, 4)
            end
        end
    end
end

VisualTab:Toggle("Show Keybinds", false, function(state)
    _G.ShowKeybinds = state
    KeybindFrame.Visible = state
    Library:UpdateKeybindRender()
end)


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

-- Configurações Iniciais
local ConfigExploit = {
    FlyKey = Enum.KeyCode.Unknown,
    invisibleKey = Enum.KeyCode.Unknown,
    NoclipKey = Enum.KeyCode.Unknown,
    WalkspeedKey = Enum.KeyCode.Unknown,
    OpenPanel = Enum.KeyCode.Unknown,
    ClickTPKey = Enum.KeyCode.Unknown -- Alterado de Unknown para F para teste
}
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Char, Hum, HRP

local function SetupChar()
	Char = LP.Character or LP.CharacterAdded:Wait()
	Hum = Char:WaitForChild("Humanoid")
	HRP = Char:WaitForChild("HumanoidRootPart")
end

SetupChar()
LP.CharacterAdded:Connect(SetupChar)

-- =========================
-- CONFIG
-- =========================
local SPEED = 60
local VERTICAL_SPEED = 45

-- =========================
-- STATE
-- =========================
local flying = false

-- =========================
-- BODY MOVERS
-- =========================
local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e5, 1e5, 1e5)

local BG = Instance.new("BodyGyro")
BG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
BG.P = 9000

-- =========================
-- MOVIMENTO
-- =========================
RunService.RenderStepped:Connect(function()
	if not flying or not HRP or not Hum then return end

	local cam = Camera.CFrame
	local move = Vector3.zero

	local look = cam.LookVector
	local right = cam.RightVector

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		move += look
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		move -= look
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		move -= right
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		move += right
	end

	if move.Magnitude > 0 then
		move = move.Unit
	end

	BV.Velocity = Vector3.new(
		move.X * SPEED,
		move.Y * VERTICAL_SPEED,
		move.Z * SPEED
	)

	BG.CFrame = cam
end)


-- =========================
-- CONTROLES
-- =========================
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
	BV.Velocity = Vector3.zero
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
end,{
    Keybind = {Value = ConfigExploit.OpenPanel}
})

ExploitTab:Section("Sync")

ConfigSync = {
    DesyncKey = Enum.KeyCode.Unknown
}

local fakeLag = false
local lagDelay = 0.15 -- Tempo que ele "anda" antes de ser puxado (0.1 a 0.2 é o ideal)
local lastStoredCF = nil

-- Loop de Movimentação Falsa
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if fakeLag and hrp then
        -- Se não temos uma posição salva, salvamos a atual
        if not lastStoredCF then
            lastStoredCF = hrp.CFrame
        end

        -- Efeito de Teleporte Reverso (Puxa de volta para a sombra)
        -- Usamos task.wait para criar o intervalo de "ida e volta"
        task.spawn(function()
            local currentPos = hrp.CFrame
            task.wait(lagDelay)
            if fakeLag and hrp then
                -- O "Pulo" do gato: ele alterna entre a posição nova e a antiga
                hrp.CFrame = lastStoredCF 
                task.wait(0.05)
                lastStoredCF = currentPos -- Atualiza para a posição que ele tentou ir
            end
        end)
    end
end)

ExploitTab:Toggle("Desync / Fake Lag (Rubberband)", false, function(v)
    fakeLag = v
    if not v then
        lastStoredCF = nil
    end
end, {
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
    SoloSessiontp = Enum.KeyCode.Unknown,
    ResetVoice = Enum.KeyCode.Unknown
}

MiscTab:Section("Tools")

local VoiceChatService = game:GetService("VoiceChatService")
local RunService = game:GetService("RunService")

local function RealVoiceReset()
    if not VoiceChatService or not NotificationService then return end

    local notifId = "VoiceResetTimer"
    local duration = 2 -- segundos
    local startTime = os.clock()

    -- cria a notificação
    NotificationService:Create(
        notifId,
        "Desconectando do Voice Chat em 2.00s",
        3
    )

    -- contador em tempo real
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local elapsed = os.clock() - startTime
        local remaining = math.max(0, duration - elapsed)

        NotificationService:Update(
            notifId,
            string.format(
                "Desconectando do Voice Chat em %.2fs",
                remaining
            )
        )

        if remaining <= 0 then
            conn:Disconnect()

            -- sai do voice
            local left = pcall(function()
                VoiceChatService:leaveVoice()
            end)

            task.wait(0.8)

            -- entra de novo
            local joined = pcall(function()
                VoiceChatService:joinVoice()
            end)

            -- update final
            if left and joined then
                NotificationService:Update(
                    notifId,
                    "Voice Chat reconectado!"
                )
                task.wait(0.8)
                NotificationService:Remove(notifId)
            else
                NotificationService:Update(
                    notifId,
                    "Reset parcial aplicado."
                )
                task.wait(0.8)
                NotificationService:Remove(notifId)
            end
        end
    end)
end
MiscTab:Button("Reset Voice", function()
    RealVoiceReset()
end,{
    Keybind = {Value = ConfigMisc.ResetVoice}
})

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


MiscTab:Button("Solo Session",function()
if not Player then Player = Players.LocalPlayer end
		local player = Player
		local character = player.Character or player.CharacterAdded:Wait()

		local soloPosition = Vector3.new(10000, 50, 10000)
		local soloFolder = workspace:FindFirstChild("SoloHouse")

		if not soloFolder then
			soloFolder = Instance.new("Folder")
			soloFolder.Name = "SoloHouse"
			soloFolder.Parent = workspace

			local floor = Instance.new("Part")
			floor.Size = Vector3.new(40, 1, 40)
			floor.CFrame = CFrame.new(soloPosition)
			floor.Anchored = true
			floor.BrickColor = BrickColor.new("Dark green")
			floor.Parent = soloFolder

			local function wall(size, pos)
				local p = Instance.new("Part")
				p.Size = size
				p.CFrame = CFrame.new(pos)
				p.Anchored = true
				p.BrickColor = BrickColor.new("Medium stone grey")
				p.Parent = soloFolder
			end

			wall(Vector3.new(40, 20, 1), soloPosition + Vector3.new(0, 10, -20))
			wall(Vector3.new(40, 20, 1), soloPosition + Vector3.new(0, 10, 20))
			wall(Vector3.new(1, 20, 40), soloPosition + Vector3.new(-20, 10, 0))
			wall(Vector3.new(1, 20, 40), soloPosition + Vector3.new(20, 10, 0))

			local roof = Instance.new("Part")
			roof.Size = Vector3.new(40, 1, 40)
			roof.CFrame = CFrame.new(soloPosition + Vector3.new(0, 20, 0))
			roof.Anchored = true
			roof.BrickColor = BrickColor.new("Really red")
			roof.Parent = soloFolder
		end

		local humanoidRoot = character:WaitForChild("HumanoidRootPart")
		humanoidRoot.CFrame = CFrame.new(soloPosition + Vector3.new(0, 3, 0))
end,{
    Keybind = {Value = ConfigMisc.SoloSessiontp}
})

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
-- Referências de Serviço
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain") or workspace.Terrain
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Plr = Players.LocalPlayer

-- Tabelas de Estado
local originalMaterials = {}
local shaderEffects = {}
local connections = {fb = nil, water = nil}

-- Configuração de Efeitos (Criados uma única vez)
local underwaterBlur = Instance.new("BlurEffect")
local underwaterColor = Instance.new("ColorCorrectionEffect")

-- Melhoria do Sistema de Áudio Subaquático
local waterEqualizer = Instance.new("EqualizerSoundEffect")
waterEqualizer.HighGain = -80 
waterEqualizer.MidGain = -45  
waterEqualizer.LowGain = 5    -- Leve boost no grave para impacto
waterEqualizer.Enabled = false
waterEqualizer.Parent = SoundService

local waterReverb = Instance.new("ReverbSoundEffect")
waterReverb.Density = 1
waterReverb.Diffusion = 1
waterReverb.DryLevel = -3
waterReverb.WetLevel = 0
waterReverb.Enabled = false
waterReverb.Parent = SoundService

-- Interface
local GraphicsTab = Window:Tab("Graphics", "rbxassetid://10709752131")

GraphicsTab:Section("Optimization & Style")

-- TOGGLE: FPS Boost (Otimizado)
GraphicsTab:Toggle("Smooth Textures (FPS Boost)", false, function(state)
    if state then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("Terrain") then
                originalMaterials[v] = v.Material
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        for part, material in pairs(originalMaterials) do
            if part and part.Parent then part.Material = material end
        end
        table.clear(originalMaterials)
    end
end, {Flag = "FPS_Boost"})

-- TOGGLE: Full Bright (Otimizado com cache de valores originais)
GraphicsTab:Toggle("Full Bright", false, function(state)
    if state then
        connections.fb = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1e5
            Lighting.GlobalShadows = false
        end)
    else
        if connections.fb then connections.fb:Disconnect() end
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = true
    end
end, {Flag = "FullBright"})

GraphicsTab:Section("Extreme Visuals & Immersion")

GraphicsTab:Toggle("Reshade Lighting", false, function(state)
    if state then
        -- 1. Bloom: Aumentado para efeito mais brilhante (Dreamy Look)
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.7    -- Aumentado (era 0.4)
        bloom.Threshold = 0.75   -- Baixado para brilhar mais facilmente
        bloom.Size = 32          -- Brilho mais espalhado e suave
        
        -- 2. Color Correction
        local color = Instance.new("ColorCorrectionEffect", Lighting)
        color.Contrast = 0.28
        color.Saturation = 0.38
        color.Brightness = 0.0
        color.TintColor = Color3.fromRGB(255, 252, 240) 
        
        -- 3. DepthOfField (Base para o Foco Dinâmico)
        local dof = Instance.new("DepthOfFieldEffect", Lighting)
        dof.FarIntensity = 0.85   -- Fundo bem embaçado
        dof.NearIntensity = 0.2   -- Leve desfoque perto
        dof.FocusDistance = 15
        dof.InFocusRadius = 20
        
        shaderEffects = {bloom, color, dof}

        -- Sistema RenderStepped (Foco Dinâmico + Água)
        connections.water = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            if not cam or not dof then return end
            
            -- [MÃO NA MASSA] FOCO DINÂMICO
            -- Atira um raio do centro da tela para saber a distância do objeto à frente
            local rayParam = RaycastParams.new()
            rayParam.FilterDescendantsInstances = {Plr.Character or nil}
            rayParam.FilterType = Enum.RaycastFilterType.Exclude
            
            local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 150, rayParam)
            
            local targetFocus = 150 -- Foco padrão se não houver nada perto
            if ray then
                targetFocus = (cam.CFrame.Position - ray.Position).Magnitude
            end
            
            -- Suaviza a transição do foco para não cansar a vista
            lastFocusDist = lastFocusDist * 0.9 + (targetFocus * 0.1)
            dof.FocusDistance = lastFocusDist

            -- Sistema de Água (Original)
            local cameraPos = cam.CFrame.Position
            local region = Region3.new(cameraPos - Vector3.new(0.5,0.5,0.5), cameraPos + Vector3.new(0.5,0.5,0.5)):ExpandToGrid(4)
            local material = Terrain:ReadVoxels(region, 4)[1][1][1]

            if material == Enum.Material.Water then
                underwaterBlur.Parent = Lighting
                underwaterBlur.Size = 18
                underwaterColor.Parent = Lighting
                underwaterColor.TintColor = Color3.fromRGB(0, 150, 255)
                waterEqualizer.Enabled = true
                waterReverb.Enabled = true
            else
                underwaterBlur.Parent = nil
                underwaterColor.Parent = nil
                waterEqualizer.Enabled = false
                waterReverb.Enabled = false
            end
        end)
    else
        if connections.water then connections.water:Disconnect() end
        for _, effect in ipairs(shaderEffects) do effect:Destroy() end
        table.clear(shaderEffects)
        
        underwaterBlur.Parent = nil
        underwaterColor.Parent = nil
        waterEqualizer.Enabled = false
        waterReverb.Enabled = false
    end
end, {Flag = "ReshadeWater"})

local lastFocusDist = 20

GraphicsTab:Toggle("Reshade Dark", false, function(state)
    if state then
        -- 1. BLOOM PESADO (Brilho intenso em contraste com o escuro)
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 1.0    -- Brilho forte para destacar luzes no breu
        bloom.Threshold = 0.8    -- Apenas fontes de luz realmente fortes brilham
        bloom.Size = 40          -- Glow bem espalhado
        
        -- 2. COLOR CORRECTION (O perfil Dark que você mandou, levemente tunado)
        local color = Instance.new("ColorCorrectionEffect", Lighting)
        color.Contrast = 0.35    -- Sombras bem pesadas e pretas
        color.Saturation = 0.3   -- Cores presentes, mas sem lavar o preto
        color.Brightness = -0.05 -- Mantém o clima dark e fechado
        
        -- 3. DEPTH OF FIELD (Foco Dinâmico Cinematográfico)
        local dof = Instance.new("DepthOfFieldEffect", Lighting)
        dof.FarIntensity = 0.9   -- Fundo totalmente embaçado
        dof.NearIntensity = 0.2
        dof.InFocusRadius = 15   -- Foco bem seletivo
        
        shaderEffects = {bloom, color, dof}

        -- Loop de Processamento: Foco + Água
        connections.water = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            if not cam or not dof then return end
            
            -- FOCO DINÂMICO (Ajusta onde você olha)
            local rayParam = RaycastParams.new()
            rayParam.FilterDescendantsInstances = {Plr.Character or nil}
            rayParam.FilterType = Enum.RaycastFilterType.Exclude
            
            local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 150, rayParam)
            
            local targetFocus = 150
            if ray then
                targetFocus = (cam.CFrame.Position - ray.Position).Magnitude
            end
            
            -- Transição suave de foco
            lastFocusDist = lastFocusDist * 0.8 + (targetFocus * 0.2)
            dof.FocusDistance = lastFocusDist

            -- Sistema Subaquático
            local cameraPos = cam.CFrame.Position
            local region = Region3.new(cameraPos - Vector3.new(0.5,0.5,0.5), cameraPos + Vector3.new(0.5,0.5,0.5)):ExpandToGrid(4)
            local material = Terrain:ReadVoxels(region, 4)[1][1][1]

            if material == Enum.Material.Water then
                underwaterBlur.Parent = Lighting
                underwaterBlur.Size = 20
                underwaterColor.Parent = Lighting
                underwaterColor.TintColor = Color3.fromRGB(0, 100, 200) -- Azul mais escuro/profundo
                waterEqualizer.Enabled = true
                waterReverb.Enabled = true
            else
                underwaterBlur.Parent = nil
                underwaterColor.Parent = nil
                waterEqualizer.Enabled = false
                waterReverb.Enabled = false
            end
        end)
    else
        if connections.water then connections.water:Disconnect() end
        for _, effect in ipairs(shaderEffects) do effect:Destroy() end
        table.clear(shaderEffects)
        
        underwaterBlur.Parent = nil
        underwaterColor.Parent = nil
        waterEqualizer.Enabled = false
        waterReverb.Enabled = false
        if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end -- Reset padrão
    end
end, {Flag = "ReshadeDark"})

local lastFocusDist = 20

-- Criamos as tabelas FORA da função para o script lembrar delas ao desligar
local shaderEffects = {}
local connections = {}

GraphicsTab:Toggle("Reshade Clean", false, function(state)
    if state then
        -- 1. BLOOM
        local bloom = Instance.new("BloomEffect", game.Lighting)
        bloom.Intensity = 0.25
        bloom.Threshold = 0.85
        bloom.Size = 16
        
        -- 2. COLOR CORRECTION
        local color = Instance.new("ColorCorrectionEffect", game.Lighting)
        color.Contrast = 0.2
        color.Saturation = 0.25
        color.TintColor = Color3.fromRGB(255, 254, 250)
        
        -- 3. DEPTH OF FIELD
        local dof = Instance.new("DepthOfFieldEffect", game.Lighting)
        dof.FarIntensity = 0.8
        dof.NearIntensity = 0.5
        dof.InFocusRadius = 15
        
        -- Guardamos os efeitos na tabela global do script
        shaderEffects = {bloom, color, dof}

        connections.water = game:GetService("RunService").RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local char = Player.Character
            if not cam or not dof or not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local distToChar = (cam.CFrame.Position - root.Position).Magnitude
            
            -- Lógica de Foco (Zoom)
            if distToChar < 10 then
                dof.NearIntensity = 0
                dof.FarIntensity = 0.7
                dof.InFocusRadius = 25
            else
                dof.NearIntensity = 0.4
                dof.FarIntensity = 0.5
                dof.InFocusRadius = 15
            end

            -- Raycast para Foco Dinâmico
            local rayParam = RaycastParams.new()
            rayParam.FilterDescendantsInstances = {char}
            rayParam.FilterType = Enum.RaycastFilterType.Exclude
            
            local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 150, rayParam)
            local targetFocus = (ray and (cam.CFrame.Position - ray.Position).Magnitude) or 150
            
            if distToChar < 10 then targetFocus = distToChar end
            
            dof.FocusDistance = (dof.FocusDistance or 10) * 0.9 + (targetFocus * 0.1)
        end)
    else
        -- =========================
        -- LOGICA DE DESATIVAR (FIXED)
        -- =========================
        
        -- 1. Desconecta o loop (Para de processar o foco)
        if connections.water then 
            connections.water:Disconnect() 
            connections.water = nil 
        end
        
        -- 2. Destrói todos os efeitos criados no Lighting
        for _, effect in ipairs(shaderEffects) do 
            if effect then effect:Destroy() end 
        end
        
        -- 3. Limpa a tabela
        table.clear(shaderEffects)
    end
end, {Flag = "ReshadeClean"})

GraphicsTab:Toggle("Reshade Graphics", false, function(state)
    if state then
        -- Efeitos Visuais (Mantidos conforme pedido)
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.3 bloom.Threshold = 0.9
        
        local color = Instance.new("ColorCorrectionEffect", Lighting)
        color.Contrast = 0.3 color.Saturation = 0.25 color.Brightness = -0.03
        
        local dof = Instance.new("DepthOfFieldEffect", Lighting)
        dof.FarIntensity = 0.85 dof.FocusDistance = 15
        
        shaderEffects = {bloom, color, dof}

        -- Sistema de Detecção Subaquática
        connections.water = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            
            -- Método mais leve para checar material
            local cameraPos = cam.CFrame.Position
            local region = Region3.new(cameraPos - Vector3.new(0.5,0.5,0.5), cameraPos + Vector3.new(0.5,0.5,0.5)):ExpandToGrid(4)
            local material = Terrain:ReadVoxels(region, 4)[1][1][1]

            if material == Enum.Material.Water then
                underwaterBlur.Parent = Lighting
                underwaterBlur.Size = 18
                
                underwaterColor.Parent = Lighting
                underwaterColor.TintColor = Color3.fromRGB(0, 150, 255)
                
                -- Ativação do Áudio Melhorado
                waterEqualizer.Enabled = true
                waterReverb.Enabled = true
            else
                underwaterBlur.Parent = nil
                underwaterColor.Parent = nil
                waterEqualizer.Enabled = false
                waterReverb.Enabled = false
            end
        end)
    else
        if connections.water then connections.water:Disconnect() end
        for _, effect in ipairs(shaderEffects) do effect:Destroy() end
        table.clear(shaderEffects)
        
        underwaterBlur.Parent = nil
        underwaterColor.Parent = nil
        waterEqualizer.Enabled = false
        waterReverb.Enabled = false
    end
end, {Flag = "ReshadeWater"})

local lastFocusDist = 20

GraphicsTab:Toggle("Ultra Cinematic V3", false, function(state)
    if state then
        -- 1. BLOOM: Seletivo e elegante
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.45 
        bloom.Threshold = 0.85
        bloom.Size = 20
        
        -- 2. COLOR CORRECTION: Sombras profundas (Dark)
        local color = Instance.new("ColorCorrectionEffect", Lighting)
        color.Contrast = 0.45    -- Sombras bem marcadas
        color.Saturation = 0.38 
        color.Brightness = -0.06 -- Escuro cinematográfico
        color.TintColor = Color3.fromRGB(255, 252, 245)
        
        -- 3. DEPTH OF FIELD: Fundo embaçado, personagem nítido
        local dof = Instance.new("DepthOfFieldEffect", Lighting)
        dof.FarIntensity = 0.85   -- Aumentado: Fundo bem borrado
        dof.NearIntensity = 0     -- ZERADO: Tira o desfoque de perto (personagem sempre limpo)
        dof.FocusDistance = 25    
        dof.InFocusRadius = 60    -- Aumentado: Garante nitidez em toda a área ao seu redor
        
        shaderEffects = {bloom, color, dof}

        connections.render = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            if not cam or not dof then return end
            
            -- FOCO DINÂMICO
            local rayParam = RaycastParams.new()
            rayParam.FilterDescendantsInstances = {Plr.Character or nil}
            rayParam.FilterType = Enum.RaycastFilterType.Exclude
            
            local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 150, rayParam)
            
            local targetFocus = 150
            if ray then
                targetFocus = (cam.CFrame.Position - ray.Position).Magnitude
            end
            
            -- Suavização
            lastFocusDist = lastFocusDist * 0.9 + (targetFocus * 0.1)
            dof.FocusDistance = lastFocusDist

            -- Água
            local cameraPos = cam.CFrame.Position
            local region = Region3.new(cameraPos - Vector3.new(0.5,0.5,0.5), cameraPos + Vector3.new(0.5,0.5,0.5)):ExpandToGrid(4)
            local material = Terrain:ReadVoxels(region, 4)[1][1][1]

            if material == Enum.Material.Water then
                underwaterBlur.Parent = Lighting
                underwaterBlur.Size = 12
                underwaterColor.Parent = Lighting
                underwaterColor.TintColor = Color3.fromRGB(0, 40, 120)
            else
                underwaterBlur.Parent = nil
                underwaterColor.Parent = nil
            end
        end)
    else
        if connections.render then connections.render:Disconnect() end
        for _, effect in ipairs(shaderEffects) do effect:Destroy() end
        table.clear(shaderEffects)
        underwaterBlur.Parent = nil
        underwaterColor.Parent = nil
    end
end, {Flag = "ReshadeUltraV3"})

-- TOGGLE: Ultra Water
GraphicsTab:Toggle("Ultra Realistic Water", false, function(state)
    Terrain.WaterWaveSize = state and 0.35 or 0.05
    Terrain.WaterWaveSpeed = state and 15 or 8
    Terrain.WaterReflectance = state and 1 or 0.1
    Terrain.WaterTransparency = state and 0.45 or 1
    Terrain.WaterColor = state and Color3.fromRGB(0, 115, 150) or Color3.fromRGB(0, 255, 255)
end, {Flag = "UltraWater"})

GraphicsTab:Section("Environment")

GraphicsTab:Slider("Field of View", 70, 120, 70, function(value)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = value end
end, {Flag = "Graphics_FOV"})

GraphicsTab:Button("Clear Map Effects (Lag Reduce)", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if (v:IsA("PostProcessEffect") and not v:IsAncestorOf(Lighting)) or 
           v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
            v:Destroy()
        end
    end
end)
Library:CreateSettings(Window)

--[[

_G.SystemCore = {}
_G.SystemCore.Cache = {}
_G.SystemCore.Threads = {}
_G.SystemCore.Internal = {}

function _G.SystemCore:Init()
    local seed = math.random(100000,999999)
    self.Cache["seed"] = seed
    return seed
end

function _G.SystemCore:Encrypt(v)
    local r = ""
    for i = 1, #tostring(v) do
        r = r .. string.char(math.random(33,126))
    end
    return r
end

function _G.SystemCore:Decrypt(v)
    return tostring(v):reverse()
end

function _G.SystemCore:Sync()
    for i = 1, 50 do
        self.Cache[i] = math.random()
    end
end

function _G.SystemCore.Internal:Ping()
    local x = 0
    for i = 1, 1000 do
        x = x + math.sin(i)
    end
    return x
end

function _G.SystemCore.Internal:Heartbeat()
    local t = tick()
    repeat
        t = t + math.random()
    until t > tick() + 0.01
end

_G.Loader = {}
_G.Loader.Version = "v"..math.random(100,999)
_G.Loader.Status = false

function _G.Loader:Load()
    self.Status = not self.Status
    return self.Status
end

function _G.Loader:Validate(k)
    if not k then
        return false
    end
    local s = 0
    for i = 1, #k do
        s = s + string.byte(k,i)
    end
    return s % 2 == 0
end

_G.AntiDump = {}

function _G.AntiDump:Check()
    local env = getfenv and getfenv(0) or {}
    for i,v in pairs(env) do
        if tostring(i):lower():find("dump") then
            return false
        end
    end
    return true
end

function _G.AntiDump:Loop()
    for i = 1, math.random(10,40) do
        coroutine.wrap(function()
            local a = 0
            for j = 1, 500 do
                a = a + math.random()
            end
        end)()
    end
end

_G.Memory = {}

for i = 1, 200 do
    _G.Memory[i] = {
        key = tostring(math.random())..tostring(os.clock()),
        value = math.random(1,999999)
    }
end

function _G.Memory:Flush()
    for i in pairs(self) do
        self[i] = nil
    end
end

function _G.Memory:Randomize()
    local t = {}
    for i = 1, 100 do
        t[i] = math.random()
    end
    return t
end

function FakeFunction_A()
    local x = 0
    for i = 1, 10000 do
        x = x + i
    end
    return x
end

function FakeFunction_B()
    local str = ""
    for i = 1, 200 do
        str = str .. string.char(math.random(65,90))
    end
    return str
end

function FakeFunction_C()
    return FakeFunction_A() .. tostring(FakeFunction_B())
end

for i = 1, 100 do
    _G["FUNC_"..i] = function()
        return math.random() * os.clock()
    end
end

-- fake anti reverse
local function __internal_runtime_validator__()
    local t = {}
    for i = 1, 300 do
        t[i] = math.random()
    end
    return t[math.random(1,#t)]
end

__internal_runtime_validator__()

]]


