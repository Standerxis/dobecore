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
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 180, 0, 40)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 15
    text.TextColor3 = Color3.new(1, 1, 1)
    
    local cleanTag = tostring(tagText):upper()
    local grad = Instance.new("UIGradient")
    
    -- Configuração de Cores e Ícones baseada no seu pedido
    if cleanTag:find("CREATOR") then
        text.Text = "👑 " .. cleanTag
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)), -- Dourado
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)), -- Sombra Preta
            ColorSequenceKeypoint.new(1, Color3.fromRGB(184, 134, 11))  -- Amarelo Escuro
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
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))  -- Cinza Claro
        }
    elseif cleanTag:find("VETERANO") then
        text.Text = "🛡️ " .. cleanTag
        grad.Color = ColorSequence.new{ -- 5 Cores para Veterano
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),    -- Vermelho
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),-- Amarelo
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),  -- Verde
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 255)),-- Ciano
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))   -- Magenta
        }
    else
        text.Text = cleanTag
        grad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.8,0.8,0.8))
    end
    
    grad.Parent = text
    text.Parent = gui

    -- Animação de movimento da sombra/brilho
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
