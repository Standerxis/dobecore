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
    gui.Size = UDim2.new(0, 250, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 60
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 22 -- Aumentei um pouco já que não tem outline
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Parent = gui
    
    -- Outline removido conforme solicitado
    
    local grad = Instance.new("UIGradient")
    local cleanTag = tostring(tagText):upper()
    
    -- PADRÃO: COR 1 -> BRANCO (COR 2) -> COR 1
    local mainColor
    
    if cleanTag:find("CREATOR") then
        text.Text = "👑 " .. cleanTag
        mainColor = Color3.fromRGB(255, 180, 0) -- Dourado
    elseif cleanTag:find("BOOSTER") then
        text.Text = "🚀 " .. cleanTag
        mainColor = Color3.fromRGB(255, 0, 200) -- Rosa
    elseif cleanTag:find("INFLUENCER") then
        text.Text = "🎥 " .. cleanTag
        mainColor = Color3.fromRGB(0, 200, 255) -- Azul Ciano
    elseif cleanTag:find("VETERANO") then
        text.Text = "🛡️ " .. cleanTag
        mainColor = Color3.fromRGB(255, 0, 0) -- Vermelho
    else
        text.Text = cleanTag
        mainColor = Color3.fromRGB(150, 150, 150) -- Cinza
    end

    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, mainColor),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), -- Branco sempre no meio
        ColorSequenceKeypoint.new(1, mainColor)
    }
    
    grad.Parent = text

    -- Animação de Brilho Suave
    task.spawn(function()
        local t = 0
        while gui.Parent do
            t = t + 0.03
            grad.Offset = Vector2.new(math.sin(t) * 0.6, 0) 
            task.wait()
        end
    end)
end

-- Lógica de Aplicação
local function applyTag(player)
    local function setup(char)
        local head = char:WaitForChild("Head", 15)
        if head then
            local tag = fetchPlayerTagFromDB(player)
            PlayerTagCache[player.UserId] = tag
            createPrettyTag(player, head, tag)
        end
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then task.spawn(setup, player.Character) end
end

for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)

-- Loop de verificação (40s)
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
