local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local UIOn = true
local Mouse = LocalPlayer:GetMouse()

local ToggleKey = Enum.KeyCode.RightControl -- Tecla para abrir/fechar o menu

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == ToggleKey then
        UIOn = not UIOn
        Library.ScreenGui.Enabled = UIOn
    end
end)

local HttpService = game:GetService("HttpService")
local ConfigFile = "DobeVoxify_Config.json"
local _Config = { Toggles = {}, Binds = {}, Colors = {} }

-- Função para Salvar no Arquivo
local function SaveSettings()
    if writefile then
        -- Criamos uma tabela temporária para garantir que o JSON tenha os nomes certos
        local dataToSave = {
            Toggles = _Config.Toggles,
            Binds = _Config.Binds, -- Use sempre o mesmo nome aqui
            Colors = _Config.Colors,
            ThemeData = _Config.ThemeData
        }
        writefile(ConfigFile, HttpService:JSONEncode(dataToSave))
    end
end

-- Função para Carregar do Arquivo
local function LoadSettings()
    if isfile and isfile(ConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and type(data) == "table" then
            -- Em vez de _Config = data, vamos preencher os valores
            for category, values in pairs(data) do
                if type(values) == "table" then
                    _Config[category] = _Config[category] or {}
                    for k, v in pairs(values) do
                        _Config[category][k] = v
                    end
                end
            end
            
            -- Sincroniza com as Flags da Library (se já existirem)
            if Library and Library.Flags then
                Library.Flags.Toggles = _Config.Toggles or {}
                Library.Flags.Binds = _Config.Binds or _Config.Keybinds or {} -- Ajuste para aceitar "Keybinds" do seu JSON
                Library.Flags.Colors = _Config.Colors or {}
            end
        end
    end
end
LoadSettings() -- Carrega ao iniciar

--// DETECÇÃO DE EXECUTOR E PROTEÇÃO
local function GetGuiParent()
    if RunService:IsStudio() then
        return LocalPlayer:WaitForChild("PlayerGui")
    else
        -- Tenta colocar no CoreGui para proteção, senão PlayerGui
        local success, result = pcall(function() return CoreGui end)
        if success then return result else return LocalPlayer:WaitForChild("PlayerGui") end
    end
end

--// LIMPEZA ANTIGA
for _, v in pairs(GetGuiParent():GetChildren()) do
    if v.Name == "DobeiOS_Remaster" then v:Destroy() end
end

--// TEMA (iOS Dark Refined)
local Theme = {
    Background = Color3.fromRGB(25, 25, 28), -- Um pouco mais escuro
    Sidebar    = Color3.fromRGB(32, 32, 35),
    ItemBG     = Color3.fromRGB(42, 42, 45),
    ItemStroke = Color3.fromRGB(70, 70, 75),
    Text       = Color3.fromRGB(255, 255, 255),
    SubText    = Color3.fromRGB(150, 150, 155),
    Accent     = Color3.fromRGB(10, 132, 255), -- Azul iOS
    Green      = Color3.fromRGB(50, 215, 75),
    Red        = Color3.fromRGB(255, 69, 58)
}

local Library = {}
Library.ScreenGui = nil
Library.CurrentColorCallback = nil -- Controle interno

Library.Elements = {} -- Armazenará as funções de atualização de cada toggle/bind

Library.Flags = {
    Toggles = {},
    Binds = {},
    Colors = {}
}

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

--// FUNÇÃO TWEEN AUXILIAR
function Library:Tween(obj, props, time)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

--// DRAG FUNCTION (Arrastar Janelas)
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Library:Tween(frame, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.05)
        end
    end)
end

--// COLOR PICKER SYSTEM (ZIndex Alto e Isolado)
function Library:OpenColorPicker(defaultColor, callback)
    if Library.ScreenGui:FindFirstChild("ColorPickerOverlay") then
        Library.ScreenGui.ColorPickerOverlay:Destroy()
    end

    local h, s, v = Color3.toHSV(defaultColor)
    
    local Overlay = Instance.new("Frame")
    Overlay.Name = "ColorPickerOverlay"
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.new(0,0,0)
    Overlay.BackgroundTransparency = 1 -- Fade in depois
    Overlay.ZIndex = 5000 -- ZIndex MUITO alto
    Overlay.Parent = Library.ScreenGui

    local Main = Instance.new("Frame", Overlay)
    Main.Size = UDim2.fromOffset(240, 270)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.fromScale(0.5, 0.55) -- Começa levemente abaixo
    Main.BackgroundColor3 = Theme.Background
    Main.ZIndex = 5001


    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Main).Color = Theme.ItemStroke

    local Label = Instance.new("TextLabel", Main)
    Label.Text = "Escolher Cor"
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.ZIndex = 5002

    -- Área Sat/Val
    local SVFrame = Instance.new("ImageButton", Main)
    SVFrame.Name = "SVFrame"
    SVFrame.Size = UDim2.new(1, -20, 0, 140)
    SVFrame.Position = UDim2.new(0, 10, 0, 35)
    SVFrame.Image = "rbxassetid://4155801252" -- Overlay Sat/Val
    SVFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    SVFrame.ZIndex = 5002
    Instance.new("UICorner", SVFrame).CornerRadius = UDim.new(0, 6)

    local PickerCursor = Instance.new("Frame", SVFrame)
    PickerCursor.Size = UDim2.fromOffset(10, 10)
    PickerCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    PickerCursor.Position = UDim2.fromScale(s, 1-v)
    PickerCursor.BackgroundColor3 = Color3.new(1,1,1)
    PickerCursor.ZIndex = 5003
    Instance.new("UICorner", PickerCursor).CornerRadius = UDim.new(1, 0)
    
    -- Barra Hue
    local HueFrame = Instance.new("ImageButton", Main)
    HueFrame.Name = "HueFrame"
    HueFrame.Size = UDim2.new(1, -20, 0, 20)
    HueFrame.Position = UDim2.new(0, 10, 0, 185)
    HueFrame.Image = "rbxassetid://3641079629" -- Rainbow
    HueFrame.ZIndex = 5002
    Instance.new("UICorner", HueFrame).CornerRadius = UDim.new(0, 4)

    local HueCursor = Instance.new("Frame", HueFrame)
    HueCursor.Size = UDim2.new(0, 3, 1, 0)
    HueCursor.Position = UDim2.fromScale(h, 0)
    HueCursor.BackgroundColor3 = Color3.new(1,1,1)
    HueCursor.ZIndex = 5003
    HueCursor.BorderSizePixel = 0

    local ConfirmBtn = Instance.new("TextButton", Main)
    ConfirmBtn.Text = "Confirmar"
    ConfirmBtn.Size = UDim2.new(0, 100, 0, 30)
    ConfirmBtn.AnchorPoint = Vector2.new(0.5, 0)
    ConfirmBtn.Position = UDim2.new(0.5, 0, 1, -40)
    ConfirmBtn.BackgroundColor3 = Theme.ItemBG
    ConfirmBtn.TextColor3 = Theme.Accent
    ConfirmBtn.Font = Enum.Font.GothamBold
    ConfirmBtn.ZIndex = 5002
    Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", ConfirmBtn).Color = Theme.ItemStroke

    -- Lógica
    local draggingHue, draggingSV = false, false

    local function UpdateColor()
        local newColor = Color3.fromHSV(h, s, v)
        SVFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        callback(newColor)
    end

    SVFrame.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end 
    end)
    HueFrame.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end 
    end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false; draggingSV = false end 
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingHue then
                h = math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
                HueCursor.Position = UDim2.fromScale(h, 0)
                UpdateColor()
            elseif draggingSV then
                s = math.clamp((input.Position.X - SVFrame.AbsolutePosition.X) / SVFrame.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - SVFrame.AbsolutePosition.Y) / SVFrame.AbsoluteSize.Y, 0, 1)
                PickerCursor.Position = UDim2.fromScale(s, 1-v)
                UpdateColor()
            end
        end
    end)

    -- Animação Entrada
    Library:Tween(Overlay, {BackgroundTransparency = 0.6})
    Library:Tween(Main, {Position = UDim2.fromScale(0.5, 0.5)})

    ConfirmBtn.MouseButton1Click:Connect(function()
        Library:Tween(Overlay, {BackgroundTransparency = 1}, 0.2)
        Library:Tween(Main, {Position = UDim2.fromScale(0.5, 0.6)}, 0.2)
        task.wait(0.2)
        Overlay:Destroy()
    end)
end

function Library:Prompt(config)
    -- config = {Title = "", Text = "", Buttons = {{Text="Sim", Callback=...}, {Text="Não", Callback=...}}}
    if not Library.ScreenGui then return end
    
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.new(0,0,0)
    Overlay.BackgroundTransparency = 1
    Overlay.ZIndex = 1900
    Overlay.Parent = Library.ScreenGui

    local PromptFrame = Instance.new("Frame")
    PromptFrame.Size = UDim2.fromOffset(300, 0) -- Altura auto
    PromptFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    PromptFrame.Position = UDim2.fromScale(0.5, 0.55) -- Começa um pouco baixo
    PromptFrame.BackgroundColor3 = Theme.Background
    PromptFrame.BorderSizePixel = 0
    PromptFrame.BackgroundTransparency = 1
    PromptFrame.ZIndex = 2000
    PromptFrame.Parent = Overlay

    local Corner = Instance.new("UICorner", PromptFrame)
    Corner.CornerRadius = UDim.new(0, 14)
    local Stroke = Instance.new("UIStroke", PromptFrame)
    Stroke.Color = Theme.ItemStroke
    Stroke.Thickness = 1
    Stroke.Transparency = 1

    local Title = Instance.new("TextLabel", PromptFrame)
    Title.Text = config.Title or "Aviso"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Theme.Text
    Title.BackgroundTransparency = 1
    Title.ZIndex = 2000
    Title.TextTransparency = 1
    
    local Desc = Instance.new("TextLabel", PromptFrame)
    Desc.Text = config.Text or "Texto do prompt aqui."
    Desc.Size = UDim2.new(1, -20, 0, 0)
    Desc.Position = UDim2.new(0, 10, 0, 40)
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 14
    Desc.TextColor3 = Theme.SubText
    Desc.BackgroundTransparency = 1
    Desc.ZIndex = 2000
    Desc.TextWrapped = true
    Desc.AutomaticSize = Enum.AutomaticSize.Y
    Desc.TextTransparency = 1
    Desc.Parent = PromptFrame

    local ButtonContainer = Instance.new("Frame", PromptFrame)
    ButtonContainer.Size = UDim2.new(1, -20, 0, 40)
    ButtonContainer.Position = UDim2.new(0, 10, 0, 0) -- Ajustado dinamicamente
    ButtonContainer.ZIndex = 2000
    ButtonContainer.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout", ButtonContainer)
    UIList.FillDirection = Enum.FillDirection.Horizontal
    UIList.Padding = UDim.new(0, 10)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local buttons = config.Buttons or {{Text = "OK", Callback = function() end}}
    local btnCount = #buttons
    local btnWidth = (280 - (10 * (btnCount - 1))) / btnCount

    for _, btnData in pairs(buttons) do
        local Btn = Instance.new("TextButton", ButtonContainer)
        Btn.Size = UDim2.new(0, btnWidth, 1, 0)
        Btn.BackgroundColor3 = Theme.ItemBG
        Btn.Text = btnData.Text
        Btn.TextColor3 = Theme.Accent
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 14
        Btn.AutoButtonColor = false
        Btn.ZIndex = 2000
        Btn.BackgroundTransparency = 1
        Btn.TextTransparency = 1
        
        local BCorner = Instance.new("UICorner", Btn)
        BCorner.CornerRadius = UDim.new(0, 8)
        
        Btn.MouseButton1Click:Connect(function()
            -- Fechar animado
            Library:Tween(PromptFrame, {Position = UDim2.fromScale(0.5, 0.55), BackgroundTransparency = 1}, 0.2)
            Library:Tween(Stroke, {Transparency = 1}, 0.2)
            Library:Tween(Overlay, {BackgroundTransparency = 1}, 0.2)
            wait(0.2)
            Overlay:Destroy()
            if btnData.Callback then btnData.Callback() end
        end)
    end

    -- Ajustar tamanho final
    local textHeight = Desc.AbsoluteSize.Y
    local totalHeight = 40 + textHeight + 20 + 40 + 10
    PromptFrame.Size = UDim2.fromOffset(300, totalHeight)
    ButtonContainer.Position = UDim2.new(0, 10, 1, -50)

    -- Animação de Entrada
    Library:Tween(Overlay, {BackgroundTransparency = 0.4}, 0.3)
    Library:Tween(PromptFrame, {Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0}, 0.3)
    Library:Tween(Stroke, {Transparency = 0}, 0.3)
    for _, v in pairs(PromptFrame:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            Library:Tween(v, {TextTransparency = 0}, 0.3)
        end
        if v:IsA("TextButton") then
            Library:Tween(v, {BackgroundTransparency = 0}, 0.3)
        end
    end
end

function Library:CreateMiniPanel(config)
    -- config = {Name = "Tags", Size = UDim2.fromOffset(200, 300)}
    local Panel = {}
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MiniPanel_" .. (config.Name or "Ui")
    MainFrame.Size = config.Size or UDim2.fromOffset(200, 250)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.ZIndex = 2100
    MainFrame.Parent = Library.ScreenGui
    MainFrame.Visible = false -- Começa fechado, abre via código
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", MainFrame).Color = Theme.ItemStroke
    
    -- Drag
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = config.Name or "Painel"
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Theme.Text
    Title.ZIndex = 2100
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.SubText
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.ZIndex = 2100
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

    local Scroll = Instance.new("ScrollingFrame", MainFrame)
    Scroll.Size = UDim2.new(1, -10, 1, -35)
    Scroll.Position = UDim2.new(0, 5, 0, 30)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 2
    Scroll.ZIndex = 2100
    Scroll.ScrollBarImageColor3 = Theme.Accent
    
    local List = Instance.new("UIListLayout", Scroll)
    List.Padding = UDim.new(0, 5)
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
    end)

    function Panel:AddButton(text, cb, customColor)
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    
    -- Se customColor for passado, usa ele. Se não, usa o Theme.ItemBG
    Btn.BackgroundColor3 = customColor or Theme.ItemBG
    
    Btn.Text = text
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.ZIndex = 2100
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    -- Retornamos o objeto Btn caso você queira mudar a cor depois dinamicamente
    Btn.MouseButton1Click:Connect(cb)
    
    return Btn
end
    
    function Panel:Toggle()
        MainFrame.Visible = not MainFrame.Visible
    end

    return Panel
end

--// CONSTRUÇÃO DA JANELA PRINCIPAL
function Library:Window(config)
    local WindowTable = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DobeiOS_Remaster"
    ScreenGui.IgnoreGuiInset = true -- IMPORTANTE: Ignora a barra superior
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = GetGuiParent()
    Library.ScreenGui = ScreenGui

    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(600, 350)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Background
    Main.ZIndex = 1
    Main.ClipsDescendants = false -- Permite sombras vazarem
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Main).Color = Theme.ItemStroke

    MakeDraggable(Main)

    -- Sombra
    if config.Shadow then
        local Shadow = Instance.new("ImageLabel", Main)
        Shadow.ZIndex = 0
        Shadow.Position = UDim2.new(0, -15, 0, -15)
        Shadow.Size = UDim2.new(1, 30, 1, 30)
        Shadow.BackgroundTransparency = 1
        Shadow.Image = "rbxassetid://6014261993"
        Shadow.ImageColor3 = Color3.new(0,0,0)
        Shadow.ImageTransparency = 0.4
        Shadow.ScaleType = Enum.ScaleType.Slice
        Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    end


    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.ZIndex = 2
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    local SidebarCover = Instance.new("Frame", Sidebar) -- Cobre o canto direito pra ficar quadrado
    SidebarCover.Size = UDim2.new(0, 10, 1, 0)
    SidebarCover.Position = UDim2.new(1, -10, 0, 0)
    SidebarCover.BackgroundColor3 = Theme.Sidebar
    SidebarCover.BorderSizePixel = 0
    SidebarCover.ZIndex = 2

    local Title = Instance.new("TextLabel", Sidebar)
    Title.Text = config.Title or "SCRIPT"
    Title.Font = Enum.Font.GothamBlack
    Title.TextColor3 = Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamMedium
    Title.Size = UDim2.new(1, -20, 0, 50)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 3

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.ZIndex = 3
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Area de Páginas
    local PageContainer = Instance.new("Frame", Main)
    PageContainer.Size = UDim2.new(1, -160, 1, 0)
    PageContainer.Position = UDim2.new(0, 160, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ClipsDescendants = true
    PageContainer.ZIndex = 2

    local PagesFolder = Instance.new("Folder", PageContainer)

    --// FUNÇÃO EXTRAS (Botões dentro de botões)
--// FUNÇÃO EXTRAS (Botões dentro de botões)
-- Serviços Necessários
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Implementação do Color Picker estilo Modern Dark
function Library:OpenColorPicker(defaultColor, callback)
    local h, s, v = Color3.toHSV(defaultColor)
    local selectedColor = defaultColor
    
    -- Gui Principal (Garante que não duplique)
    if self.PickerGui then self.PickerGui:Destroy() end
    
    local PickerGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    PickerGui.Name = "DobeColorPicker"
    PickerGui.DisplayOrder = 1000 -- Superior ao DisplayOrder 999 da Main UI
    self.PickerGui = PickerGui
    
    -- Efeito de Blur no Fundo para foco
    local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    Blur.Size = 0
    Library:Tween(Blur, {Size = 15}, 0.3)

    local MainFrame = Instance.new("Frame", PickerGui)
    MainFrame.Size = UDim2.fromOffset(450, 320)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 100 -- ZIndex Alto para garantir visibilidade
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    -- Sombra (Shadow)
    local Shadow = Instance.new("ImageLabel", MainFrame)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.fromOffset(-20, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = 99

    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Theme.ItemStroke
    Stroke.Thickness = 1

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "Seletor de Cores"
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.fromOffset(20, 10)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 101

    -- Saturação e Brilho (O quadrado grande)
    local SatValBox = Instance.new("ImageLabel", MainFrame)
    SatValBox.Size = UDim2.fromOffset(200, 180)
    SatValBox.Position = UDim2.fromOffset(20, 60)
    SatValBox.Image = "rbxassetid://4155801252"
    SatValBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    SatValBox.ZIndex = 101
    Instance.new("UICorner", SatValBox).CornerRadius = UDim.new(0, 8)

    local Cursor = Instance.new("Frame", SatValBox)
    Cursor.Size = UDim2.fromOffset(12, 12)
    Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
    Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
    Cursor.Position = UDim2.fromScale(s, 1-v)
    Cursor.ZIndex = 102
    Instance.new("UICorner", Cursor).CornerRadius = UDim.new(1, 0)
    local CStroke = Instance.new("UIStroke", Cursor)
    CStroke.Thickness = 2
    CStroke.Color = Color3.new(0,0,0)

    -- Barra de Hue (Rainbow)
    local HueSlider = Instance.new("ImageLabel", MainFrame)
    HueSlider.Size = UDim2.fromOffset(18, 180)
    HueSlider.Position = UDim2.fromOffset(235, 60)
    HueSlider.Image = "rbxassetid://3641079629"
    HueSlider.ZIndex = 101
    Instance.new("UICorner", HueSlider).CornerRadius = UDim.new(1, 0)

    local HueCursor = Instance.new("Frame", HueSlider)
    HueCursor.Size = UDim2.new(1, 4, 0, 4)
    HueCursor.Position = UDim2.fromScale(0.5, h)
    HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    HueCursor.ZIndex = 102
    Instance.new("UIStroke", HueCursor).Thickness = 1

    -- Inputs (Estilizados)
    local function CreateInput(name, pos, defaultText)
        local Container = Instance.new("Frame", MainFrame)
        Container.Size = UDim2.fromOffset(140, 35)
        Container.Position = pos
        Container.BackgroundColor3 = Theme.Sidebar
        Container.ZIndex = 101
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", Container)
        Label.Text = name
        Label.Position = UDim2.new(0, 8, 0, 0)
        Label.Size = UDim2.new(0, 30, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Theme.SubText
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 12
        Label.ZIndex = 102

        local Box = Instance.new("TextBox", Container)
        Box.Size = UDim2.new(1, -45, 1, 0)
        Box.Position = UDim2.fromOffset(40, 0)
        Box.BackgroundTransparency = 1
        Box.Text = defaultText
        Box.TextColor3 = Theme.Text
        Box.Font = Enum.Font.GothamMedium
        Box.TextSize = 13
        Box.ZIndex = 102
        return Box
    end

    local HexBox = CreateInput("HEX", UDim2.fromOffset(270, 60), "#FFFFFF")
    local RBox = CreateInput("R", UDim2.fromOffset(270, 105), "255")
    local GBox = CreateInput("G", UDim2.fromOffset(270, 150), "255")
    local BBox = CreateInput("B", UDim2.fromOffset(270, 195), "255")

    -- Previsão de Cor
    local Preview = Instance.new("Frame", MainFrame)
    Preview.Size = UDim2.fromOffset(140, 30)
    Preview.Position = UDim2.fromOffset(270, 240)
    Preview.BackgroundColor3 = selectedColor
    Preview.ZIndex = 101
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 6)

    -- Botões de Ação Animados
    local function CreateActionBtn(text, pos, color)
        local Btn = Instance.new("TextButton", MainFrame)
        Btn.Size = UDim2.fromOffset(200, 40)
        Btn.Position = pos
        Btn.BackgroundColor3 = Theme.ItemBG
        Btn.Text = text
        Btn.TextColor3 = Theme.Text
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 14
        Btn.ZIndex = 101
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        
        local BStroke = Instance.new("UIStroke", Btn)
        BStroke.Color = Theme.ItemStroke

        Btn.MouseEnter:Connect(function() Library:Tween(BStroke, {Color = color}) end)
        Btn.MouseLeave:Connect(function() Library:Tween(BStroke, {Color = Theme.ItemStroke}) end)
        return Btn
    end

    local DoneBtn = CreateActionBtn("APLICAR", UDim2.fromOffset(20, 260), Theme.Green)
    local CancelBtn = CreateActionBtn("CANCELAR", UDim2.fromOffset(230, 260), Theme.Red)
    CancelBtn.Position = UDim2.new(0, 230, 0, 260) -- Ajuste fino

    local function Update()
        selectedColor = Color3.fromHSV(h, s, v)
        SatValBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        Preview.BackgroundColor3 = selectedColor
        HexBox.Text = "#" .. selectedColor:ToHex():upper()
        RBox.Text = math.floor(selectedColor.R * 255)
        GBox.Text = math.floor(selectedColor.G * 255)
        BBox.Text = math.floor(selectedColor.B * 255)
    end

    -- Lógica de Arrastar (Mantida do seu código com correções de Offset)
    local dragSatVal = false
    local dragHue = false

    SatValBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragSatVal = true end
    end)
    HueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragSatVal = false; dragHue = false end
    end)

    RunService.RenderStepped:Connect(function()
        if dragSatVal then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos - SatValBox.AbsolutePosition - Vector2.new(0, 36)
            s = math.clamp(relativePos.X / SatValBox.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp(relativePos.Y / SatValBox.AbsoluteSize.Y, 0, 1)
            Cursor.Position = UDim2.fromScale(s, 1-v)
            Update()
        elseif dragHue then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos - HueSlider.AbsolutePosition - Vector2.new(0, 36)
            h = math.clamp(relativePos.Y / HueSlider.AbsoluteSize.Y, 0, 1)
            HueCursor.Position = UDim2.fromScale(0.5, h)
            Update()
        end
    end)

    local function Close()
        Library:Tween(Blur, {Size = 0}, 0.2)
        Library:Tween(MainFrame, {Position = UDim2.fromScale(0.5, 0.6), BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        PickerGui:Destroy()
        Blur:Destroy()
    end

    DoneBtn.MouseButton1Click:Connect(function()
        if callback then callback(selectedColor) end
        Close()
    end)
    CancelBtn.MouseButton1Click:Connect(Close)

    Update()
end

-- ==========================================================
-- SEU CÓDIGO ORIGINAL (AddExtras) - NÃO ALTERADO
-- ==========================================================
local function AddExtras(parent, options, callback)
    if not options then return end
    
    local flag = "Unknown"
    if options and options.Flag then 
        flag = options.Flag 
    elseif parent:FindFirstChild("TextLabel") then
        flag = parent.TextLabel.Text
    elseif parent:IsA("TextButton") and parent.Text ~= "" then
        flag = parent.Text
    end
    
    if not Library.Flags then Library.Flags = {Toggles = {}, Binds = {}, Colors = {}} end
    if not Library.Elements then Library.Elements = {} end
    if not Library.Elements[flag] then Library.Elements[flag] = {} end

    -- 1. KEYBIND
    local KeyBtn 
    if options.Keybind ~= nil then
        local binding = false
        local blockKeyUntilRelease = nil

        -- [CORREÇÃO CARREGAMENTO BIND]
        local savedBind = Library.Flags.Binds[flag]
        if savedBind then
            local success, keyCode = pcall(function() return Enum.KeyCode[savedBind] end)
            if success then
                if type(options.Keybind) == "table" then options.Keybind.Value = keyCode else options.Keybind = keyCode end
            end
        end

        KeyBtn = Instance.new("TextButton", parent)
        KeyBtn.AutomaticSize = Enum.AutomaticSize.XY
        KeyBtn.Size = UDim2.fromOffset(0, 20)
        KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
        KeyBtn.Position = UDim2.new(1, -10, 0.5, 0)
        KeyBtn.ZIndex = parent.ZIndex + 1 
        KeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        KeyBtn.BackgroundTransparency = 1
        KeyBtn.BorderSizePixel = 0
        
        local Corner = Instance.new("UICorner", KeyBtn)
        Corner.CornerRadius = UDim.new(0, 4)
        
        local Padding = Instance.new("UIPadding", KeyBtn)
        Padding.PaddingLeft = UDim.new(0, 6)
        Padding.PaddingRight = UDim.new(0, 6)

        local function getBindName(override)
            local key = override or (type(options.Keybind) == "table" and options.Keybind.Value or options.Keybind)
            if key == Enum.KeyCode.Unknown or key == nil then return "..." end
            return key.Name
        end

        KeyBtn.Text = getBindName()
        KeyBtn.TextColor3 = Theme.SubText
        KeyBtn.Font = Enum.Font.GothamBold
        KeyBtn.TextSize = 12

        local function animateBox(show)
            TweenService:Create(
                KeyBtn,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = show and 0 or 1 }
            ):Play()
        end

        local function resetVisual()
            binding = false
            KeyBtn.Text = getBindName()
            KeyBtn.TextColor3 = Theme.SubText
            animateBox(false)
        end

        KeyBtn.MouseButton1Click:Connect(function()
            if binding then return end
            
            binding = true
            KeyBtn.Text = "..."
            KeyBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
            animateBox(true)
            
            local conInput
            task.wait()
            
            conInput = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local selectedKey = input.KeyCode
                    
                    if selectedKey == Enum.KeyCode.Escape then
                        selectedKey = Enum.KeyCode.Unknown
                    end
                    
                    if type(options.Keybind) == "table" then 
                        options.Keybind.Value = selectedKey 
                    else 
                        options.Keybind = selectedKey 
                    end
                    
                    -- [CORREÇÃO SALVAMENTO BIND]
                    Library.Flags.Binds[flag] = selectedKey.Name
                    blockKeyUntilRelease = selectedKey

                    if Library.UpdateKeybindRender then
                        Library:UpdateKeybindRender()
                    end
                    conInput:Disconnect()
                    resetVisual()
                    if SaveSettings then SaveSettings() end -- Salva ao definir

                elseif input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    
                    local unk = Enum.KeyCode.Unknown
                    if type(options.Keybind) == "table" then
                        options.Keybind.Value = unk
                    else
                        options.Keybind = unk
                    end
                    
                    Library.Flags.Binds[flag] = unk.Name
                    blockKeyUntilRelease = unk

                    conInput:Disconnect()
                    resetVisual()
                    if SaveSettings then SaveSettings() end
                end
            end)
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp or binding then return end

            local checkKey = (type(options.Keybind) == "table" and options.Keybind.Value) or options.Keybind
            if checkKey == Enum.KeyCode.Unknown or checkKey == nil then return end
            if input.KeyCode ~= checkKey then return end

            if blockKeyUntilRelease == checkKey then
                return
            end

            if callback then
                callback("Trigger")
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if blockKeyUntilRelease and input.KeyCode == blockKeyUntilRelease then
                blockKeyUntilRelease = nil
            end
        end)
    end

    -- 2. COLOR PICKER
    if options.Color then
        -- [CORREÇÃO CARREGAMENTO COR]
        local savedColor = Library.Flags.Colors[flag]
        local startColor = options.Color

        if savedColor and type(savedColor) == "table" then
            startColor = Color3.new(savedColor[1], savedColor[2], savedColor[3])
        end

        local ColorInd = Instance.new("TextButton", parent)
        ColorInd.Size = UDim2.fromOffset(20, 20)
        ColorInd.AnchorPoint = Vector2.new(1, 0.5)
        
        local function updateColorPos()
            local xOffset = -10
            if KeyBtn then xOffset = -20 - KeyBtn.AbsoluteSize.X end
            ColorInd.Position = UDim2.new(1, xOffset, 0.5, 0)
        end

        updateColorPos()
        if KeyBtn then KeyBtn:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColorPos) end

        ColorInd.BackgroundColor3 = startColor
        ColorInd.Text = ""
        ColorInd.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", ColorInd).CornerRadius = UDim.new(0, 4)
        local Stroke = Instance.new("UIStroke", ColorInd)
        Stroke.Color = Theme.ItemStroke

        ColorInd.MouseButton1Click:Connect(function()
            Library:OpenColorPicker(ColorInd.BackgroundColor3, function(newC)
                ColorInd.BackgroundColor3 = newC
                -- [CORREÇÃO SALVAMENTO COR]
                Library.Flags.Colors[flag] = {newC.R, newC.G, newC.B}
                if callback then callback("Color", newC) end
                if SaveSettings then SaveSettings() end -- Salva ao mudar a cor
            end)
        end)

        -- Aplica a cor carregada inicialmente ao script
        task.spawn(function()
            if callback then callback("Color", startColor) end
        end)
    end 
end

    local first = true
    function WindowTable:Tab(name, iconid)
        local TabFuncs = {}
        
        -- Página
        local Page = Instance.new("ScrollingFrame", PagesFolder)
        Page.Name = name
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        Page.ZIndex = 5

        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        local PagePad = Instance.new("UIPadding", Page)
        PagePad.PaddingTop = UDim.new(0, 15)
        PagePad.PaddingLeft = UDim.new(0, 15)
        PagePad.PaddingRight = UDim.new(0, 15)
        PagePad.PaddingBottom = UDim.new(0, 15)

        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 30)
        end)

    -- Botão da Tab
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Size = UDim2.new(0, 140, 0, 32)
    Btn.BackgroundColor3 = Theme.Accent
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Theme.SubText
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left -- Alinhamos à esquerda
    Btn.ZIndex = 4
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    -- Padding para o texto não colar no ícone
    local TextPad = Instance.new("UIPadding", Btn)
    TextPad.PaddingLeft = UDim.new(0, 35) -- Espaço para o ícone

    -- Criando o Ícone
    local Icon = Instance.new("ImageLabel", Btn)
    Icon.Name = "Icon"
    Icon.Size = UDim2.fromOffset(18, 18)
    Icon.Position = UDim2.new(0, -25, 0.5, 0) -- Posição relativa ao texto (usando o padding)
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconid or "rbxassetid://6031230167" -- Ícone padrão se não definir
    Icon.ImageColor3 = Theme.SubText
    Icon.ZIndex = 5

    -- Ajuste na animação de clique para mudar a cor do ícone também
    local function Show()
        for _, v in pairs(TabContainer:GetChildren()) do
            if v:IsA("TextButton") then
                Library:Tween(v, {BackgroundTransparency = 1, TextColor3 = Theme.SubText})
                if v:FindFirstChild("Icon") then
                    Library:Tween(v.Icon, {ImageColor3 = Theme.SubText}, 0.2)
                end
            end
        end
        for _, v in pairs(PagesFolder:GetChildren()) do v.Visible = false end
        
        Library:Tween(Btn, {BackgroundTransparency = 0.85, TextColor3 = Theme.Accent})
        Library:Tween(Icon, {ImageColor3 = Theme.Accent}, 0.2)
        Page.Visible = true
    end
    -- ... (resto da função continua igual)

        local function Show()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Library:Tween(v, {BackgroundTransparency = 1, TextColor3 = Theme.SubText})
                end
            end
            for _, v in pairs(PagesFolder:GetChildren()) do v.Visible = false end
            
            Library:Tween(Btn, {BackgroundTransparency = 0.85, TextColor3 = Theme.Accent})
            Page.Visible = true
        end

        Btn.MouseButton1Click:Connect(Show)
        if first then Show(); first = false end

        --// ELEMENTOS DA UI
        
        function TabFuncs:Section(text)
            local Sec = Instance.new("TextLabel", Page)
            Sec.Text = string.upper(text)
            Sec.Size = UDim2.new(1, 0, 0, 25)
            Sec.BackgroundTransparency = 1
            Sec.TextColor3 = Theme.SubText
            Sec.Font = Enum.Font.GothamBold
            Sec.TextSize = 11
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Sec.ZIndex = 5
        end

        function TabFuncs:Button(text, callback, options)
    local BtnFrame = Instance.new("TextButton", Page)
    BtnFrame.Size = UDim2.new(1, 0, 0, 42)
    BtnFrame.BackgroundColor3 = Theme.ItemBG
    BtnFrame.Text = ""
    BtnFrame.AutoButtonColor = false
    BtnFrame.ZIndex = 5
    
    Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 8)
    
    -- Criamos o Stroke e guardamos em uma variável
    local Stroke = Instance.new("UIStroke", BtnFrame)
    Stroke.Color = Color3.fromRGB(50, 50, 50) -- Cor Cinza Inicial
    Stroke.Thickness = 1.2 -- Opcional: deixar a borda um pouco mais visível
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Lbl = Instance.new("TextLabel", BtnFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -20, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Theme.Text
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 6

    -- Cores da animação
    local ColorNormal = Color3.fromRGB(50, 50, 50) -- Cinza
    local ColorHover = Color3.fromRGB(0, 170, 255)  -- Azul (ajuste o tom se preferir)

    -- Animação ao entrar (Mouse In)
    BtnFrame.MouseEnter:Connect(function()
        Library:Tween(Stroke, {Color = ColorHover}, 0.2)
    end)

    -- Animação ao sair (Mouse Out)
    BtnFrame.MouseLeave:Connect(function()
        Library:Tween(Stroke, {Color = ColorNormal}, 0.2)
    end)

    local function Activate()
        Library:Tween(BtnFrame, {BackgroundColor3 = Color3.fromRGB(55,55,60)}, 0.1)
        task.wait(0.1)
        Library:Tween(BtnFrame, {BackgroundColor3 = Theme.ItemBG}, 0.1)
        if callback then callback() end
    end

    BtnFrame.MouseButton1Click:Connect(Activate)
    
    AddExtras(BtnFrame, options, function(mode, val)
        if mode == "Trigger" then Activate() end
    end)
end

      function TabFuncs:Toggle(text, default, callback, options)
    local flag = (options and options.Flag) or text
    
    -- CORREÇÃO: Verifica se já existe valor carregado no sistema de flags
    local savedValue = Library.Flags and Library.Flags.Toggles and Library.Flags.Toggles[flag]
    local toggled = (savedValue ~= nil) and savedValue or (default or false)
    
    local ActiveColor = Color3.fromRGB(0, 120, 255)
    local InactiveColor = Color3.fromRGB(60, 60, 65)

    if not Library.Flags then Library.Flags = { Toggles = {}, Binds = {}, Colors = {} } end
    if not Library.Elements then Library.Elements = {} end 
    
    Library.Flags.Toggles[flag] = toggled

    local TogFrame = Instance.new("TextButton", Page)
    TogFrame.Size = UDim2.new(1, 0, 0, 42)
    TogFrame.BackgroundColor3 = Theme.ItemBG
    TogFrame.Text = ""
    TogFrame.AutoButtonColor = false
    TogFrame.ZIndex = 5
    Instance.new("UICorner", TogFrame).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", TogFrame)
    Stroke.Color = Theme.ItemStroke

    local Lbl = Instance.new("TextLabel", TogFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -60, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Theme.Text
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 6

    local Switch = Instance.new("Frame", TogFrame)
    Switch.Size = UDim2.fromOffset(40, 22)
    Switch.ZIndex = 6
    Switch.BackgroundColor3 = toggled and ActiveColor or InactiveColor
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local function UpdateSwitchPosition()
        local totalExtraWidth = 0
        if options then
            if options.Keybind ~= nil then totalExtraWidth = totalExtraWidth + 35 end
            if options.Color ~= nil then totalExtraWidth = totalExtraWidth + 25 end
        end
        Switch.Position = UDim2.new(1, -55 - totalExtraWidth, 0.5, -11)
    end

    local Ball = Instance.new("Frame", Switch)
    Ball.Size = UDim2.fromOffset(18, 18)
    Ball.Position = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Ball.BackgroundColor3 = Color3.new(1,1,1)
    Ball.ZIndex = 7
    Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

    local function Swap(quiet)
        if not quiet then 
            toggled = not toggled 
        end
        
        Library.Flags.Toggles[flag] = toggled
        
        -- Atualização Visual
        Library:Tween(Switch, {BackgroundColor3 = toggled and ActiveColor or InactiveColor}, 0.2)
        Library:Tween(Ball, {Position = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
        
        -- Executa o callback
        task.spawn(function()
            local success, err = pcall(function()
                callback(toggled)
            end)
            if not success then
                warn("Erro no callback do Toggle ["..flag.."]: "..tostring(err))
            end
        end)

        -- Salva as configs sempre que mudar manualmente
        if not quiet and SaveSettings then SaveSettings() end
    end

    TogFrame.MouseButton1Click:Connect(function() Swap(false) end)

    AddExtras(TogFrame, options, function(mode, val)
        if mode == "Trigger" then Swap(false) end
        if mode == "Color" then callback("Color", val) end
    end)
    
    UpdateSwitchPosition()

    -- CORREÇÃO: Roda o estado inicial carregado
    task.spawn(function() 
        pcall(function() callback(toggled) end) 
    end)

    local function SetState(bool)
        if toggled ~= bool then 
            toggled = bool 
            Swap(true)
        end
    end

    if not Library.Elements[flag] then Library.Elements[flag] = {} end
    Library.Elements[flag].Set = SetState
    Library.Elements[flag].Type = "Toggle"

    return { Set = SetState }
end

function TabFuncs:Slider(text, min, max, default, callback, options)
    local flag = (options and options.Flag) or text
    local value = default or min
    
    local ActiveColor = Color3.fromRGB(0, 120, 255)
    local InactiveColor = Color3.fromRGB(60, 60, 65)
    local UIS = game:GetService("UserInputService")

    -- CORREÇÃO DO ERRO: Inicializa cada tabela individualmente se não existir
    Library.Flags = Library.Flags or {}
    Library.Flags.Sliders = Library.Flags.Sliders or {}
    Library.Flags.Sliders[flag] = value

    local SliFrame = Instance.new("TextButton", Page)
    SliFrame.Size = UDim2.new(1, 0, 0, 50)
    SliFrame.BackgroundColor3 = Theme.ItemBG
    SliFrame.Text = ""
    SliFrame.AutoButtonColor = false
    Instance.new("UICorner", SliFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", SliFrame).Color = Theme.ItemStroke

    local Lbl = Instance.new("TextLabel", SliFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -60, 0, 25)
    Lbl.Position = UDim2.new(0, 12, 0, 5)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Theme.Text
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ValLbl = Instance.new("TextLabel", SliFrame)
    ValLbl.Text = tostring(value)
    ValLbl.Size = UDim2.new(0, 40, 0, 25)
    ValLbl.Position = UDim2.new(1, -52, 0, 5)
    ValLbl.BackgroundTransparency = 1
    ValLbl.TextColor3 = ActiveColor
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextSize = 13
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBack = Instance.new("Frame", SliFrame)
    SliderBack.Size = UDim2.new(1, -24, 0, 4)
    SliderBack.Position = UDim2.new(0, 12, 1, -12)
    SliderBack.BackgroundColor3 = InactiveColor
    SliderBack.BorderSizePixel = 0
    Instance.new("UICorner", SliderBack)

    local SliderFill = Instance.new("Frame", SliderBack)
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = ActiveColor
    SliderFill.BorderSizePixel = 0
    Instance.new("UICorner", SliderFill)

    local Ball = Instance.new("Frame", SliderFill)
    Ball.AnchorPoint = Vector2.new(0.5, 0.5)
    Ball.Size = UDim2.fromOffset(12, 12)
    Ball.Position = UDim2.new(1, 0, 0.5, 0)
    Ball.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", Ball).Color = ActiveColor

    local dragging = false
    local function move(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(((max - min) * pos) + min)
        
        value = newValue
        Library.Flags.Sliders[flag] = newValue -- Agora a tabela existe!
        
        Library:Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
        ValLbl.Text = tostring(newValue)
        callback(newValue)
    end

    SliFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            move(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            move(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Set = function(self, val)
            local clamped = math.clamp(val, min, max)
            value = clamped
            ValLbl.Text = tostring(clamped)
            Library:Tween(SliderFill, {Size = UDim2.new((clamped - min)/(max - min), 0, 1, 0)}, 0.2)
            callback(clamped)
        end
    }
end

--// NOVO: ADICIONANDO A FUNÇÃO DE INPUT PARA MOEDAS (CONFORME PEDIDO)
function TabFuncs:Input(text, placeholder, callback)
    local InputFrame = Instance.new("Frame", Page)
    InputFrame.Size = UDim2.new(1, 0, 0, 42)
    InputFrame.BackgroundColor3 = Theme.ItemBG
    InputFrame.ZIndex = 5
    Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", InputFrame).Color = Theme.ItemStroke

    local Lbl = Instance.new("TextLabel", InputFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(0, 150, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Theme.Text
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 6

    local Box = Instance.new("TextBox", InputFrame)
    Box.Size = UDim2.new(0, 100, 0, 24)
    Box.Position = UDim2.new(1, -110, 0.5, -12)
    Box.BackgroundColor3 = Theme.Background
    Box.Text = ""
    Box.PlaceholderText = placeholder or "..."
    Box.TextColor3 = Theme.Text
    Box.PlaceholderColor3 = Theme.SubText
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.ZIndex = 6
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    Box.FocusLost:Connect(function(enter)
        callback(Box.Text)
    end)
end

        function TabFuncs:Dropdown(text, list, callback)
    local list = list or {}
    local dropped = false
    local currentSelected = list[1] or "..."
    local DropFuncs = {}

    -- Frame Principal (O que fica na aba)
    local DropMain = Instance.new("Frame", Page)
    DropMain.Name = "Dropdown_" .. text
    DropMain.Size = UDim2.new(1, 0, 0, 42)
    DropMain.BackgroundColor3 = Theme.ItemBG
    DropMain.ZIndex = 5
    Instance.new("UICorner", DropMain).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", DropMain)
    MainStroke.Color = Theme.ItemStroke
    MainStroke.Thickness = 1

    -- Label do Selecionado
    local SelectedLabel = Instance.new("TextLabel", DropMain)
    SelectedLabel.Text = text .. ": " .. currentSelected
    SelectedLabel.Size = UDim2.new(1, -60, 1, 0)
    SelectedLabel.Position = UDim2.new(0, 12, 0, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.TextColor3 = Theme.Text
    SelectedLabel.Font = Enum.Font.GothamMedium
    SelectedLabel.TextSize = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.ZIndex = 6

    -- Botão de Abrir
    local OpenBtn = Instance.new("TextButton", DropMain)
    OpenBtn.Size = UDim2.new(0, 36, 0, 30)
    OpenBtn.Position = UDim2.new(1, -6, 0.5, 0)
    OpenBtn.AnchorPoint = Vector2.new(1, 0.5)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    OpenBtn.Text = ""
    OpenBtn.ZIndex = 7
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)
    
    local Arrow = Instance.new("ImageLabel", OpenBtn)
    Arrow.Size = UDim2.fromOffset(14, 14)
    Arrow.Position = UDim2.fromScale(0.5, 0.5)
    Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://6034818372"
    Arrow.ImageColor3 = Theme.SubText
    Arrow.ZIndex = 8

    -- O Menu Suspenso (Ajustado ZIndex e Scroll)
    local DropList = Instance.new("ScrollingFrame", Library.ScreenGui)
    DropList.Name = "DropList_" .. text
    DropList.Size = UDim2.new(0, 180, 0, 0) 
    DropList.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    DropList.Visible = false
    DropList.ClipsDescendants = true
    DropList.ZIndex = 2000 
    DropList.BorderSizePixel = 0
    DropList.ScrollBarThickness = 3 -- Aumentado levemente para facilitar
    DropList.ScrollBarImageColor3 = Theme.Accent
    DropList.CanvasSize = UDim2.new(0, 0, 0, 0)
    DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 10)
    local ListStroke = Instance.new("UIStroke", DropList)
    ListStroke.Color = Color3.fromRGB(60, 60, 65)
    
    local ListLayout = Instance.new("UIListLayout", DropList)
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local ListPadding = Instance.new("UIPadding", DropList)
    ListPadding.PaddingTop = UDim.new(0, 6)
    ListPadding.PaddingBottom = UDim.new(0, 6)
    ListPadding.PaddingLeft = UDim.new(0, 6)
    ListPadding.PaddingRight = UDim.new(0, 6)

    -- AJUSTE: Garante que o Canvas tenha espaço extra no fundo para o último item
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DropList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 15)
    end)

    local function UpdateListPosition()
        DropList.Position = UDim2.fromOffset(
            OpenBtn.AbsolutePosition.X - DropList.AbsoluteSize.X + OpenBtn.AbsoluteSize.X,
            OpenBtn.AbsolutePosition.Y + OpenBtn.AbsoluteSize.Y + 5
        )
    end

    -- Função de Toggle Animada
    local function Toggle(state)
        dropped = state
        if dropped then
            UpdateListPosition()
            DropList.Visible = true
            -- Calcula altura baseada nos itens, mas trava em 200px
            local targetHeight = math.min(ListLayout.AbsoluteContentSize.Y + 15, 200)
            Library:Tween(DropList, {Size = UDim2.new(0, 180, 0, targetHeight)}, 0.2)
            Library:Tween(Arrow, {Rotation = 180}, 0.2)
        else
            Library:Tween(DropList, {Size = UDim2.new(0, 180, 0, 0)}, 0.2)
            Library:Tween(Arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function() 
                if not dropped then DropList.Visible = false end 
            end)
        end
    end

    OpenBtn.MouseButton1Click:Connect(function()
        Toggle(not dropped)
    end)

    -- Função para criar cada opção (Ajustado ZIndex e clique)
    local function CreateOption(v)
        local Option = Instance.new("TextButton", DropList)
        Option.Size = UDim2.new(1, -5, 0, 32) -- Reduzido para não colidir com o scroll
        Option.BackgroundTransparency = 1
        Option.BackgroundColor3 = Theme.Accent
        Option.Text = v
        Option.TextColor3 = Theme.Text
        Option.Font = Enum.Font.Gotham
        Option.TextSize = 13
        Option.TextXAlignment = Enum.TextXAlignment.Left
        Option.ZIndex = 2010 -- Maior que o DropList
        
        local OptCorner = Instance.new("UICorner", Option)
        OptCorner.CornerRadius = UDim.new(0, 6)
        local OptPad = Instance.new("UIPadding", Option)
        OptPad.PaddingLeft = UDim.new(0, 10)

        Option.MouseEnter:Connect(function()
            Library:Tween(Option, {BackgroundTransparency = 0.8}, 0.2)
        end)
        Option.MouseLeave:Connect(function()
            Library:Tween(Option, {BackgroundTransparency = 1}, 0.2)
        end)

        Option.MouseButton1Click:Connect(function()
            currentSelected = v
            SelectedLabel.Text = text .. ": " .. v
            callback(v)
            Toggle(false)
        end)
    end

    -- Inicializa a lista
    for _, v in pairs(list) do CreateOption(v) end

    -- Função de Refresh
    function DropFuncs:Refresh(newList)
        for _, child in pairs(DropList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, v in pairs(newList) do CreateOption(v) end
        
        if dropped then
            local targetHeight = math.min(ListLayout.AbsoluteContentSize.Y + 15, 200)
            Library:Tween(DropList, {Size = UDim2.new(0, 180, 0, targetHeight)}, 0.2)
        end
    end

    -- Fechar ao clicar fora (Corrigido detecção de área)
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropped then
            task.wait(0.05) 
            local pos = UserInputService:GetMouseLocation()
            local lp, ls = DropList.AbsolutePosition, DropList.AbsoluteSize
            local bp, bs = OpenBtn.AbsolutePosition, OpenBtn.AbsoluteSize

            -- Compensação da TopBar (36px)
            local inList = (pos.X >= lp.X and pos.X <= lp.X + ls.X and pos.Y >= lp.Y + 36 and pos.Y <= lp.Y + ls.Y + 36)
            local inBtn = (pos.X >= bp.X and pos.X <= bp.X + bs.X and pos.Y >= bp.Y + 36 and pos.Y <= bp.Y + bs.Y + 36)

            if not inList and not inBtn then
                Toggle(false)
            end
        end
    end)
    
    return DropFuncs
end

        function TabFuncs:Input(text, default, callback)
            local InpFrame = Instance.new("Frame", Page)
            InpFrame.Size = UDim2.new(1, 0, 0, 42)
            InpFrame.BackgroundColor3 = Theme.ItemBG
            InpFrame.ZIndex = 5
            Instance.new("UICorner", InpFrame).CornerRadius = UDim.new(0, 8)
            Instance.new("UIStroke", InpFrame).Color = Theme.ItemStroke

            local Lbl = Instance.new("TextLabel", InpFrame)
            Lbl.Text = text
            Lbl.Size = UDim2.new(0.6, 0, 1, 0)
            Lbl.Position = UDim2.new(0, 12, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.TextColor3 = Theme.Text
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.ZIndex = 6

            local Box = Instance.new("TextBox", InpFrame)
            Box.Size = UDim2.new(0.35, -10, 0, 26)
            Box.Position = UDim2.new(1, -10, 0.5, 0)
            Box.AnchorPoint = Vector2.new(1, 0.5)
            Box.BackgroundColor3 = Theme.Background
            Box.TextColor3 = Theme.Accent
            Box.PlaceholderText = "..."
            Box.Text = default or ""
            Box.Font = Enum.Font.GothamBold
            Box.TextSize = 12
            Box.ZIndex = 6
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)

            Box.FocusLost:Connect(function(enter)
                callback(Box.Text)
            end)
        end

        
        --// SERVER BROWSER TAB (Opcional)
        if config.ServerTab and name == "Servidores" then
            TabFuncs:Section("Lista de Servidores")
            
            local Status = Instance.new("TextLabel", Page)
            Status.Text = "Status: Aguardando..."
            Status.Size = UDim2.new(1, 0, 0, 25)
            Status.BackgroundTransparency = 1
            Status.TextColor3 = Theme.Accent
            Status.Font = Enum.Font.GothamBold
            Status.TextSize = 12
            Status.ZIndex = 5

            local Refresh = Instance.new("TextButton", Page)
            Refresh.Text = "Atualizar Lista"
            Refresh.Size = UDim2.new(1, 0, 0, 35)
            Refresh.BackgroundColor3 = Theme.Accent
            Refresh.TextColor3 = Theme.Text
            Refresh.Font = Enum.Font.GothamBold
            Refresh.TextSize = 13
            Refresh.ZIndex = 5
            Instance.new("UICorner", Refresh).CornerRadius = UDim.new(0, 6)

            local SrvList = Instance.new("Frame", Page)
            SrvList.Size = UDim2.new(1, 0, 0, 300) -- Altura fixa
            SrvList.BackgroundTransparency = 1
            SrvList.LayoutOrder = 99
            
            -- É melhor não usar um ScrollingFrame dentro de outro, então usamos o Page
            -- Mas precisamos limpar as cartas antigas.
            -- Para simplificar, vou criar as cartas direto no 'Page' abaixo do botão refresh.

            local function LoadServers()
                Status.Text = "Buscando..."
                -- Limpa antigos (que não sejam os botões padrão)
                for _, v in pairs(Page:GetChildren()) do
                    if v.Name == "ServerCard" then v:Destroy() end
                end

                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=50"
                local success, result = pcall(function() return game:HttpGet(url) end)

                if not success then
                    Status.Text = "Erro ao buscar servidores."
                    Status.TextColor3 = Theme.Red
                    return
                end

                local data = HttpService:JSONDecode(result).data
                Status.Text = "Encontrados: " .. #data
                Status.TextColor3 = Theme.Green

                for _, s in pairs(data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        local Card = Instance.new("Frame", Page)
                        Card.Name = "ServerCard"
                        Card.Size = UDim2.new(1, 0, 0, 50)
                        Card.BackgroundColor3 = Theme.ItemBG
                        Card.ZIndex = 5
                        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
                        Instance.new("UIStroke", Card).Color = Theme.ItemStroke

                        local Info = Instance.new("TextLabel", Card)
                        Info.Text = s.playing .. "/" .. s.maxPlayers .. " Players | Ping: " .. (s.ping or "N/A")
                        Info.Size = UDim2.new(0.7, 0, 1, 0)
                        Info.Position = UDim2.new(0, 10, 0, 0)
                        Info.BackgroundTransparency = 1
                        Info.TextColor3 = Theme.SubText
                        Info.Font = Enum.Font.GothamBold
                        Info.TextSize = 12
                        Info.TextXAlignment = Enum.TextXAlignment.Left
                        Info.ZIndex = 6

                        local Join = Instance.new("TextButton", Card)
                        Join.Text = "Entrar"
                        Join.Size = UDim2.new(0, 70, 0, 28)
                        Join.Position = UDim2.new(1, -10, 0.5, 0)
                        Join.AnchorPoint = Vector2.new(1, 0.5)
                        Join.BackgroundColor3 = Theme.Accent
                        Join.TextColor3 = Theme.Text
                        Join.Font = Enum.Font.GothamBold
                        Join.TextSize = 11
                        Join.ZIndex = 6
                        Instance.new("UICorner", Join).CornerRadius = UDim.new(0, 4)

                        Join.MouseButton1Click:Connect(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        end)
                    end
                end
            end
            
            Refresh.MouseButton1Click:Connect(LoadServers)
        end

        return TabFuncs
    end

    if config.ServerTab then WindowTable:Tab("Servidores", "rbxassetid://9692125126") end
--// Toggle Flutuante (Botão Redondo)
    local ToggleUI = Instance.new("TextButton", ScreenGui)
    ToggleUI.Name = "FloatingToggle"
    ToggleUI.Size = UDim2.fromOffset(50, 50)
    ToggleUI.Position = UDim2.new(0, 30, 0.4, 0)
    ToggleUI.BackgroundColor3 = Theme.Background
    ToggleUI.Text = "" 
    ToggleUI.ZIndex = 1000 
    
    Instance.new("UICorner", ToggleUI).CornerRadius = UDim.new(1, 0)
    
    local TStroke = Instance.new("UIStroke", ToggleUI)
    TStroke.Color = Theme.ItemStroke
    TStroke.Thickness = 2

    -- Adicionando a Imagem/Logo
    local Logo = Instance.new("ImageLabel", ToggleUI)
    Logo.Size = UDim2.fromScale(0.8, 0.8)
    Logo.Position = UDim2.fromScale(0.5, 0.5)
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://109406051515132"
    Logo.ZIndex = 1001

    -- Animação de Hover
    ToggleUI.MouseEnter:Connect(function()
        Library:Tween(TStroke, {Color = Theme.Accent}, 0.2)
    end)
    ToggleUI.MouseLeave:Connect(function()
        Library:Tween(TStroke, {Color = Theme.ItemStroke}, 0.2)
    end)

    -- Lógica de Arrastar e Clicar
    local dragging, dragStart, startPos, hasMoved
    
    ToggleUI.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleUI.Position
            hasMoved = false 
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                hasMoved = true
            end
            
            ToggleUI.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Função auxiliar para alternar o menu com animação
    local function ToggleMenu()
        UIOn = not UIOn
        Main.Visible = UIOn
        
        -- Pequena animação de clique (escala) para feedback
        Library:Tween(ToggleUI, {Size = UDim2.fromOffset(45, 45)}, 0.05)
        task.wait(0.05)
        Library:Tween(ToggleUI, {Size = UDim2.fromOffset(50, 50)}, 0.1)
    end

    ToggleUI.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not hasMoved then
                ToggleMenu()
            end
        end
    end)

    --// NOVA LÓGICA: Atalho RightShift + Tecla Customizada
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end -- Ignora se estiver no chat
        
        -- Verifica se apertou RightShift OU a tecla salva nas configurações
        if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Library.ToggleKey then
            ToggleMenu()
        end
    end)

    -- RETORNO CORRETO:
    return WindowTable
end

function Library:CreateSettings(Window)
    local SettingsTab = Window:Tab("Configurações", "rbxassetid://6031280882")
    
    --// 0. SEÇÃO DE TAGS (ADICIONADA)
    --// 0. SEÇÃO DE TAGS (ADICIONADA)
SettingsTab:Section("Tags CUSTOM")

SettingsTab:Toggle("Esconder Todas as Tags", false, function(state)
    -- Adicionamos _G. para conversar com o arquivo tag.lua
    if _G.toggleAllTags then
        _G.toggleAllTags(not state) 
    end
end)

SettingsTab:Toggle("Esconder Minha Tag", false, function(state)
    -- Adicionamos _G. para conversar com o arquivo tag.lua
    if _G.toggleMyTag then
        _G.toggleMyTag(not state)
    end
end)

    --// 1. PREPARAÇÃO
    local ConfigFolder = "DobeiOS_Configs"
    local ConfigName = "Default"
    local SelectedConfig = nil
    
    -- Define valores padrão se não existirem
    if not Library.ToggleKey then Library.ToggleKey = Enum.KeyCode.RightControl end

    -- Garante que a pasta existe
    if makefolder and isfolder and not isfolder(ConfigFolder) then 
        makefolder(ConfigFolder) 
    end

    

    SettingsTab:Section("GERENCIAR CONFIGS")

    SettingsTab:Input("Nome da Config", "Default", function(text)
        ConfigName = text
    end)

    local function GetConfigs()
        if not listfiles then return {} end
        local files = listfiles(ConfigFolder)
        local names = {}
        for _, file in pairs(files) do
            local cleanName = file:match("([^/]+)%.json$") or file:match("([^/]+)$")
            if cleanName then table.insert(names, cleanName) end
        end
        return names
    end

    local ConfigDrop = SettingsTab:Dropdown("Configs Salvas", GetConfigs(), function(val)
        SelectedConfig = val
    end)

    SettingsTab:Button("Atualizar Lista", function()
        ConfigDrop:Refresh(GetConfigs())
    end)

    -- SALVAR
    SettingsTab:Button("Salvar Configuração", function()
        if not writefile then return end
        
        local SaveData = {
            ThemeData = {
                AccentHex = Theme.Accent:ToHex()
            },
            Keybinds = {
                MenuToggle = Library.ToggleKey.Name 
            },
            Toggles = Library.Flags.Toggles,
            Binds = Library.Flags.Binds,
            Colors = Library.Flags.Colors
        }
        
        local success, json = pcall(function() return HttpService:JSONEncode(SaveData) end)
        if success then
            writefile(ConfigFolder .. "/" .. ConfigName .. ".json", json)
            NotificationService:Create("CriarConfig", "✅ Configuração '"..ConfigName.."' salva!")
            task.wait(1.2)
            NotificationService:Remove("CriarConfig")
            ConfigDrop:Refresh(GetConfigs())
        end
    end)

    -- CARREGAR
    SettingsTab:Button("Carregar Configuração", function()
        if not readfile or not SelectedConfig then return end
        
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        if isfile(path) then
            local content = readfile(path)
            local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
            
            if success and decoded then
                -- 1. Carregar Toggles
                if decoded.Toggles then
                    for flag, value in pairs(decoded.Toggles) do
                        if Library.Elements[flag] and Library.Elements[flag].Set then
                            Library.Elements[flag].Set(value)
                        end
                    end
                end

                -- 2. Carregar Keybinds
                if decoded.Binds then
                    for flag, keyName in pairs(decoded.Binds) do
                        if Library.Elements[flag] and Library.Elements[flag].SetKey then
                            Library.Elements[flag].SetKey(keyName)
                        end
                    end
                end

                -- 3. Carregar Cores
                if decoded.Colors then
                    for flag, rgbTable in pairs(decoded.Colors) do
                        if Library.Elements[flag] and Library.Elements[flag].SetColor then
                            Library.Elements[flag].SetColor(rgbTable[1], rgbTable[2], rgbTable[3])
                        end
                    end
                end

                -- 4. Dados do Tema
                if decoded.ThemeData and decoded.ThemeData.AccentHex then
                    Theme.Accent = Color3.fromHex(decoded.ThemeData.AccentHex)
                end

                -- 5. Tecla do Menu
                if decoded.Keybinds and decoded.Keybinds.MenuToggle then
                    Library.ToggleKey = Enum.KeyCode[decoded.Keybinds.MenuToggle]
                end
                
                if NotificationService then
                    NotificationService:Create("ConfigLoad", "Configuração carregada com sucesso!")
                    task.wait(1.2)
                    NotificationService:Remove("ConfigLoad")
                end
            end
        end
    end)

    -- DELETAR
    SettingsTab:Button("Deletar Configuração", function()
        if not delfile or not SelectedConfig then return end
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        if isfile(path) then
            delfile(path)
            ConfigDrop:Refresh(GetConfigs())
            SelectedConfig = nil
            if NotificationService then
                NotificationService:Create("DeleteConfig", "Config deletada.")
                task.wait(1.2)
                NotificationService:Remove("DeleteConfig")
            end
        end
    end)
end

return Library

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

