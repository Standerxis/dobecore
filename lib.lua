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
        local ignoreNextTrigger = false -- 🔹 NOVO
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
                    
                    Library.Flags.Binds[flag] = selectedKey.Name
                    ignoreNextTrigger = true -- 🔹 BLOQUEIA EXECUÇÃO IMEDIATA
                    
                    conInput:Disconnect()
                    resetVisual()

                elseif input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    
                    if type(options.Keybind) == "table" then
                        options.Keybind.Value = Enum.KeyCode.Unknown
                    else
                        options.Keybind = Enum.KeyCode.Unknown
                    end
                    
                    Library.Flags.Binds[flag] = Enum.KeyCode.Unknown.Name
                    ignoreNextTrigger = true -- 🔹 TAMBÉM BLOQUEIA
                    
                    conInput:Disconnect()
                    resetVisual()
                end
            end)
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp or binding then return end

            local checkKey = (type(options.Keybind) == "table" and options.Keybind.Value) or options.Keybind

            if ignoreNextTrigger then
                ignoreNextTrigger = false
                return
            end

            if input.KeyCode == checkKey and checkKey ~= Enum.KeyCode.Unknown then
                if callback then callback("Trigger") end
            end
        end)
    end

    -- 2. COLOR PICKER (inalterado)
    if options.Color then
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

        ColorInd.BackgroundColor3 = options.Color
        ColorInd.Text = ""
        ColorInd.ZIndex = parent.ZIndex + 1
        Instance.new("UICorner", ColorInd).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", ColorInd).Color = Theme.ItemStroke

        ColorInd.MouseButton1Click:Connect(function()
            Library:OpenColorPicker(ColorInd.BackgroundColor3, function(newC)
                ColorInd.BackgroundColor3 = newC
                Library.Flags.Colors[flag] = {newC.R, newC.G, newC.B}
                if callback then callback("Color", newC) end
            end)
        end)
    end 
end
