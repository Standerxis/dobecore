local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TagConfig = {
    Creator = {
        Priority = 4, -- Aumentado para manter no topo
        Users = {"taylafofinha2","Mv_Cap", "SolterYourBad"}
    },
    Influencer = {
        Priority = 3,
        Users = {} -- Adicione os nomes aqui
    },
    Booster = {
        Priority = 2,
        Users = {"taylafofinha2", "Mv_Cap", "greenlauren1"}
    },
    Veterano = {
        Priority = 1,
        Users = {}
    }
}

local function hasName(list, name)
    for _, v in ipairs(list) do
        if string.lower(v) == string.lower(name) then return true end
    end
    return false
end

local function getPlayerTag(player)
    local best = nil
    local bestPriority = -1
    for tagName, data in pairs(TagConfig) do
        if hasName(data.Users, player.Name) then
            if data.Priority > bestPriority then
                best = tagName
                bestPriority = data.Priority
            end
        end
    end
    return best
end

local function clearTag(char)
    local head = char:FindFirstChild("Head")
    if head then
        local old = head:FindFirstChild("DobeTag")
        if old then old:Destroy() end
    end
end

local function createPrettyTag(head, tagType)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 140, 0, 30)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 80
    gui.Parent = head

    if tagType == "Creator" then
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.BorderSizePixel = 0
        text.Font = Enum.Font.GothamBlack
        text.TextSize = 12
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Text = "👑 DOBECORE"
        text.Parent = gui

        local textGrad = Instance.new("UIGradient")
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 40, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
        }
        textGrad.Parent = text

        task.spawn(function()
            local offsetText = -1
            while gui.Parent do
                offsetText = offsetText + 0.015
                if offsetText > 1 then offsetText = -1 end
                textGrad.Offset = Vector2.new(offsetText, 0)
                RunService.RenderStepped:Wait()
            end
        end)

    elseif tagType == "Influencer" then
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BorderSizePixel = 0
        frame.BackgroundColor3 = Color3.fromRGB(173, 216, 230) -- Azul claro/Ciano
        frame.BackgroundTransparency = 0.15
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Font = Enum.Font.GothamBlack
        text.TextSize = 10
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Text = "🎥 INFLUENCER"
        text.Parent = frame

    elseif tagType == "Booster" then
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BorderSizePixel = 0
        frame.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        frame.BackgroundTransparency = 0.15
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Font = Enum.Font.GothamBlack
        text.TextSize = 9
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Text = "🚀 SERVER BOOSTER"
        text.Parent = frame

        local boostGrad = Instance.new("UIGradient")
        boostGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 120, 200))
        boostGrad.Parent = frame

        task.spawn(function()
            while gui.Parent do
                boostGrad.Rotation = (boostGrad.Rotation + 2) % 360
                RunService.RenderStepped:Wait()
            end
        end)
    end
end

local function applyTag(player)
    local function onCharacter(char)
        task.wait(0.6)
        clearTag(char)
        local tag = getPlayerTag(player)
        if tag then
            local head = char:WaitForChild("Head", 10)
            if head then
                createPrettyTag(head, tag)
            end
        end
    end

    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.spawn(onCharacter, player.Character) end
end

for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)
