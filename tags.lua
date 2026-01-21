
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

local function createCreatorTag(head)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0,220,0,42)
    gui.StudsOffset = Vector3.new(0,2.8,0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = "DOBECORE CREATOR"
    text.TextScaled = true
    text.Font = Enum.Font.GothamBlack
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = 0.85
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.Parent = gui

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40,40,40)),
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
    }
    grad.Parent = text

    task.spawn(function()
        while gui.Parent do
            grad.Offset = Vector2.new((grad.Offset.X + 0.01) % 1, 0)
            RunService.RenderStepped:Wait()
        end
    end)
end

local function createBoosterTag(head)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0,200,0,40)
    gui.StudsOffset = Vector3.new(0,2.6,0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = "SERVER BOOSTER"
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.fromRGB(255,120,200)
    text.Parent = gui

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,120,200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,190,230)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,120,200))
    }
    grad.Parent = text

    task.spawn(function()
        while gui.Parent do
            grad.Rotation = (grad.Rotation + 1.5) % 360
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
