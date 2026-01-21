local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TagConfig = {
    Creator = {
        Priority = 3,
        Users = {"taylafofinha2", "MV_CAP", "SolterYourBad"}
    },
    Booster = {
        Priority = 2,
        Users = {"taylafofinha2", "greenlauren1"}
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

-- Função única para criar o visual, baseada no que funciona no seu script
local function createPrettyTag(head, tagType)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    -- Tamanho fixo em pixels para não crescer (Offset)
    gui.Size = (tagType == "Creator") and UDim2.new(0, 160, 0, 30) or UDim2.new(0, 140, 0, 26)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 100
    gui.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBold
    text.TextSize = 12
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Parent = frame

    if tagType == "Creator" then
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        text.Text = "DOBE CREATOR"
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Parent = frame

        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
        }
        grad.Parent = stroke

        task.spawn(function()
            while gui.Parent do
                grad.Offset = Vector2.new(math.sin(tick()*2)*0.5, 0)
                RunService.RenderStepped:Wait()
            end
        end)

    elseif tagType == "Booster" then
        frame.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        text.Text = "✦ SERVER BOOSTER"
        corner.CornerRadius = UDim.new(0, 20)
        
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new(Color3.fromRGB(255, 100, 200), Color3.fromRGB(255, 255, 255))
        grad.Parent = frame
    end
end

local function applyTag(player)
    local tag = getPlayerTag(player)
    if not tag then return end

    -- Conexão para quando o personagem renascer
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5) -- Delay essencial para o Roblox carregar a cabeça
        clearTag(char)
        local head = char:FindFirstChild("Head")
        if head then
            createPrettyTag(head, tag)
        end
    end)

    -- Aplica imediatamente se o personagem já existir
    if player.Character then
        task.wait(0.1)
        clearTag(player.Character)
        local head = player.Character:FindFirstChild("Head")
        if head then
            createPrettyTag(head, tag)
        end
    end
end

-- Inicia para quem já está no servidor e para novos
for _, plr in ipairs(Players:GetPlayers()) do
    applyTag(plr)
end
Players.PlayerAdded:Connect(applyTag)
