local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}
Library.ScreenGui = nil
Library.Flags = { Toggles = {}, Binds = {}, Colors = {}, Sliders = {} }
Library.Elements = {} 
Library.ToggleKey = Enum.KeyCode.RightControl

--// DETECÇÃO DE EXECUTOR E PROTEÇÃO
local function GetGuiParent()
    if RunService:IsStudio() then
        return LocalPlayer:WaitForChild("PlayerGui")
    else
        local success, result = pcall(function() return CoreGui end)
        if success then return result else return LocalPlayer:WaitForChild("PlayerGui") end
    end
end

--// LIMPEZA ANTIGA
for _, v in pairs(GetGuiParent():GetChildren()) do
    if v.Name == "Dobe_ModernUI" or v.Name == "ModernNotifications" then v:Destroy() end
end

--// TEMA (iOS Dark Refined)
local Theme = {
    Background = Color3.fromRGB(25, 25, 28),
    Sidebar    = Color3.fromRGB(32, 32, 35),
    ItemBG     = Color3.fromRGB(42, 42, 45),
    ItemStroke = Color3.fromRGB(70, 70, 75),
    Text       = Color3.fromRGB(255, 255, 255),
    SubText    = Color3.fromRGB(150, 150, 155),
    Accent     = Color3.fromRGB(10, 132, 255), 
    Green      = Color3.fromRGB(50, 215, 75),
    Red        = Color3.fromRGB(255, 69, 58)
}

--// FUNÇÃO TWEEN AUXILIAR
function Library:Tween(obj, props, time)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

--// NOTIFICATION SYSTEM
local NotificationService = {}
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "ModernNotifications"
NotifGui.ResetOnSpawn = false
NotifGui.DisplayOrder = 999
NotifGui.Parent = GetGuiParent()

local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "NotificationHolder"
NotifHolder.Size = UDim2.new(1, 0, 0, 0)
NotifHolder.Position = UDim2.new(0, 0, 0, 20)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = NotifGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Parent = NotifHolder

function NotificationService:Create(id, text, duration)
    -- Se id for string, trata como ID único, senão é apenas texto
    local msg = text or id
    local time = duration or 3
    
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(0, 34) 
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = NotifHolder

    local c = Instance.new("UICorner", f)
    c.CornerRadius = UDim.new(0, 6)

    local s = Instance.new("UIStroke", f)
    s.Thickness = 1
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.8 
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = msg:upper()
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextTransparency = 1
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.Parent = f
    
    local timerBar = Instance.new("Frame", f)
    timerBar.Size = UDim2.new(1, 0, 0, 1)
    timerBar.Position = UDim2.new(0, 0, 1, -1)
    timerBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    timerBar.BackgroundTransparency = 0.4
    timerBar.BorderSizePixel = 0

    TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(400, 34)}):Play()
    TweenService:Create(l, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    TweenService:Create(timerBar, TweenInfo.new(time, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 1)}):Play()

    task.delay(time, function()
        if f then
            TweenService:Create(l, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 1}):Play()
            local out = TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1})
            out:Play()
            out.Completed:Connect(function()
                f:Destroy()
            end)
        end
    end)
end

function NotificationService:Remove(id)
    -- Função placeholder para compatibilidade
end

--// ADD EXTRAS (Keybinds & ColorPickers)
local function AddExtras(parent, options, callback)
    if not options then return end
    
    local flag = options.Flag or (parent:FindFirstChild("TextLabel") and parent.TextLabel.Text) or (parent:IsA("TextButton") and parent.Text) or "Unknown"
    
    if not Library.Flags then Library.Flags = {Toggles = {}, Binds = {}, Colors = {}, Sliders = {}} end
    if not Library.Flags.Binds then Library.Flags.Binds = {} end

    -- 1. KEYBIND (Estilo Badge iOS)
    local KeyBtn 
    if options.Keybind ~= nil then
        local binding = false
        local blockKeyUntilRelease = nil

        KeyBtn = Instance.new("TextButton", parent)
        KeyBtn.Name = "KeybindBadge"
        KeyBtn.AutomaticSize = Enum.AutomaticSize.XY
        KeyBtn.Size = UDim2.fromOffset(0, 20)
        KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
        KeyBtn.Position = UDim2.new(1, -12, 0.5, 0)
        KeyBtn.ZIndex = parent.ZIndex + 1 
        KeyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeyBtn.BackgroundTransparency = 0.94 -- Glass sutil
        KeyBtn.Text = ""
        KeyBtn.AutoButtonColor = false
        
        local Corner = Instance.new("UICorner", KeyBtn)
        Corner.CornerRadius = UDim.new(0, 6)
        
        local Stroke = Instance.new("UIStroke", KeyBtn)
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Transparency = 0.9
        Stroke.Thickness = 1

        local Padding = Instance.new("UIPadding", KeyBtn)
        Padding.PaddingLeft = UDim.new(0, 8)
        Padding.PaddingRight = UDim.new(0, 8)

        local Lbl = Instance.new("TextLabel", KeyBtn)
        Lbl.Size = UDim2.fromScale(1, 1)
        Lbl.BackgroundTransparency = 1
        Lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
        Lbl.Font = Enum.Font.GothamMedium
        Lbl.TextSize = 11

        local function getBindName(override)
            local key = override or (type(options.Keybind) == "table" and options.Keybind.Value or options.Keybind)
            if key == Enum.KeyCode.Unknown or key == nil then return "NONE" end
            return key.Name:upper()
        end

        Lbl.Text = getBindName()

        local function resetVisual()
            binding = false
            Lbl.Text = getBindName()
            Library:Tween(Lbl, {TextColor3 = Color3.fromRGB(160, 160, 160)}, 0.2)
            Library:Tween(KeyBtn, {BackgroundTransparency = 0.94, BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.2)
        end

        KeyBtn.MouseButton1Click:Connect(function()
            if binding then return end
            
            binding = true
            Lbl.Text = "..."
            Library:Tween(Lbl, {TextColor3 = Color3.new(1,1,1)}, 0.2)
            Library:Tween(KeyBtn, {BackgroundTransparency = 0.85, BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.2)
            
            local conInput
            task.wait()
            
            conInput = game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local selectedKey = input.KeyCode
                    if selectedKey == Enum.KeyCode.Escape then selectedKey = Enum.KeyCode.Unknown end
                    
                    if type(options.Keybind) == "table" then options.Keybind.Value = selectedKey else options.Keybind = selectedKey end
                    
                    Library.Flags.Binds[flag] = selectedKey.Name
                    blockKeyUntilRelease = selectedKey

                    conInput:Disconnect()
                    resetVisual()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
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

    -- 2. COLOR PICKER (Indicador Circular iOS)
    if options.Color then
        local ColorInd = Instance.new("TextButton", parent)
        ColorInd.Name = "ColorIndicator"
        ColorInd.Size = UDim2.fromOffset(20, 20) -- Ligeiramente maior
        ColorInd.AnchorPoint = Vector2.new(1, 0.5)
        
        local function updateColorPos()
            local xOffset = -12
            if KeyBtn then 
                xOffset = -22 - KeyBtn.AbsoluteSize.X 
            end
            ColorInd.Position = UDim2.new(1, xOffset, 0.5, 0)
        end

        updateColorPos()
        if KeyBtn then KeyBtn:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColorPos) end

        ColorInd.BackgroundColor3 = options.Color
        ColorInd.Text = ""
        ColorInd.ZIndex = parent.ZIndex + 1
        
        local CICorner = Instance.new("UICorner", ColorInd)
        CICorner.CornerRadius = UDim.new(1, 0) -- Circular como no iOS Settings
        
        local CIStroke = Instance.new("UIStroke", ColorInd)
        CIStroke.Color = Color3.fromRGB(255, 255, 255)
        CIStroke.Transparency = 0.8
        CIStroke.Thickness = 1.5

        ColorInd.MouseButton1Click:Connect(function()
            Library:OpenColorPicker(ColorInd.BackgroundColor3, function(newC)
                ColorInd.BackgroundColor3 = newC
                Library.Flags.Colors[flag] = {newC.R, newC.G, newC.B}
                if callback then callback("Color", newC) end
            end)
        end)
    end 
end

--// COLOR PICKER WINDOW
function Library:OpenColorPicker(defaultColor, callback)
    if Library.ScreenGui:FindFirstChild("ColorPickerOverlay") then
        Library.ScreenGui.ColorPickerOverlay:Destroy()
    end

    local h, s, v = Color3.toHSV(defaultColor)
    local selectedColor = defaultColor
    
    -- Overlay de Fundo (Blur e Escurecimento)
    local Overlay = Instance.new("TextButton") 
    Overlay.Name = "ColorPickerOverlay"
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.new(0,0,0)
    Overlay.BackgroundTransparency = 1
    Overlay.AutoButtonColor = false
    Overlay.Text = ""
    Overlay.ZIndex = 5000
    Overlay.Parent = Library.ScreenGui

    local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    Blur.Size = 0
    Library:Tween(Blur, {Size = 15}, 0.4)

    -- Frame Principal (Glass Style iOS)
    local MainFrame = Instance.new("Frame", Overlay)
    MainFrame.Size = UDim2.fromOffset(280, 360) -- Aumentado para caber o grid
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.fromScale(0.5, 0.6) -- Começa mais baixo para o efeito de subida
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.ZIndex = 5001
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 20) -- Cantos bem arredondados iOS

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.8

    -- Título
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "Color Picker"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 14
    Title.ZIndex = 5002

    -- Visualização da Cor Selecionada (Círculo)
    local ColorPreview = Instance.new("Frame", MainFrame)
    ColorPreview.Size = UDim2.fromOffset(60, 60)
    ColorPreview.Position = UDim2.new(0.5, 0, 0, 60)
    ColorPreview.AnchorPoint = Vector2.new(0.5, 0)
    ColorPreview.BackgroundColor3 = defaultColor
    ColorPreview.ZIndex = 5002
    Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(1, 0)
    
    local PreviewStroke = Instance.new("UIStroke", ColorPreview)
    PreviewStroke.Thickness = 3
    PreviewStroke.Color = Color3.fromRGB(255, 255, 255)
    PreviewStroke.Transparency = 0.9

    -- Botão Confirmar (Estilo Botão de Ação iOS)
    local ConfirmBtn = Instance.new("TextButton", MainFrame)
    ConfirmBtn.Text = "Confirm"
    ConfirmBtn.Size = UDim2.new(1, -40, 0, 40)
    ConfirmBtn.Position = UDim2.new(0, 20, 1, -20)
    ConfirmBtn.AnchorPoint = Vector2.new(0, 1)
    ConfirmBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmBtn.BackgroundTransparency = 0.1 -- Vidro sólido
    ConfirmBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ConfirmBtn.Font = Enum.Font.GothamBold
    ConfirmBtn.TextSize = 14
    ConfirmBtn.ZIndex = 5002
    Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 12)

    local function Close()
        Library:Tween(Blur, {Size = 0}, 0.3)
        Library:Tween(Overlay, {BackgroundTransparency = 1}, 0.3)
        Library:Tween(MainFrame, {Position = UDim2.fromScale(0.5, 0.7), BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        Overlay:Destroy()
        Blur:Destroy()
    end

    ConfirmBtn.MouseButton1Click:Connect(function()
        if callback then callback(selectedColor) end
        Close()
    end)

    -- Animação de Abertura
    Library:Tween(Overlay, {BackgroundTransparency = 0.5}, 0.4)
    Library:Tween(MainFrame, {Position = UDim2.fromScale(0.5, 0.5)}, 0.4, Enum.EasingStyle.Quart)

    -- Dica: Se quiser que ele feche ao clicar fora (no overlay)
    Overlay.MouseButton1Click:Connect(Close)
end


function Library:Window(config)
    local WindowTable = {
        CurrentTab = nil,
        Tabs = {},
        Elements = {} -- Armazenar elementos para busca
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Dobe_iOS_Glass"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = GetGuiParent()
    Library.ScreenGui = ScreenGui

    -- Background de Desfoque (Opcional: Se quiser simular blur real use um BlurEffect na Camera)
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(580, 360)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BackgroundTransparency = 0.15 -- Efeito Vidro Escuro iOS
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 14) -- Bordas mais arredondadas

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.8
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Sidebar (Glass mais claro)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Sidebar.BackgroundTransparency = 0.6
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

    -- Divisória vertical sutil
    local Sep = Instance.new("Frame", Sidebar)
    Sep.Size = UDim2.new(0, 1, 0.9, 0)
    Sep.Position = UDim2.new(1, 0, 0.05, 0)
    Sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Sep.BackgroundTransparency = 0.9
    Sep.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Sidebar)
    Title.Text = config.Title or "DobeiOS"
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.fromOffset(0, 10)
    Title.BackgroundTransparency = 1

    -- // BARRA DE PESQUISA ESTILO IOS //
    local SearchFrame = Instance.new("Frame", Sidebar)
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(1, -20, 0, 28)
    SearchFrame.Position = UDim2.fromOffset(10, 50)
    SearchFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchFrame.BackgroundTransparency = 0.9
    Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 8)
    
    local SearchIcon = Instance.new("ImageLabel", SearchFrame)
    SearchIcon.Size = UDim2.fromOffset(14, 14)
    SearchIcon.Position = UDim2.fromOffset(8, 7)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxassetid://6031154871" -- Ícone de lupa
    SearchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

    local SearchInput = Instance.new("TextBox", SearchFrame)
    SearchInput.Size = UDim2.new(1, -30, 1, 0)
    SearchInput.Position = UDim2.fromOffset(28, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Search"
    SearchInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    -- Tab Container (Ajustado para dar espaço à pesquisa)
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -10, 1, -95)
    TabContainer.Position = UDim2.fromOffset(5, 85)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 4)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Page Container
    local PageContainer = Instance.new("Frame", Main)
    PageContainer.Name = "Pages"
    PageContainer.Size = UDim2.new(1, -180, 1, -20)
    PageContainer.Position = UDim2.fromOffset(170, 10)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ClipsDescendants = true

    -- // LÓGICA DE PESQUISA //
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, tab in pairs(WindowTable.Tabs) do
            for _, element in pairs(tab.Elements) do
                -- 'element.Instance' deve ser o Frame/Button principal do Toggle, Slider, etc.
                -- 'element.Name' é o texto original
                if element.Name:lower():find(query) then
                    element.Instance.Visible = true
                else
                    element.Instance.Visible = false
                end
            end
        end
    end)

    -- Arraste e Animações de Entrada (Mantidos da sua lógica)
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Botão Flutuante (Floating Toggle)
    -- [Aqui você insere a lógica do FloatingToggle que você já tem, apenas ajuste a cor para 255,255,255 com Transparência 0.9 para o estilo Glass]
        local UIOn = true
    local ToggleUI = Instance.new("TextButton", ScreenGui)
    ToggleUI.Name = "FloatingToggle"
    ToggleUI.Size = UDim2.fromOffset(48, 48)
    ToggleUI.Position = UDim2.new(0, 30, 0.5, -24)
    ToggleUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
    ToggleUI.BackgroundTransparency = 0.2
    ToggleUI.Text = "" 
    ToggleUI.ZIndex = 10000 
        
    Instance.new("UICorner", ToggleUI).CornerRadius = UDim.new(1, 0)
        
    local TStroke = Instance.new("UIStroke", ToggleUI)
    TStroke.Color = Color3.fromRGB(255, 255, 255)
    TStroke.Thickness = 1.5
    TStroke.Transparency = 0.8 

    local Logo = Instance.new("ImageLabel", ToggleUI)
    Logo.Size = UDim2.fromScale(0.6, 0.6)
    Logo.Position = UDim2.fromScale(0.5, 0.5)
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://109406051515132"
    Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Logo.ZIndex = 10001

    ToggleUI.MouseEnter:Connect(function()
        Library:Tween(TStroke, {Transparency = 0.4}, 0.2)
        Library:Tween(ToggleUI, {BackgroundTransparency = 0.1}, 0.2)
    end)
    ToggleUI.MouseLeave:Connect(function()
        Library:Tween(TStroke, {Transparency = 0.8}, 0.2)
        Library:Tween(ToggleUI, {BackgroundTransparency = 0.2}, 0.2)
    end)

    local draggingToggle, dragStartToggle, startPosToggle, hasMovedToggle
    ToggleUI.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingToggle = true
            dragStartToggle = input.Position
            startPosToggle = ToggleUI.Position
            hasMovedToggle = false 
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartToggle
            if delta.Magnitude > 7 then hasMovedToggle = true end
            ToggleUI.Position = UDim2.new(startPosToggle.X.Scale, startPosToggle.X.Offset + delta.X, startPosToggle.Y.Scale, startPosToggle.Y.Offset + delta.Y)
        end
    end)

    local function ToggleMenu()
        UIOn = not UIOn
        Main.Visible = UIOn
        local targetTrans = UIOn and 0.2 or 0.8
        Library:Tween(TStroke, {Transparency = targetTrans}, 0.2)
    end

    ToggleUI.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingToggle = false
            if not hasMovedToggle then ToggleMenu() end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end 
        if input.KeyCode == Enum.KeyCode.RightShift or (Library.ToggleKey and input.KeyCode == Library.ToggleKey) then
            ToggleMenu()
        end
    end)


    --// TAB FUNCTION
    function WindowTable:Tab(name, iconid)
        local TabFuncs = {}
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name:upper()
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 10
        TabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
        TabBtn.AutoButtonColor = false
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end)
        
        Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 5)

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

        if #TabContainer:GetChildren() == 2 then -- UIList + 1 Btn
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundTransparency = 0.9
        end

        -- Elementos da Tab
        function TabFuncs:Section(text)
            local Sec = Instance.new("TextLabel", Page)
            Sec.Text = string.upper(text)
            Sec.Size = UDim2.new(1, 0, 0, 30)
            Sec.BackgroundTransparency = 1
            Sec.TextColor3 = Color3.fromRGB(100, 100, 100)
            Sec.Font = Enum.Font.GothamBold
            Sec.TextSize = 10
            Sec.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UIPadding", Sec).PaddingLeft = UDim.new(0, 4)
        end

        function TabFuncs:Button(text, callback, options)
            local BtnFrame = Instance.new("TextButton", Page)
            BtnFrame.Size = UDim2.new(1, 0, 0, 40)
            BtnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            BtnFrame.BackgroundTransparency = 0.96
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)
            
            local Stroke = Instance.new("UIStroke", BtnFrame)
            Stroke.Color = Color3.fromRGB(255, 255, 255)
            Stroke.Transparency = 0.9
            
            local Lbl = Instance.new("TextLabel", BtnFrame)
            Lbl.Text = text
            Lbl.Size = UDim2.new(1, -20, 1, 0)
            Lbl.Position = UDim2.new(0, 12, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local function Activate()
                local Flash = Library:Tween(BtnFrame, {BackgroundTransparency = 0.8}, 0.1)
                Flash.Completed:Connect(function() Library:Tween(BtnFrame, {BackgroundTransparency = 0.96}, 0.1) end)
                if callback then callback() end
            end

            BtnFrame.MouseEnter:Connect(function() Library:Tween(Stroke, {Transparency = 0.6}, 0.2); Library:Tween(Lbl, {TextColor3 = Color3.new(1,1,1)}, 0.2) end)
            BtnFrame.MouseLeave:Connect(function() Library:Tween(Stroke, {Transparency = 0.9}, 0.2); Library:Tween(Lbl, {TextColor3 = Color3.fromRGB(200,200,200)}, 0.2) end)
            BtnFrame.MouseButton1Click:Connect(Activate)
            
            AddExtras(BtnFrame, options, function(mode) if mode == "Trigger" then Activate() end end)
            return BtnFrame
        end

        function TabFuncs:Toggle(text, default, callback, options)
    local flag = (options and options.Flag) or text
    local toggled = default or false
    Library.Flags.Toggles[flag] = toggled

    -- Container Principal (Glass Style)
    local TogFrame = Instance.new("TextButton", Page)
    TogFrame.Name = "Toggle_" .. text
    TogFrame.Size = UDim2.new(1, -10, 0, 42)
    TogFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TogFrame.BackgroundTransparency = 0.94 -- Vidro translúcido
    TogFrame.Text = ""
    TogFrame.AutoButtonColor = false
    
    local Corner = Instance.new("UICorner", TogFrame)
    Corner.CornerRadius = UDim.new(0, 10) -- Bordas arredondadas iOS
    
    local Stroke = Instance.new("UIStroke", TogFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.85
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Label do Toggle
    local Lbl = Instance.new("TextLabel", TogFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -70, 1, 0)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- O Switch (Cápsula traseira)
    local Switch = Instance.new("Frame", TogFrame)
    Switch.Size = UDim2.fromOffset(36, 20)
    Switch.AnchorPoint = Vector2.new(1, 0.5)
    Switch.Position = UDim2.new(1, -12, 0.5, 0)
    Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
    Switch.BackgroundTransparency = toggled and 0 or 0.5 -- Leve transparência quando desligado
    
    local SwitchCorner = Instance.new("UICorner", Switch)
    SwitchCorner.CornerRadius = UDim.new(1, 0)

    -- A "Bola" do Switch (Knob)
    local Ball = Instance.new("Frame", Switch)
    Ball.Size = UDim2.fromOffset(16, 16)
    Ball.AnchorPoint = Vector2.new(0, 0.5)
    Ball.Position = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    Ball.BackgroundColor3 = toggled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    
    local BallCorner = Instance.new("UICorner", Ball)
    BallCorner.CornerRadius = UDim.new(1, 0)

    local function Swap(quiet)
        if not quiet then toggled = not toggled end
        Library.Flags.Toggles[flag] = toggled
        
        -- Cores e Posições (Interpretação iOS Glass)
        local targetSwitchCol = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
        local targetBallCol = toggled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        local targetBallPos = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local targetTextCol = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        Library:Tween(Switch, {BackgroundColor3 = targetSwitchCol, BackgroundTransparency = toggled and 0 or 0.5}, 0.25)
        Library:Tween(Ball, {Position = targetBallPos, BackgroundColor3 = targetBallCol}, 0.25)
        Library:Tween(Lbl, {TextColor3 = targetTextCol}, 0.25)
        
        if callback then 
            task.spawn(function() 
                local success, err = pcall(callback, toggled) 
                if not success then warn("Callback Error: " .. err) end
            end) 
        end
    end

    -- Eventos de Interação
    TogFrame.MouseEnter:Connect(function() 
        Library:Tween(Stroke, {Transparency = 0.6, Color = Color3.fromRGB(255, 255, 255)}, 0.2) 
    end)
    TogFrame.MouseLeave:Connect(function() 
        Library:Tween(Stroke, {Transparency = 0.85, Color = Color3.fromRGB(255, 255, 255)}, 0.2) 
    end)
    
    TogFrame.MouseButton1Click:Connect(function() Swap(false) end)

    -- Mantendo sua lógica de Extras e Métodos
    if typeof(AddExtras) == "function" then
        AddExtras(TogFrame, options, function(mode) if mode == "Trigger" then Swap(false) end end)
    end

    if default then Swap(true) end

    local Methods = {}
    function Methods:Set(val) 
        toggled = val
        Swap(true) 
    end
    
    Library.Elements[flag] = Methods
    return Methods
end

        function TabFuncs:Slider(text, min, max, default, callback, options)
    local flag = (options and options.Flag) or text
    local value = default or min
    Library.Flags.Sliders[flag] = value

    local SliFrame = Instance.new("TextButton", Page)
    SliFrame.Name = "Slider_" .. text
    SliFrame.Size = UDim2.new(1, -10, 0, 50) -- Ligeiramente mais alto para o estilo iOS
    SliFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliFrame.BackgroundTransparency = 0.93 -- Efeito Vidro
    SliFrame.Text = ""
    SliFrame.AutoButtonColor = false
    
    local Corner = Instance.new("UICorner", SliFrame)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", SliFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.85

    local Lbl = Instance.new("TextLabel", SliFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -60, 0, 20)
    Lbl.Position = UDim2.new(0, 15, 0, 10)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ValLbl = Instance.new("TextLabel", SliFrame)
    ValLbl.Text = tostring(value)
    ValLbl.Size = UDim2.new(0, 40, 0, 20)
    ValLbl.Position = UDim2.new(1, -15, 0, 10)
    ValLbl.AnchorPoint = Vector2.new(1, 0)
    ValLbl.BackgroundTransparency = 1
    ValLbl.TextColor3 = Color3.fromRGB(150, 150, 150) -- Valor em cinza suave
    ValLbl.Font = Enum.Font.GothamMedium
    ValLbl.TextSize = 13
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right

    -- Barra do Slider (Background)
    local SliderBack = Instance.new("Frame", SliFrame)
    SliderBack.Size = UDim2.new(1, -30, 0, 4) -- Barra um pouco mais grossa
    SliderBack.Position = UDim2.new(0, 15, 1, -12)
    SliderBack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderBack.BackgroundTransparency = 0.9 -- Quase invisível
    SliderBack.BorderSizePixel = 0
    Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(1, 0)

    -- Preenchimento (Fill)
    local SliderFill = Instance.new("Frame", SliderBack)
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFill.BackgroundTransparency = 0.2 -- Brilho suave no preenchimento
    SliderFill.BorderSizePixel = 0
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    -- Círculo de Arraste (iOS Knob)
    local Knob = Instance.new("Frame", SliderFill)
    Knob.Size = UDim2.fromOffset(12, 12)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(1, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local KnobStroke = Instance.new("UIStroke", Knob)
    KnobStroke.Color = Color3.fromRGB(0, 0, 0)
    KnobStroke.Transparency = 0.8

    local dragging = false
    local function move(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(((max - min) * pos) + min)
        value = newValue
        Library.Flags.Sliders[flag] = newValue
        
        -- Animação suave para o preenchimento
        Library:Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
        ValLbl.Text = tostring(newValue)
        if callback then callback(newValue) end
    end

    SliFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            move(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            move(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

        function TabFuncs:Input(text, placeholder, callback)
    local InpFrame = Instance.new("Frame", Page)
    InpFrame.Name = "Input_" .. text
    InpFrame.Size = UDim2.new(1, -10, 0, 42)
    InpFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InpFrame.BackgroundTransparency = 0.94
    
    local Corner = Instance.new("UICorner", InpFrame)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", InpFrame)
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.85

    local Lbl = Instance.new("TextLabel", InpFrame)
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -120, 1, 0)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Caixa de texto estilo iOS (Fundo escuro sutil)
    local Box = Instance.new("TextBox", InpFrame)
    Box.Size = UDim2.new(0, 100, 0, 26)
    Box.Position = UDim2.new(1, -12, 0.5, 0)
    Box.AnchorPoint = Vector2.new(1, 0.5)
    Box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Box.BackgroundTransparency = 0.7 -- Input mais "afundado"
    Box.Text = ""
    Box.PlaceholderText = placeholder or "Type..."
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.ClipsDescendants = true
    
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    local BoxStroke = Instance.new("UIStroke", Box)
    BoxStroke.Color = Color3.fromRGB(255, 255, 255)
    BoxStroke.Transparency = 0.9

    -- Efeito de Foco (Quando clica para digitar)
    Box.Focused:Connect(function()
        Library:Tween(BoxStroke, {Transparency = 0.5}, 0.3)
        Library:Tween(Box, {BackgroundTransparency = 0.5}, 0.3)
    end)
    
    Box.FocusLost:Connect(function()
        Library:Tween(BoxStroke, {Transparency = 0.9}, 0.3)
        Library:Tween(Box, {BackgroundTransparency = 0.7}, 0.3)
        if callback then callback(Box.Text) end
    end)
end
        -- ... (Dentro da função de criação da Tab)
function TabFuncs:Dropdown(text, list, callback)
    local list = list or {}
    local dropped = false
    local current = list[1] or "None"
    local DropFuncs = {}

    -- Elemento Principal (Glassmorphism)
    local DropMain = Instance.new("Frame", Page)
    DropMain.Size = UDim2.new(1, -10, 0, 42)
    DropMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropMain.BackgroundTransparency = 0.94
    
    local MainCorner = Instance.new("UICorner", DropMain)
    MainCorner.CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", DropMain)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.8
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Texto e Valor Selecionado (Estilo iOS)
    local Label = Instance.new("TextLabel", DropMain)
    Label.Text = text
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SelectedLabel = Instance.new("TextLabel", DropMain)
    SelectedLabel.Text = tostring(current):upper()
    SelectedLabel.Size = UDim2.new(0, 100, 1, 0)
    SelectedLabel.Position = UDim2.new(1, -40, 0, 0)
    SelectedLabel.AnchorPoint = Vector2.new(1, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 12
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Arrow = Instance.new("ImageLabel", DropMain)
    Arrow.Size = UDim2.fromOffset(14, 14)
    Arrow.Position = UDim2.new(1, -12, 0.5, 0)
    Arrow.AnchorPoint = Vector2.new(1, 0.5)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://6034818372"
    Arrow.ImageColor3 = Color3.fromRGB(200, 200, 200)

    local OpenBtn = Instance.new("TextButton", DropMain)
    OpenBtn.Size = UDim2.new(1, 0, 1, 0)
    OpenBtn.BackgroundTransparency = 1
    OpenBtn.Text = ""

    -- Lista Suspensa (Container Glass)
    local DropList = Instance.new("ScrollingFrame", Library.ScreenGui)
    DropList.Size = UDim2.fromOffset(180, 0)
    DropList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    DropList.BackgroundTransparency = 0.1
    DropList.Visible = false
    DropList.ScrollBarThickness = 0
    DropList.ZIndex = 5000
    Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", DropList).Color = Color3.fromRGB(255, 255, 255)
    
    local ListLayout = Instance.new("UIListLayout", DropList)
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", DropList).PaddingTop = UDim.new(0, 8)

    local function Toggle(state)
        dropped = state
        if dropped then
            DropList.Position = UDim2.fromOffset(DropMain.AbsolutePosition.X, DropMain.AbsolutePosition.Y + DropMain.AbsoluteSize.Y + 5)
            DropList.Size = UDim2.fromOffset(DropMain.AbsoluteSize.X, 0)
            DropList.Visible = true
            local h = math.min(ListLayout.AbsoluteContentSize.Y + 16, 200)
            Library:Tween(DropList, {Size = UDim2.fromOffset(DropMain.AbsoluteSize.X, h)}, 0.25)
            Library:Tween(Arrow, {Rotation = 180}, 0.25)
        else
            Library:Tween(DropList, {Size = UDim2.fromOffset(DropMain.AbsoluteSize.X, 0)}, 0.2)
            Library:Tween(Arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function() if not dropped then DropList.Visible = false end end)
        end
    end

    local function CreateOption(val)
        local Btn = Instance.new("TextButton", DropList)
        Btn.Size = UDim2.new(0.92, 0, 0, 32)
        Btn.BackgroundTransparency = 1
        Btn.Text = tostring(val):upper()
        Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 11
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIPadding", Btn).PaddingLeft = UDim.new(0, 12)
        
        Btn.MouseButton1Click:Connect(function()
            current = val
            SelectedLabel.Text = tostring(val):upper()
            if callback then callback(val) end
            Toggle(false)
        end)
    end

    for _, v in pairs(list) do CreateOption(v) end
    OpenBtn.MouseButton1Click:Connect(function() Toggle(not dropped) end)
    
    function DropFuncs:Refresh(newlist)
        for _, v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, v in pairs(newlist) do CreateOption(v) end
    end

    return DropFuncs
end -- Fim Dropdown

return TabFuncs
end -- Fim Tab

return WindowTable
-- Fim Window

function Library:CreateSettings(Window)
    local SettingsTab = Window:Tab("Configurações", "rbxassetid://6031280882")
    
    local ConfigFolder = "DobeiOS_Configs"
    local ConfigName = "Default"
    local SelectedConfig = nil
    
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

    SettingsTab:Button("Salvar Configuração", function()
        if not writefile then return end
        
        local SaveData = {
            Keybinds = { MenuToggle = Library.ToggleKey.Name },
            Toggles = Library.Flags.Toggles,
            Binds = Library.Flags.Binds,
            Colors = Library.Flags.Colors
        }
        
        local success, json = pcall(function() return HttpService:JSONEncode(SaveData) end)
        if success then
            writefile(ConfigFolder .. "/" .. ConfigName .. ".json", json)
            if NotificationService then NotificationService:Create("Config", "SALVO COM SUCESSO!") end
            ConfigDrop:Refresh(GetConfigs())
        end
    end)

    SettingsTab:Button("Carregar Configuração", function()
        if not readfile or not SelectedConfig then return end
        
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        if isfile(path) then
            local content = readfile(path)
            local success, decoded = pcall(function() return HttpService:JSONDecode(content) end)
            
            if success and decoded then
                if decoded.Toggles then
                    for flag, value in pairs(decoded.Toggles) do
                        if Library.Elements[flag] and Library.Elements[flag].Set then
                            Library.Elements[flag].Set(value)
                        end
                    end
                end
                 if NotificationService then NotificationService:Create("Config", "CARREGADO COM SUCESSO!") end
            end
        end
    end)
end

return Library
