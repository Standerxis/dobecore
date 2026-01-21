local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local API_URL = "https://bzaanfwkntyekealgiwi.supabase.co/functions/v1/api/players/" 
local INGEST_KEY = "dobecore_secret"

_G.TagsVisible = _G.TagsVisible or true
local PlayerTagCache = {}

local function fetchPlayerTagFromDB(player)
    local req = (syn and syn.request) or (http and http.request) or request or http_request
    if not req then return nil end

    local success, response = pcall(function()
        return req({
            Url = API_URL .. tostring(player.UserId),
            Method = "GET",
            Headers = { ["x-api-key"] = INGEST_KEY }
        })
    end)

    if success and (response.StatusCode == 200 or response.Success) then
        local data = HttpService:JSONDecode(response.Body)
        return data and data.tag
    end
    return nil
end

local function createPrettyTag(player, head, tagText)
    local oldTag = head:FindFirstChild("DobeTag")
    if oldTag then oldTag:Destroy() end

    if not tagText or tagText == "Nenhuma" then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 200, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3.5, 0) -- Um pouco mais alto para não colidir com o nome
    gui.AlwaysOnTop = true
    gui.MaxDistance = 60
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBold -- Fonte mais limpa
    text.TextScaled = false
    text.TextSize = 18 -- Tamanho fixo fica mais "clean" que o Scaled
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Parent = gui
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2.5
    stroke.Transparency = 0.2
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Parent = text
    
    local grad = Instance.new("UIGradient")
    local cleanTag = tostring(tagText):upper()
    
    -- Configuração de Estilos Premium
    if cleanTag:find("CREATOR") then
        text.Text = "👑 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 230, 100))
        }
    elseif cleanTag:find("BOOSTER") then
        text.Text = "🚀 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 255))
        }
    elseif cleanTag:find("INFLUENCER") then
        text.Text = "🎥 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
        }
    elseif cleanTag:find("VETERANO") then
        text.Text = "🛡️ " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
        }
    else
        text.Text = cleanTag
        grad.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 255, 255))
    end
    
    grad.Parent = text

    -- Animação de Rotação (Efeito de brilho metálico)
    task.spawn(function()
        while gui.Parent do
            grad.Rotation = grad.Rotation + 2
            task.wait(0.02)
        end
    end)
end

-- Função principal de aplicação
local function applyTag(player)
    local function setup(char)
        local head = char:WaitForChild("Head", 15)
        if not head then return end
        
        local tag = fetchPlayerTagFromDB(player)
        PlayerTagCache[player.UserId] = tag
        createPrettyTag(player, head, tag)
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then task.spawn(setup, player.Character) end
end

-- Inicialização
for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)

-- Loop de atualização (Otimizado para não pesar)
task.spawn(function()
    while true do
        task.wait(40)
        for _, plr in ipairs(Players:GetPlayers()) do
            local currentTag = fetchPlayerTagFromDB(plr)
            if currentTag ~= PlayerTagCache[plr.UserId] then
                PlayerTagCache[plr.UserId] = currentTag
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    createPrettyTag(plr, plr.Character.Head, currentTag)
                end
            end
        end
    end
end)
