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
    -- Limite de tamanho: Usando Scale para não ficar gigante na tela
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(4, 0, 1, 0) -- Tamanho fixo proporcional ao mundo
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 50 -- Limita a distância que a tag some (evita poluição visual)
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextScaled = true -- Faz o texto caber sempre dentro do limite da tag
    text.TextColor3 = Color3.new(1, 1, 1)
    
    -- Adiciona um Stroke (contorno) para ajudar na leitura
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = text
    
    local cleanTag = tostring(tagText):upper()
    local grad = Instance.new("UIGradient")
    
    if cleanTag:find("CREATOR") then
        text.Text = "👑 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)), -- Dourado
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)), -- Sombra Preta
            ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 101, 8))   -- Amarelo Escuro
        }
    elseif cleanTag:find("BOOSTER") then
        text.Text = "🚀 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)), -- Rosa
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), -- Sombra Branca
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 105, 180))  -- Rosa Claro
        }
    elseif cleanTag:find("INFLUENCER") then
        text.Text = "🎥 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), -- Branco
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),       -- Sombra Preta
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))  -- Cinza
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

local function applyTag(player)
    local function setup(char)
        local head = char:WaitForChild("Head", 15)
        local tag = fetchPlayerTagFromDB(player)
        if tag and tag ~= "Nenhuma" then
            if head:FindFirstChild("DobeTag") then head.DobeTag:Destroy() end
            createPrettyTag(player, head, tag)
        end
    end
    player.CharacterAdded:Connect(setup)
    if player.Character then task.spawn(setup, player.Character) end
end

for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)
