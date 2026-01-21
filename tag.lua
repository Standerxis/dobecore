local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variáveis de controle globais para o menu acessar
_G.TagsVisible = _G.TagsVisible or true
_G.MyTagVisible = _G.MyTagVisible or true

local TagConfig = {
    Creator = {
        Priority = 4,
        Users = {"taylafofinha2", "SolterYourBad","MV_CAP"}
    },
    Influencer = {
        Priority = 3,
        Users = {"greenlauren1"} 
    },
    Booster = {
        Priority = 2,
        Users = {"greenlauren1","leooswzx"}
    },
    Veterano = {
        Priority = 1,
        Users = {}
    }
}

-- Funções de Controle que o Menu vai chamar
function _G.toggleAllTags(state)
    _G.TagsVisible = state
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("DobeTag")
                if tag then tag.Enabled = state end
            end
        end
    end
end

function _G.toggleMyTag(state)
    _G.MyTagVisible = state
    local char = Players.LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("DobeTag")
            if tag then tag.Enabled = state end
        end
    end
end

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

local function createPrettyTag(player, head, tagType)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 140, 0, 30)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 80
    
    -- VERIFICAÇÃO DE VISIBILIDADE AO CRIAR
    if not _G.TagsVisible then
        gui.Enabled = false
    elseif player == Players.LocalPlayer and not _G.MyTagVisible then
        gui.Enabled = false
    end
    
    gui.Parent = head

    -- [SISTEMA DE CORES E ANIMAÇÕES IGUAL AO ANTERIOR]
    if tagType == "Creator" or tagType == "Influencer" or tagType == "Booster" then
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.BorderSizePixel = 0
        text.Font = Enum.Font.GothamBlack
        text.TextSize = 12
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Parent = gui

        local textGrad = Instance.new("UIGradient")
        
        if tagType == "Creator" then
            text.Text = "👑 DOBECORE"
            textGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 40, 40)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
            }
        elseif tagType == "Influencer" then
            text.Text = "🎥 INFLUENCER"
            textGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 150)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            }
        elseif tagType == "Booster" then
            text.Text = "🚀 SERVER BOOSTER"
            textGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 20, 147)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            }
        end
        
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
                createPrettyTag(player, head, tag)
            end
        end
    end

    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.spawn(onCharacter, player.Character) end
end

for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)
