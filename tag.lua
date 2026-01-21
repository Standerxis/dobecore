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

    -- Corrigido: 200 é SUCESSO. Vamos processar o corpo da mensagem.
    if success and (response.StatusCode == 200 or response.Success) then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.tag then
            return data.tag -- Retorna "Server Booster" como mostrado no seu print
        end
    end
    return nil
end

local function createPrettyTag(player, head, tagText)
    -- Se chegou aqui, o tagText já é "Server Booster"
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 160, 0, 40)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 15 -- Aumentado para destaque
    text.TextColor3 = Color3.new(1, 1, 1)
    
    -- Lógica de exibição baseada no seu print
    local cleanTag = tostring(tagText):upper()
    if cleanTag:find("BOOSTER") then
        text.Text = "🚀 " .. cleanTag
    elseif cleanTag:find("CREATOR") then
        text.Text = "👑 " .. cleanTag
    else
        text.Text = cleanTag
    end
    
    text.Parent = gui

    -- Gradiente animado para o Server Booster
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 255)), -- Rosa Booster
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 255))
    }
    grad.Parent = text

    task.spawn(function()
        local t = 0
        while gui.Parent do
            t = t + 0.02
            grad.Offset = Vector2.new(math.sin(t), 0)
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
