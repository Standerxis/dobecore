local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local API_URL = "https://bzaanfwkntyekealgiwi.supabase.co/functions/v1/api/players/" 
local INGEST_KEY = "dobecore_secret"

_G.TagsVisible = _G.TagsVisible or true
_G.MyTagVisible = _G.MyTagVisible or true
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
        if data and data.tag then
            return data.tag
        end
    end
    return nil
end

local function createPrettyTag(player, head, tagText)
    -- Se a tag já existe, remove para atualizar
    local oldTag = head:FindFirstChild("DobeTag")
    if oldTag then oldTag:Destroy() end

    if not tagText or tagText == "Nenhuma" then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(4, 0, 1, 0)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 50
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextScaled = true
    text.TextColor3 = Color3.new(1, 1, 1)
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = text
    
    local cleanTag = tostring(tagText):upper()
    local grad = Instance.new("UIGradient")
    
    -- Configuração de Cores solicitada
    if cleanTag:find("CREATOR") then
        text.Text = "👑 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 101, 8))
        }
    elseif cleanTag:find("BOOSTER") then
        text.Text = "🚀 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 105, 180))
        }
    elseif cleanTag:find("INFLUENCER") then
        text.Text = "🎥 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
        }
    elseif cleanTag:find("VETERANO") then
        text.Text = "🛡️ " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
        }
    else
        text.Text = cleanTag
        grad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.7,0.7,0.7))
    end
    
    grad.Parent = text
    text.Parent = gui

    task.spawn(function()
        local t = 0
        while gui.Parent do
            t = t + 0.03
            grad.Offset = Vector2.new(math.sin(t) * 1.5, 0)
            RunService.RenderStepped:Wait()
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

-- LOOP DE ATUALIZAÇÃO EM TEMPO REAL (A cada 40 segundos)
task.spawn(function()
    while true do
        task.wait(40)
        for _, plr in ipairs(Players:GetPlayers()) do
            local currentTag = fetchPlayerTagFromDB(plr)
            
            -- Se a tag no banco mudou em relação ao que temos salvo
            if currentTag ~= PlayerTagCache[plr.UserId] then
                PlayerTagCache[plr.UserId] = currentTag
                
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                if head then
                    createPrettyTag(plr, head, currentTag)
                end
            end
        end
    end
end)
