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
        writefile(ConfigFile, HttpService:JSONEncode(_Config))
    end
end

-- Função para Carregar do Arquivo
local function LoadSettings()
    if isfile and isfile(ConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success then _Config = data end
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
Gui.Name = "ModernNotifications"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999
Gui.Parent = LP:WaitForChild("PlayerGui")

local Holder = Instance.new("Frame")
Holder.Name = "NotificationHolder"
Holder.Size = UDim2.new(1, 0, 0, 0)
Holder.Position = UDim2.new(0, 0, 0, 20)
Holder.BackgroundTransparency = 1
Holder.Parent = Gui

local Layout = Instance.new("UIListLayout")
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Top
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Holder

--// ESTILO MODERNO (PRETO E BRANCO)
local function Notify(text, duration)
    duration = duration or 3
    
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(0, 34) -- Começa com largura 0 para animação
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Fundo quase preto
    f.BackgroundTransparency = 0.2 -- Translúcido estilo Keybind
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = Holder

    local c = Instance.new("UICorner", f)
    c.CornerRadius = UDim.new(0, 6)

    local s = Instance.new("UIStroke", f)
    s.Thickness = 1
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.8 -- Borda branca sutil
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text:upper() -- Texto em uppercase fica mais moderno
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextTransparency = 1
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.Parent = f
    
    -- Barra de duração (estética moderna)
    local timerBar = Instance.new("Frame", f)
    timerBar.Size = UDim2.new(1, 0, 0, 1)
    timerBar.Position = UDim2.new(0, 0, 1, -1)
    timerBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    timerBar.BackgroundTransparency = 0.4
    timerBar.BorderSizePixel = 0

    --// ANIMAÇÃO PROFISSIONAL
    -- 1. Entrada (Expansão e Fade In)
    TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(400, 34)}):Play()
    TweenService:Create(l, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    
    -- 2. Barra de tempo diminuindo
    TweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 1)}):Play()

    task.delay(duration, function()
        -- 3. Saída (Slide Up e Fade Out)
        TweenService:Create(l, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 1}):Play()
        local out = TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1})
        out:Play()
        out.Completed:Connect(function()
            f:Destroy()
        end)
    end)
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
    
    -- Overlay de Fundo (Blur visual)
    local Overlay = Instance.new("TextButton") -- TextButton para capturar cliques e não fechar o menu atrás
    Overlay.Name = "ColorPickerOverlay"
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.new(0,0,0)
    Overlay.BackgroundTransparency = 1
    Overlay.AutoButtonColor = false
    Overlay.Text = ""
    Overlay.ZIndex = 5000
    Overlay.Parent = Library.ScreenGui

    local Main = Instance.new("Frame", Overlay)
    Main.Size = UDim2.fromOffset(260, 320)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.fromScale(0.5, 0.6) -- Começa abaixo para o efeito de slide-up
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BackgroundTransparency = 0.1
    Main.ZIndex = 5001

    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 12)
    
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.8
    MainStroke.Thickness = 1

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "COLOR PICKER"
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.ZIndex = 5002

    -- Área Saturação/Valor
    local SVFrame = Instance.new("ImageButton", Main)
    SVFrame.Name = "SVFrame"
    SVFrame.Size = UDim2.new(1, -30, 0, 150)
    SVFrame.Position = UDim2.new(0, 15, 0, 45)
    SVFrame.Image = "rbxassetid://4155801252"
    SVFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    SVFrame.ZIndex = 5002
    Instance.new("UICorner", SVFrame).CornerRadius = UDim.new(0, 8)

    local PickerCursor = Instance.new("Frame", SVFrame)
    PickerCursor.Size = UDim2.fromOffset(12, 12)
    PickerCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    PickerCursor.Position = UDim2.fromScale(s, 1-v)
    PickerCursor.BackgroundColor3 = Color3.new(1,1,1)
    PickerCursor.ZIndex = 5003
    
    local CursorCorner = Instance.new("UICorner", PickerCursor)
    CursorCorner.CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", PickerCursor).Thickness = 2
    
    -- Barra Hue (Arco-íris)
    local HueFrame = Instance.new("ImageButton", Main)
    HueFrame.Name = "HueFrame"
    HueFrame.Size = UDim2.new(1, -30, 0, 12)
    HueFrame.Position = UDim2.new(0, 15, 0, 210)
    HueFrame.Image = "rbxassetid://3641079629"
    HueFrame.ZIndex = 5002
    Instance.new("UICorner", HueFrame).CornerRadius = UDim.new(1, 0)

    local HueCursor = Instance.new("Frame", HueFrame)
    HueCursor.Size = UDim2.new(0, 6, 1, 4)
    HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    HueCursor.Position = UDim2.fromScale(h, 0.5)
    HueCursor.BackgroundColor3 = Color3.new(1,1,1)
    HueCursor.ZIndex = 5003
    Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(1, 0)

    -- Botão de Confirmação (Estilo Minimalista)
    local ConfirmBtn = Instance.new("TextButton", Main)
    ConfirmBtn.Text = "CONFIRMAR"
    ConfirmBtn.Size = UDim2.new(1, -30, 0, 35)
    ConfirmBtn.Position = UDim2.new(0, 15, 1, -50)
    ConfirmBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ConfirmBtn.Font = Enum.Font.GothamBold
    ConfirmBtn.TextSize = 12
    ConfirmBtn.ZIndex = 5002
    Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 6)

    -- Logica de Cores
    local function UpdateColor()
        local newColor = Color3.fromHSV(h, s, v)
        SVFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        callback(newColor)
    end

    local draggingHue, draggingSV = false, false

    SVFrame.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end 
    end)
    HueFrame.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end 
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = false; draggingSV = false end 
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingHue then
                h = math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
                HueCursor.Position = UDim2.fromScale(h, 0.5)
                UpdateColor()
            elseif draggingSV then
                s = math.clamp((input.Position.X - SVFrame.AbsolutePosition.X) / SVFrame.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - SVFrame.AbsolutePosition.Y) / SVFrame.AbsoluteSize.Y, 0, 1)
                PickerCursor.Position = UDim2.fromScale(s, 1-v)
                UpdateColor()
            end
        end
    end)

    -- Animações de entrada profissionais
    TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.5)}):Play()

    ConfirmBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        local out = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, 0.55), BackgroundTransparency = 1})
        out:Play()
        out.Completed:Connect(function()
            Overlay:Destroy()
        end)
    end)
end

function Library:Prompt(config)
    -- config = {Title = "", Text = "", Buttons = {{Text="Sim", Callback=...}, {Text="Não", Callback=...}}}
    if not Library.ScreenGui then return end
    
    local Overlay = Instance.new("TextButton") -- Usado para bloquear cliques atrás
    Overlay.Name = "PromptOverlay"
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.new(0,0,0)
    Overlay.BackgroundTransparency = 1
    Overlay.AutoButtonColor = false
    Overlay.Text = ""
    Overlay.ZIndex = 6000
    Overlay.Parent = Library.ScreenGui

    local PromptFrame = Instance.new("Frame")
    PromptFrame.Size = UDim2.fromOffset(320, 0)
    PromptFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    PromptFrame.Position = UDim2.fromScale(0.5, 0.52) -- Começa levemente deslocado
    PromptFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    PromptFrame.BackgroundTransparency = 0.1
    PromptFrame.ClipsDescendants = true
    PromptFrame.ZIndex = 6001
    PromptFrame.Parent = Overlay

    local Corner = Instance.new("UICorner", PromptFrame)
    Corner.CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", PromptFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.8

    local Title = Instance.new("TextLabel", PromptFrame)
    Title.Text = (config.Title or "PROMPT"):upper()
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 6002
    Title.TextTransparency = 1
    
    local Desc = Instance.new("TextLabel", PromptFrame)
    Desc.Text = config.Text or "Deseja confirmar esta ação?"
    Desc.Size = UDim2.new(1, -40, 0, 0)
    Desc.Position = UDim2.new(0, 20, 0, 50)
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 13
    Desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    Desc.BackgroundTransparency = 1
    Desc.ZIndex = 6002
    Desc.TextWrapped = true
    Desc.AutomaticSize = Enum.AutomaticSize.Y
    Desc.TextTransparency = 1
    Desc.Parent = PromptFrame

    local ButtonContainer = Instance.new("Frame", PromptFrame)
    ButtonContainer.Size = UDim2.new(1, -30, 0, 35)
    ButtonContainer.Position = UDim2.new(0, 15, 1, -50)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 6002

    local UIList = Instance.new("UIListLayout", ButtonContainer)
    UIList.FillDirection = Enum.FillDirection.Horizontal
    UIList.Padding = UDim.new(0, 10)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local buttons = config.Buttons or {{Text = "OK", Callback = function() end}}
    local btnCount = #buttons
    local btnWidth = (290 - (10 * (btnCount - 1))) / btnCount

    for _, btnData in pairs(buttons) do
        local Btn = Instance.new("TextButton", ButtonContainer)
        Btn.Size = UDim2.new(0, btnWidth, 1, 0)
        Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Text = btnData.Text:upper()
        Btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Btn.AutoButtonColor = true
        Btn.ZIndex = 6003
        Btn.BackgroundTransparency = 1
        Btn.TextTransparency = 1
        
        local BCorner = Instance.new("UICorner", Btn)
        BCorner.CornerRadius = UDim.new(0, 6)
        
        Btn.MouseButton1Click:Connect(function()
            local out = game:GetService("TweenService"):Create(PromptFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(320, 0), BackgroundTransparency = 1})
            game:GetService("TweenService"):Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            out:Play()
            out.Completed:Connect(function()
                Overlay:Destroy()
                if btnData.Callback then btnData.Callback() end
            end)
        end)
    end

    -- Ajuste Dinâmico de Altura
    task.spawn(function()
        task.wait()
        local textHeight = Desc.AbsoluteSize.Y
        local totalHeight = 50 + textHeight + 30 + 35 + 20
        
        -- Animação de Entrada
        game:GetService("TweenService"):Create(Overlay, TweenInfo.new(0.4), {BackgroundTransparency = 0.5}):Play()
        game:GetService("TweenService"):Create(PromptFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(320, totalHeight), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0.1}):Play()
        
        for _, v in pairs(PromptFrame:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                game:GetService("TweenService"):Create(v, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
                if v:IsA("TextButton") then
                    game:GetService("TweenService"):Create(v, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
                end
            end
        end
    end)
end

function Library:CreateMiniPanel(config)
    -- config = {Name = "Tags", Size = UDim2.fromOffset(200, 300)}
    local Panel = {}
    local TweenService = game:GetService("TweenService")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MiniPanel_" .. (config.Name or "Ui")
    MainFrame.Size = config.Size or UDim2.fromOffset(210, 260)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BackgroundTransparency = 0.15 -- Efeito Glass
    MainFrame.ZIndex = 2100
    MainFrame.Parent = Library.ScreenGui
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    
    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.85 -- Borda bem sutil

    -- Lógica de Arrastar (Smooth Drag)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.1), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = (config.Name or "PANEL"):upper()
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 11
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -32, 0, 2)
    CloseBtn.Text = "×" -- Símbolo de fechar mais elegante
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 20
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.GothamMedium
    CloseBtn.MouseButton1Click:Connect(function() Panel:Toggle() end)

    local Scroll = Instance.new("ScrollingFrame", MainFrame)
    Scroll.Size = UDim2.new(1, -16, 1, -45)
    Scroll.Position = UDim2.new(0, 8, 0, 35)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 0 -- Scroll invisível para estética moderna
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local List = Instance.new("UIListLayout", Scroll)
    List.Padding = UDim.new(0, 6)
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
    end)

    function Panel:AddButton(text, cb, customColor)
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(1, 0, 0, 32)
        Btn.BackgroundColor3 = customColor or Color3.fromRGB(255, 255, 255)
        Btn.BackgroundTransparency = customColor and 0 or 0.9 -- Botão padrão é quase invisível até hover
        Btn.Text = text:upper()
        Btn.TextColor3 = customColor and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 10
        
        local BCorner = Instance.new("UICorner", Btn)
        BCorner.CornerRadius = UDim.new(0, 4)

        -- Hover Animation
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.7, TextSize = 11}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, TextSize = 10}):Play()
        end)

        Btn.MouseButton1Click:Connect(cb)
        return Btn
    end
    
    function Panel:Toggle()
        if MainFrame.Visible then
            -- Animação de Fechar
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.fromOffset(210, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            MainFrame.Visible = false
        else
            -- Animação de Abrir
            MainFrame.Size = UDim2.fromOffset(210, 0)
            MainFrame.BackgroundTransparency = 1
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = config.Size or UDim2.fromOffset(210, 260), BackgroundTransparency = 0.15}):Play()
        end
    end

    return Panel
end

--// CONSTRUÇÃO DA JANELA PRINCIPAL
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:Window(config)
    local WindowTable = {
        CurrentTab = nil,
        Tabs = {}
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Dobe_ModernUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui") -- Melhor para scripts
    Library.ScreenGui = ScreenGui

    -- Container Principal (O Vidro)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(580, 360)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BackgroundTransparency = 0.15 -- Efeito transparente moderno
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false
    Main.Parent = ScreenGui

    -- Arredondamento e Borda de Luz
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.85 -- Borda quase invisível, estilo luxo
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Dragging Suave (Melhorado)
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Sidebar (Menu Lateral)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 10)

    -- Divisor sutil entre Sidebar e Conteúdo
    local Separator = Instance.new("Frame", Sidebar)
    Separator.Size = UDim2.new(0, 1, 0.9, 0)
    Separator.Position = UDim2.new(1, 0, 0.05, 0)
    Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Separator.BackgroundTransparency = 0.9
    Separator.BorderSizePixel = 0

    -- Título Moderno (Upper Case + Bold)
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Text = (config.Title or "DobeiOS"):upper()
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 13
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.fromOffset(0, 5)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 3

    -- Container de Abas
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -10, 1, -65)
    TabContainer.Position = UDim2.fromOffset(5, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 3)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Container de Páginas
    local PageContainer = Instance.new("Frame", Main)
    PageContainer.Name = "Pages"
    PageContainer.Size = UDim2.new(1, -175, 1, -20)
    PageContainer.Position = UDim2.fromOffset(170, 10)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ClipsDescendants = true

    -- Animação de Entrada Profissional
    Main.Size = UDim2.fromOffset(500, 300) -- Começa menor
    Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(580, 360),
        BackgroundTransparency = 0.15
    }):Play()

    --// Função AddTab Interna
    function WindowTable:AddTab(name)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 10
        TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
        TabBtn.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner", TabBtn)
        TabCorner.CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(140, 140, 140), BackgroundTransparency = 1}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9}):Play()
        end)

        -- Ativa a primeira aba automaticamente
        if #TabContainer:GetChildren() == 1 then -- Contando o UIListLayout
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundTransparency = 0.9
        end

        local TabMethods = {}
        -- Aqui você adicionaria métodos como TabMethods:AddButton, AddToggle, etc.
        return TabMethods
    end

    return WindowTable
end

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
    
    local flag = options.Flag or (parent:FindFirstChild("TextLabel") and parent.TextLabel.Text) or (parent:IsA("TextButton") and parent.Text) or "Unknown"
    
    if not Library.Flags then Library.Flags = {Toggles = {}, Binds = {}, Colors = {}} end
    if not Library.Flags.Binds then Library.Flags.Binds = {} end

    -- 1. KEYBIND (Modern B&W)
    local KeyBtn 
    if options.Keybind ~= nil then
        local binding = false
        local blockKeyUntilRelease = nil

        KeyBtn = Instance.new("TextButton", parent)
        KeyBtn.Name = "KeybindElement"
        KeyBtn.AutomaticSize = Enum.AutomaticSize.XY
        KeyBtn.Size = UDim2.fromOffset(0, 18)
        KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
        KeyBtn.Position = UDim2.new(1, -10, 0.5, 0)
        KeyBtn.ZIndex = parent.ZIndex + 1 
        KeyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeyBtn.BackgroundTransparency = 0.9 -- Quase invisível por padrão
        KeyBtn.BorderSizePixel = 0
        
        local Corner = Instance.new("UICorner", KeyBtn)
        Corner.CornerRadius = UDim.new(0, 4)
        
        local Padding = Instance.new("UIPadding", KeyBtn)
        Padding.PaddingLeft = UDim.new(0, 6)
        Padding.PaddingRight = UDim.new(0, 6)

        local function getBindName(override)
            local key = override or (type(options.Keybind) == "table" and options.Keybind.Value or options.Keybind)
            if key == Enum.KeyCode.Unknown or key == nil then return "NONE" end
            return key.Name:upper()
        end

        KeyBtn.Text = getBindName()
        KeyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        KeyBtn.Font = Enum.Font.GothamBold
        KeyBtn.TextSize = 10

        local function resetVisual()
            binding = false
            KeyBtn.Text = getBindName()
            KeyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
            game:GetService("TweenService"):Create(KeyBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        end

        KeyBtn.MouseButton1Click:Connect(function()
            if binding then return end
            
            binding = true
            KeyBtn.Text = "..."
            KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            game:GetService("TweenService"):Create(KeyBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
            
            local conInput
            task.wait()
            
            conInput = game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local selectedKey = input.KeyCode
                    if selectedKey == Enum.KeyCode.Escape then selectedKey = Enum.KeyCode.Unknown end
                    
                    if type(options.Keybind) == "table" then options.Keybind.Value = selectedKey else options.Keybind = selectedKey end
                    
                    Library.Flags.Binds[flag] = selectedKey.Name
                    blockKeyUntilRelease = selectedKey

                    if Library.UpdateKeybindRender then Library:UpdateKeybindRender() end
                    conInput:Disconnect()
                    resetVisual()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    -- Reset se clicar fora ou botão do mouse
                    conInput:Disconnect()
                    resetVisual()
                end
            end)
        end)

        -- Trigger Logic
        game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
            if gp or binding then return end
            local checkKey = (type(options.Keybind) == "table" and options.Keybind.Value) or options.Keybind
            if checkKey == Enum.KeyCode.Unknown or input.KeyCode ~= checkKey then return end
            if blockKeyUntilRelease == checkKey then return end

            if callback then callback("Trigger") end
        end)

        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if blockKeyUntilRelease and input.KeyCode == blockKeyUntilRelease then blockKeyUntilRelease = nil end
        end)
    end

    -- 2. COLOR PICKER (Modern B&W)
    if options.Color then
        local ColorInd = Instance.new("TextButton", parent)
        ColorInd.Size = UDim2.fromOffset(16, 16)
        ColorInd.AnchorPoint = Vector2.new(1, 0.5)
        
        local function updateColorPos()
            local xOffset = -10
            if KeyBtn then xOffset = -20 - KeyBtn.AbsoluteSize.X end
            ColorInd.Position = UDim2.new(1, xOffset, 0.5, 0)
        end

        updateColorPos()
        if KeyBtn then KeyBtn:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColorPos) end

        ColorInd.BackgroundColor3 = options.Color
        ColorInd.Text = ""
        ColorInd.ZIndex = parent.ZIndex + 1
        
        local CICorner = Instance.new("UICorner", ColorInd)
        CICorner.CornerRadius = UDim.new(0, 4)
        
        local CIStroke = Instance.new("UIStroke", ColorInd)
        CIStroke.Color = Color3.fromRGB(255, 255, 255)
        CIStroke.Transparency = 0.8
        CIStroke.Thickness = 1

        ColorInd.MouseButton1Click:Connect(function()
            Library:OpenColorPicker(ColorInd.BackgroundColor3, function(newC)
                ColorInd.BackgroundColor3 = newC
                Library.Flags.Colors[flag] = {newC.R, newC.G, newC.B}
                if callback then callback("Color", newC) end
            end)
        end)
    end 
end


    local first = true
    function WindowTable:Tab(name, iconid)
    local TabFuncs = {}
    local TweenService = game:GetService("TweenService")
    
    -- Página de Conteúdo
    local Page = Instance.new("ScrollingFrame", PagesFolder)
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0 -- Scroll invisível para look moderno
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ZIndex = 10

    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 8)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    
    local PagePad = Instance.new("UIPadding", Page)
    PagePad.PaddingTop = UDim.new(0, 10)
    PagePad.PaddingLeft = UDim.new(0, 10)
    PagePad.PaddingRight = UDim.new(0, 10)
    PagePad.PaddingBottom = UDim.new(0, 10)

    -- Auto-ajuste do Canvas
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
    end)

    -- Botão da Tab na Sidebar
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Name = name .. "_TabBtn"
    Btn.Size = UDim2.new(0, 150, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 1 -- Invisível por padrão
    Btn.Text = name:upper()
    Btn.TextColor3 = Color3.fromRGB(130, 130, 130) -- Cinza "apagado"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.AutoButtonColor = false
    Btn.ZIndex = 11

    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 6)
    
    local BtnPadding = Instance.new("UIPadding", Btn)
    BtnPadding.PaddingLeft = UDim.new(0, 38) -- Espaço para o ícone

    -- Ícone da Tab
    local Icon = Instance.new("ImageLabel", Btn)
    Icon.Name = "Icon"
    Icon.Size = UDim2.fromOffset(16, 16)
    Icon.Position = UDim2.new(0, -28, 0.5, 0)
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconid or "rbxassetid://6031230167"
    Icon.ImageColor3 = Color3.fromRGB(130, 130, 130)
    Icon.ZIndex = 12

    local function Show()
        -- Resetar todas as outras abas
        for _, v in pairs(TabContainer:GetChildren()) do
            if v:IsA("TextButton") then
                TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(130, 130, 130)}):Play()
                if v:FindFirstChild("Icon") then
                    TweenService:Create(v.Icon, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(130, 130, 130)}):Play()
                end
            end
        end
        
        -- Esconder todas as páginas
        for _, v in pairs(PagesFolder:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        
        -- Ativar esta aba
        Page.Visible = true
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.9, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(Icon, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end

    Btn.MouseButton1Click:Connect(Show)

    -- Hover Effect
    Btn.MouseEnter:Connect(function()
        if not Page.Visible then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
        end
    end)
    Btn.MouseLeave:Connect(function()
        if not Page.Visible then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end)

    -- Ativar a primeira aba automaticamente
    if #PagesFolder:GetChildren() == 1 then
        Show()
    end

    -- Retornar os métodos da Tab (AddButton, AddToggle, etc)
    TabFuncs.Page = Page
    return TabFuncs
end

        --// ELEMENTOS DA UI DENTRO DA TAB

function TabFuncs:Section(text)
    local Sec = Instance.new("TextLabel", Page)
    Sec.Text = string.upper(text)
    Sec.Size = UDim2.new(1, 0, 0, 30)
    Sec.BackgroundTransparency = 1
    Sec.TextColor3 = Color3.fromRGB(100, 100, 100) -- Cinza sutil
    Sec.Font = Enum.Font.GothamBold
    Sec.TextSize = 10 -- Menor e elegante
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.ZIndex = 5
    
    -- Padding lateral para alinhar com os itens
    local SecPad = Instance.new("UIPadding", Sec)
    SecPad.PaddingLeft = UDim.new(0, 4)
end

function TabFuncs:Button(text, callback, options)
    local BtnFrame = Instance.new("TextButton", Page)
    BtnFrame.Name = text .. "_Btn"
    BtnFrame.Size = UDim2.new(1, 0, 0, 40)
    BtnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BtnFrame.BackgroundTransparency = 0.96 -- Quase invisível
    BtnFrame.Text = ""
    BtnFrame.AutoButtonColor = false
    BtnFrame.ZIndex = 5
    
    local Corner = Instance.new("UICorner", BtnFrame)
    Corner.CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke", BtnFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.9 -- Borda bem apagada inicialmente
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Lbl = Instance.new("TextLabel", BtnFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -20, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200) -- Texto cinza claro
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 6

    -- Animações Monochrome
    BtnFrame.MouseEnter:Connect(function()
        Library:Tween(Stroke, {Transparency = 0.6}, 0.2) -- Borda acende
        Library:Tween(Lbl, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2) -- Texto brilha
        Library:Tween(BtnFrame, {BackgroundTransparency = 0.92}, 0.2) -- Fundo levemente mais forte
    end)

    BtnFrame.MouseLeave:Connect(function()
        Library:Tween(Stroke, {Transparency = 0.9}, 0.2)
        Library:Tween(Lbl, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
        Library:Tween(BtnFrame, {BackgroundTransparency = 0.96}, 0.2)
    end)

    local function Activate()
        -- Feedback visual de clique (Flash branco)
        local Flash = Library:Tween(BtnFrame, {BackgroundTransparency = 0.8}, 0.1)
        Flash.Completed:Connect(function()
            Library:Tween(BtnFrame, {BackgroundTransparency = 0.92}, 0.1)
        end)
        
        if callback then callback() end
    end

    BtnFrame.MouseButton1Click:Connect(Activate)
    
    -- Suporte a Keybinds/Colors via AddExtras
    AddExtras(BtnFrame, options, function(mode, val)
        if mode == "Trigger" then Activate() end
    end)
    
    return BtnFrame
end

      function TabFuncs:Toggle(text, default, callback, options)
    local flag = (options and options.Flag) or text
    local toggled = default or false
    
    -- Cores do Tema Monochrome
    local ActiveColor = Color3.fromRGB(255, 255, 255)
    local InactiveColor = Color3.fromRGB(35, 35, 35)
    local BallActive = Color3.fromRGB(0, 0, 0) -- Bolinha preta no fundo branco (contraste)
    local BallInactive = Color3.fromRGB(150, 150, 150)

    if not Library.Flags then Library.Flags = { Toggles = {}, Binds = {}, Colors = {} } end
    Library.Flags.Toggles[flag] = toggled

    local TogFrame = Instance.new("TextButton", Page)
    TogFrame.Name = text .. "_Toggle"
    TogFrame.Size = UDim2.new(1, 0, 0, 40)
    TogFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TogFrame.BackgroundTransparency = 0.96
    TogFrame.Text = ""
    TogFrame.AutoButtonColor = false
    TogFrame.ZIndex = 5
    
    Instance.new("UICorner", TogFrame).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", TogFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.9
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Lbl = Instance.new("TextLabel", TogFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -70, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 6

    -- O "Corpo" do Switch
    local Switch = Instance.new("Frame", TogFrame)
    Switch.Size = UDim2.fromOffset(34, 18)
    Switch.AnchorPoint = Vector2.new(1, 0.5)
    Switch.Position = UDim2.new(1, -12, 0.5, 0)
    Switch.BackgroundColor3 = toggled and ActiveColor or InactiveColor
    Switch.ZIndex = 6
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    -- Stroke interno para o switch não sumir no fundo
    local SStroke = Instance.new("UIStroke", Switch)
    SStroke.Color = Color3.fromRGB(255, 255, 255)
    SStroke.Transparency = 0.8

    local Ball = Instance.new("Frame", Switch)
    Ball.Size = UDim2.fromOffset(12, 12)
    Ball.AnchorPoint = Vector2.new(0, 0.5)
    Ball.Position = toggled and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    Ball.BackgroundColor3 = toggled and BallActive or BallInactive
    Ball.ZIndex = 7
    Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

    -- Função para ajustar posição caso tenha Keybind/Color no AddExtras
    local function UpdateSwitchPosition()
        local extra = 0
        if options then
            if options.Keybind then extra = extra + 45 end
            if options.Color then extra = extra + 25 end
        end
        Switch.Position = UDim2.new(1, -12 - extra, 0.5, 0)
    end

    local function Swap(quiet)
        if not quiet then toggled = not toggled end
        Library.Flags.Toggles[flag] = toggled
        
        -- Animação Suave
        Library:Tween(Switch, {BackgroundColor3 = toggled and ActiveColor or InactiveColor}, 0.2)
        Library:Tween(Ball, {
            Position = toggled and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = toggled and BallActive or BallInactive
        }, 0.2)
        Library:Tween(Lbl, {TextColor3 = toggled and Color3.new(1,1,1) or Color3.fromRGB(180,180,180)}, 0.2)

        task.spawn(function()
            local success, err = pcall(function() callback(toggled) end)
            if not success then warn("Toggle Error: " .. err) end
        end)
    end

    -- Mouse Interaction
    TogFrame.MouseEnter:Connect(function()
        Library:Tween(Stroke, {Transparency = 0.7}, 0.2)
    end)
    TogFrame.MouseLeave:Connect(function()
        Library:Tween(Stroke, {Transparency = 0.9}, 0.2)
    end)

    TogFrame.MouseButton1Click:Connect(function() Swap(false) end)

    AddExtras(TogFrame, options, function(mode, val)
        if mode == "Trigger" then Swap(false) end
    end)
    
    UpdateSwitchPosition()

    if default then 
        task.spawn(function() pcall(function() callback(true) end) end)
    end

    local ToggleMethods = {}
    function ToggleMethods:Set(bool)
        if toggled ~= bool then 
            toggled = bool 
            Swap(true) 
        end
    end

    if not Library.Elements[flag] then Library.Elements[flag] = {} end
    Library.Elements[flag] = ToggleMethods

    return ToggleMethods
end

function TabFuncs:Slider(text, min, max, default, callback, options)
    local flag = (options and options.Flag) or text
    local value = default or min
    local UIS = game:GetService("UserInputService")
    
    -- Cores Monochrome
    local BarColor = Color3.fromRGB(255, 255, 255)
    local BgBarColor = Color3.fromRGB(40, 40, 40)

    Library.Flags = Library.Flags or {}
    Library.Flags.Sliders = Library.Flags.Sliders or {}
    Library.Flags.Sliders[flag] = value

    local SliFrame = Instance.new("TextButton", Page)
    SliFrame.Name = text .. "_Slider"
    SliFrame.Size = UDim2.new(1, 0, 0, 48) -- Ligeiramente mais alto para conforto
    SliFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliFrame.BackgroundTransparency = 0.96
    SliFrame.Text = ""
    SliFrame.AutoButtonColor = false
    
    Instance.new("UICorner", SliFrame).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", SliFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.9
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Lbl = Instance.new("TextLabel", SliFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -60, 0, 20)
    Lbl.Position = UDim2.new(0, 12, 0, 8)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ValLbl = Instance.new("TextLabel", SliFrame)
    ValLbl.Text = tostring(value)
    ValLbl.Size = UDim2.new(0, 40, 0, 20)
    ValLbl.Position = UDim2.new(1, -52, 0, 8)
    ValLbl.BackgroundTransparency = 1
    ValLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextSize = 12
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right

    -- Barra de fundo (mais fina, 2px)
    local SliderBack = Instance.new("Frame", SliFrame)
    SliderBack.Size = UDim2.new(1, -24, 0, 2)
    SliderBack.Position = UDim2.new(0, 12, 1, -12)
    SliderBack.BackgroundColor3 = BgBarColor
    SliderBack.BorderSizePixel = 0
    Instance.new("UICorner", SliderBack)

    -- Barra de preenchimento
    local SliderFill = Instance.new("Frame", SliderBack)
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = BarColor
    SliderFill.BorderSizePixel = 0
    Instance.new("UICorner", SliderFill)

    -- Marcador (Ball)
    local Ball = Instance.new("Frame", SliderFill)
    Ball.AnchorPoint = Vector2.new(0.5, 0.5)
    Ball.Size = UDim2.fromOffset(10, 10)
    Ball.Position = UDim2.new(1, 0, 0.5, 0)
    Ball.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Ball.ZIndex = 10
    
    local BCorner = Instance.new("UICorner", Ball)
    BCorner.CornerRadius = UDim.new(1, 0)
    
    local BStroke = Instance.new("UIStroke", Ball)
    BStroke.Color = Color3.fromRGB(255, 255, 255)
    BStroke.Thickness = 1.5

    local dragging = false
    local function move(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(((max - min) * pos) + min)
        
        value = newValue
        Library.Flags.Sliders[flag] = newValue
        
        -- Interpolação suave do tamanho
        TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.OutQuad), {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        ValLbl.Text = tostring(newValue)
        callback(newValue)
    end

    -- Efeitos de Hover
    SliFrame.MouseEnter:Connect(function()
        Library:Tween(Stroke, {Transparency = 0.7}, 0.2)
        Library:Tween(Lbl, {TextColor3 = Color3.new(1, 1, 1)}, 0.2)
    end)
    
    SliFrame.MouseLeave:Connect(function()
        if not dragging then
            Library:Tween(Stroke, {Transparency = 0.9}, 0.2)
            Library:Tween(Lbl, {TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.2)
        end
    end)

    SliFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Library:Tween(BStroke, {Thickness = 2.5}, 0.1) -- Feedback de grab
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
            Library:Tween(BStroke, {Thickness = 1.5}, 0.1)
            Library:Tween(Stroke, {Transparency = 0.9}, 0.2)
        end
    end)

    local SliderMethods = {}
    function SliderMethods:Set(val)
        local clamped = math.clamp(val, min, max)
        value = clamped
        ValLbl.Text = tostring(clamped)
        local pos = (clamped - min) / (max - min)
        Library:Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.2)
        callback(clamped)
    end

    return SliderMethods
end

--// NOVO: ADICIONANDO A FUNÇÃO DE INPUT PARA MOEDAS (CONFORME PEDIDO)
function TabFuncs:Input(text, placeholder, callback)
    local InputFrame = Instance.new("Frame", Page)
    InputFrame.Name = text .. "_Input"
    InputFrame.Size = UDim2.new(1, 0, 0, 42)
    InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputFrame.BackgroundTransparency = 0.96
    InputFrame.ZIndex = 5
    
    local Corner = Instance.new("UICorner", InputFrame)
    Corner.CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke", InputFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.9
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Lbl = Instance.new("TextLabel", InputFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -140, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 6

    local Box = Instance.new("TextBox", InputFrame)
    Box.Size = UDim2.new(0, 100, 0, 24)
    Box.Position = UDim2.new(1, -12, 0.5, 0)
    Box.AnchorPoint = Vector2.new(1, 0.5)
    Box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Box.BackgroundTransparency = 0.5
    Box.Text = ""
    Box.PlaceholderText = placeholder or "Enter text..."
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 11
    Box.ClearTextOnFocus = false
    Box.ClipsDescendants = true
    Box.ZIndex = 6
    
    local BoxCorner = Instance.new("UICorner", Box)
    BoxCorner.CornerRadius = UDim.new(0, 4)
    
    local BoxStroke = Instance.new("UIStroke", Box)
    BoxStroke.Color = Color3.fromRGB(255, 255, 255)
    BoxStroke.Transparency = 0.8

    -- Animações de Foco
    Box.Focused:Connect(function()
        Library:Tween(BoxStroke, {Transparency = 0.4, Color = Color3.fromRGB(255, 255, 255)}, 0.2)
        Library:Tween(Box, {Size = UDim2.new(0, 120, 0, 24)}, 0.2) -- Expande levemente ao digitar
    end)

    Box.FocusLost:Connect(function(enterPressed)
        Library:Tween(BoxStroke, {Transparency = 0.8, Color = Color3.fromRGB(255, 255, 255)}, 0.2)
        Library:Tween(Box, {Size = UDim2.new(0, 100, 0, 24)}, 0.2)
        
        if callback then
            callback(Box.Text)
        end
    end)

    -- Efeito de Hover no Card
    InputFrame.MouseEnter:Connect(function()
        Library:Tween(Stroke, {Transparency = 0.7}, 0.2)
        Library:Tween(Lbl, {TextColor3 = Color3.new(1, 1, 1)}, 0.2)
    end)

    InputFrame.MouseLeave:Connect(function()
        Library:Tween(Stroke, {Transparency = 0.9}, 0.2)
        Library:Tween(Lbl, {TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.2)
    end)

    local InputMethods = {}
    function InputMethods:Set(val)
        Box.Text = tostring(val)
        if callback then callback(val) end
    end
    
    return InputMethods
end

       function TabFuncs:Dropdown(text, list, callback)
    local list = list or {}
    local dropped = false
    local currentSelected = list[1] or "None"
    local DropFuncs = {}
    
    -- Frame Principal no Card
    local DropMain = Instance.new("Frame", Page)
    DropMain.Name = text .. "_Dropdown"
    DropMain.Size = UDim2.new(1, 0, 0, 42)
    DropMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropMain.BackgroundTransparency = 0.96
    DropMain.ZIndex = 5
    
    local Corner = Instance.new("UICorner", DropMain)
    Corner.CornerRadius = UDim.new(0, 6)
    
    local MainStroke = Instance.new("UIStroke", DropMain)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.9
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local SelectedLabel = Instance.new("TextLabel", DropMain)
    SelectedLabel.Text = text .. ": " .. currentSelected:upper()
    SelectedLabel.Size = UDim2.new(1, -50, 1, 0)
    SelectedLabel.Position = UDim2.new(0, 12, 0, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    SelectedLabel.Font = Enum.Font.GothamMedium
    SelectedLabel.TextSize = 12
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.ZIndex = 6

    local OpenBtn = Instance.new("TextButton", DropMain)
    OpenBtn.Size = UDim2.new(1, 0, 1, 0)
    OpenBtn.BackgroundTransparency = 1
    OpenBtn.Text = ""
    OpenBtn.ZIndex = 10

    local Arrow = Instance.new("ImageLabel", DropMain)
    Arrow.Size = UDim2.fromOffset(14, 14)
    Arrow.Position = UDim2.new(1, -12, 0.5, 0)
    Arrow.AnchorPoint = Vector2.new(1, 0.5)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://6034818372"
    Arrow.ImageColor3 = Color3.fromRGB(150, 150, 150)
    Arrow.ZIndex = 7

    -- O Menu Suspenso (Fora do Page, dentro do ScreenGui)
    local DropList = Instance.new("ScrollingFrame")
    DropList.Name = "DropList_" .. text
    DropList.Parent = Library.ScreenGui
    DropList.Size = UDim2.fromOffset(180, 0)
    DropList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    DropList.BackgroundTransparency = 0.05
    DropList.Visible = false
    DropList.ScrollBarThickness = 0
    DropList.ZIndex = 5000 
    
    Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 8)
    local ListStroke = Instance.new("UIStroke", DropList)
    ListStroke.Color = Color3.fromRGB(255, 255, 255)
    ListStroke.Transparency = 0.8
    
    local ListLayout = Instance.new("UIListLayout", DropList)
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local ListPadding = Instance.new("UIPadding", DropList)
    ListPadding.PaddingTop = UDim.new(0, 6)
    ListPadding.PaddingBottom = UDim.new(0, 6)

    -- Função para atualizar posição
    local function UpdateListPosition()
        DropList.Position = UDim2.fromOffset(
            DropMain.AbsolutePosition.X, 
            DropMain.AbsolutePosition.Y + DropMain.AbsoluteSize.Y + 5
        )
        DropList.Size = UDim2.fromOffset(DropMain.AbsoluteSize.X, DropList.Size.Y.Offset)
    end

    -- Função de Toggle
    local function Toggle(state)
        dropped = state
        if dropped then
            UpdateListPosition()
            DropList.Visible = true
            local targetHeight = math.min(ListLayout.AbsoluteContentSize.Y + 15, 200)
            Library:Tween(DropList, {Size = UDim2.new(0, DropMain.AbsoluteSize.X, 0, targetHeight)}, 0.2)
            Library:Tween(Arrow, {Rotation = 180}, 0.2)
        else
            Library:Tween(DropList, {Size = UDim2.new(0, DropMain.AbsoluteSize.X, 0, 0)}, 0.2)
            Library:Tween(Arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function() if not dropped then DropList.Visible = false end end)
        end
    end

    -- Criar Opções
    local function CreateOption(v)
        local Option = Instance.new("TextButton", DropList)
        Option.Size = UDim2.new(0.92, 0, 0, 32)
        Option.BackgroundTransparency = 1
        Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Option.Text = tostring(v):upper()
        Option.TextColor3 = Color3.fromRGB(150, 150, 150)
        Option.Font = Enum.Font.GothamMedium
        Option.TextSize = 10
        Option.TextXAlignment = Enum.TextXAlignment.Left
        Option.ZIndex = 5010
        Option.AutoButtonColor = false
        
        local OptCorner = Instance.new("UICorner", Option)
        OptCorner.CornerRadius = UDim.new(0, 6)
        local OptPad = Instance.new("UIPadding", Option)
        OptPad.PaddingLeft = UDim.new(0, 10)

        Option.MouseEnter:Connect(function()
            Library:Tween(Option, {BackgroundTransparency = 0.9, TextColor3 = Color3.new(1, 1, 1)}, 0.2)
        end)
        Option.MouseLeave:Connect(function()
            Library:Tween(Option, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
        end)

        Option.MouseButton1Click:Connect(function()
            currentSelected = v
            SelectedLabel.Text = text .. ": " .. tostring(v):upper()
            callback(v)
            Toggle(false)
        end)
    end

    -- Inicializa
    for _, v in pairs(list) do CreateOption(v) end
    OpenBtn.MouseButton1Click:Connect(function() Toggle(not dropped) end)

    -- Refresh
    function DropFuncs:Refresh(newList)
        for _, child in pairs(DropList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, v in pairs(newList) do CreateOption(v) end
        if dropped then
            local targetHeight = math.min(ListLayout.AbsoluteContentSize.Y + 15, 200)
            Library:Tween(DropList, {Size = UDim2.new(0, DropMain.AbsoluteSize.X, 0, targetHeight)}, 0.2)
        end
    end

    -- Detectar clique fora
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropped then
            task.wait(0.05)
            local pos = UserInputService:GetMouseLocation()
            local lp, ls = DropList.AbsolutePosition, DropList.AbsoluteSize
            local bp, bs = DropMain.AbsolutePosition, DropMain.AbsoluteSize

            -- Ajuste fino para a detecção de área
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

        
        ---// SERVER BROWSER TAB (Opcional)
if config.ServerTab and name == "Servidores" then
    TabFuncs:Section("Navegador de Instâncias")
    
    local Status = Instance.new("TextLabel", Page)
    Status.Text = "STATUS: AGUARDANDO..."
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(150, 150, 150)
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 10
    Status.ZIndex = 5

    local Refresh = Instance.new("TextButton", Page)
    Refresh.Name = "RefreshBtn"
    Refresh.Text = "ATUALIZAR LISTA"
    Refresh.Size = UDim2.new(1, 0, 0, 32)
    Refresh.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Refresh.BackgroundTransparency = 0.95
    Refresh.TextColor3 = Color3.fromRGB(255, 255, 255)
    Refresh.Font = Enum.Font.GothamBold
    Refresh.TextSize = 11
    Refresh.ZIndex = 5
    
    local RefCorner = Instance.new("UICorner", Refresh)
    RefCorner.CornerRadius = UDim.new(0, 6)
    local RefStroke = Instance.new("UIStroke", Refresh)
    RefStroke.Color = Color3.fromRGB(255, 255, 255)
    RefStroke.Transparency = 0.8

    local function LoadServers()
        Status.Text = "BUSCANDO SERVIDORES..."
        Status.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        -- Limpa antigos
        for _, v in pairs(Page:GetChildren()) do
            if v.Name == "ServerCard" then v:Destroy() end
        end

        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=50"
        local success, result = pcall(function() return game:HttpGet(url) end)

        if not success then
            Status.Text = "ERRO NA CONEXÃO"
            Status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end

        local data = game:GetService("HttpService"):JSONDecode(result).data
        Status.Text = "ENCONTRADOS: " .. #data
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)

        for _, s in pairs(data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                local Card = Instance.new("Frame", Page)
                Card.Name = "ServerCard"
                Card.Size = UDim2.new(1, 0, 0, 50)
                Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Card.BackgroundTransparency = 0.98
                Card.ZIndex = 5
                
                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
                local CStroke = Instance.new("UIStroke", Card)
                CStroke.Color = Color3.fromRGB(255, 255, 255)
                CStroke.Transparency = 0.92

                local Info = Instance.new("TextLabel", Card)
                Info.Text = string.format("%02d/%02d PLAYERS\nPING: %s MS", s.playing, s.maxPlayers, s.ping or "??")
                Info.Size = UDim2.new(1, -90, 1, 0)
                Info.Position = UDim2.new(0, 12, 0, 0)
                Info.BackgroundTransparency = 1
                Info.TextColor3 = Color3.fromRGB(160, 160, 160)
                Info.Font = Enum.Font.GothamMedium
                Info.TextSize = 11
                Info.TextXAlignment = Enum.TextXAlignment.Left
                Info.ZIndex = 6

                local Join = Instance.new("TextButton", Card)
                Join.Text = "ENTRAR"
                Join.Size = UDim2.new(0, 70, 0, 26)
                Join.Position = UDim2.new(1, -12, 0.5, 0)
                Join.AnchorPoint = Vector2.new(1, 0.5)
                Join.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Join.BackgroundTransparency = 0.1 -- Botão mais visível
                Join.TextColor3 = Color3.fromRGB(0, 0, 0) -- Texto preto para contraste no branco
                Join.Font = Enum.Font.GothamBold
                Join.TextSize = 10
                Join.ZIndex = 6
                Instance.new("UICorner", Join).CornerRadius = UDim.new(0, 4)

                Join.MouseButton1Click:Connect(function()
                    Join.Text = "..."
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, game.Players.LocalPlayer)
                end)
                
                -- Hover no Card
                Card.MouseEnter:Connect(function()
                    Library:Tween(CStroke, {Transparency = 0.7}, 0.2)
                    Library:Tween(Card, {BackgroundTransparency = 0.95}, 0.2)
                end)
                Card.MouseLeave:Connect(function()
                    Library:Tween(CStroke, {Transparency = 0.92}, 0.2)
                    Library:Tween(Card, {BackgroundTransparency = 0.98}, 0.2)
                end)
            end
        end
    end
    
    Refresh.MouseButton1Click:Connect(LoadServers)
end

    if config.ServerTab then WindowTable:Tab("Servidores", "rbxassetid://9692125126") end
--// Toggle Flutuante (Botão Redondo Estilo Monochrome)
local ToggleUI = Instance.new("TextButton", ScreenGui)
ToggleUI.Name = "FloatingToggle"
ToggleUI.Size = UDim2.fromOffset(48, 48)
ToggleUI.Position = UDim2.new(0, 30, 0.5, -24)
ToggleUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Fundo escuro
ToggleUI.BackgroundTransparency = 0.2 -- Efeito de vidro
ToggleUI.Text = "" 
ToggleUI.ZIndex = 10000 -- Garantir que fique acima de tudo
    
Instance.new("UICorner", ToggleUI).CornerRadius = UDim.new(1, 0)
    
local TStroke = Instance.new("UIStroke", ToggleUI)
TStroke.Color = Color3.fromRGB(255, 255, 255)
TStroke.Thickness = 1.5
TStroke.Transparency = 0.8 -- Começa discreto

-- Adicionando a Imagem/Logo
local Logo = Instance.new("ImageLabel", ToggleUI)
Logo.Size = UDim2.fromScale(0.6, 0.6) -- Um pouco menor para elegância
Logo.Position = UDim2.fromScale(0.5, 0.5)
Logo.AnchorPoint = Vector2.new(0.5, 0.5)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://109406051515132"
Logo.ImageColor3 = Color3.fromRGB(255, 255, 255) -- Logo branca
Logo.ZIndex = 10001

-- Animação de Hover
ToggleUI.MouseEnter:Connect(function()
    Library:Tween(TStroke, {Transparency = 0.4}, 0.2)
    Library:Tween(ToggleUI, {BackgroundTransparency = 0.1}, 0.2)
end)
ToggleUI.MouseLeave:Connect(function()
    Library:Tween(TStroke, {Transparency = 0.8}, 0.2)
    Library:Tween(ToggleUI, {BackgroundTransparency = 0.2}, 0.2)
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
        if delta.Magnitude > 7 then -- Sensibilidade de movimento
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

-- Função auxiliar para alternar o menu
local function ToggleMenu()
    UIOn = not UIOn
    Main.Visible = UIOn
    
    -- Feedback Visual no Toggle
    local targetTrans = UIOn and 0.2 or 0.8
    Library:Tween(TStroke, {Transparency = targetTrans}, 0.2)
    
    -- Animação de escala rápida
    ToggleUI:TweenSize(UDim2.fromOffset(42, 42), "Out", "Quad", 0.05, true)
    task.wait(0.05)
    ToggleUI:TweenSize(UDim2.fromOffset(48, 48), "Out", "Quad", 0.1, true)
end

ToggleUI.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        if not hasMoved then
            ToggleMenu()
        end
    end
end)

-- Atalhos de teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    -- RightShift ou tecla customizada na Library
    if input.KeyCode == Enum.KeyCode.RightShift or (Library.ToggleKey and input.KeyCode == Library.ToggleKey) then
        ToggleMenu()
    end
end)

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
