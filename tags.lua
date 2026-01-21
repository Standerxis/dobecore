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


local TagConfig = {
    Creator = {
        Priority = 3,
        Users = {
            "taylafofinha2",
            "Mv_Cap",
            "SolterYourBad"
        }
    },

    Booster = {
        Priority = 2,
        Users = {
            "taylafofinha2",
            "greenlauren1"
        }
    },

    Veterano = {
        Priority = 1,
        Users = {
        }
    }
}

local function hasName(list, name)
    for _, v in ipairs(list) do
        if string.lower(v) == string.lower(name) then
            return true
        end
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
        if old then
            old:Destroy()
        end
    end
end

-- Substitua as funções originais por estas:

local function createCreatorTag(head)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    -- Define um tamanho fixo em pixels, mas limita a escala
    gui.Size = UDim2.new(0, 180, 0, 35) 
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 100 -- Impede que seja vista do outro lado do mapa
    gui.Parent = head

    -- Container para a Tag (Fundo)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "DOBE CREATOR"
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 14 -- Tamanho fixo para parecer uma tag real
    text.RichText = true
    text.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)), -- Dourado
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), -- Brilho
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
    }
    grad.Parent = stroke -- O gradiente agora afeta a borda (efeito premium)

    task.spawn(function()
        local counter = 0
        while gui.Parent do
            counter = counter + 0.02
            grad.Offset = Vector2.new(math.sin(counter), 0)
            RunService.RenderStepped:Wait()
        end
    end)
end

local function createBoosterTag(head)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 160, 0, 30)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 80
    gui.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    frame.BackgroundTransparency = 0.4
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20) -- Estilo pílula
    corner.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "✦ SERVER BOOSTER"
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 12
    text.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 200))
    }
    grad.Parent = frame

    task.spawn(function()
        while gui.Parent do
            grad.Rotation = (grad.Rotation + 2) % 360
            RunService.RenderStepped:Wait()
        end
    end)
end
local function applyTag(player)
    local tag = getPlayerTag(player)
    if not tag then return end

    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        clearTag(char)

        local head = char:FindFirstChild("Head")
        if not head then return end

        if tag == "Creator" then
            createCreatorTag(head)
        elseif tag == "Booster" then
            createBoosterTag(head)
        end
    end)

    if player.Character then
        clearTag(player.Character)
        local head = player.Character:FindFirstChild("Head")
        if head then
            if tag == "Creator" then
                createCreatorTag(head)
            elseif tag == "Booster" then
                createBoosterTag(head)
            end
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    applyTag(plr)
end

Players.PlayerAdded:Connect(applyTag)
