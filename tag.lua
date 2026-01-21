local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local API_URL = "https://bzaanfwkntyekealgiwi.supabase.co/functions/v1/api/players/" 
local INGEST_KEY = "dobecore_secret" -- Certifique-se que esta chave é a mesma da imagem

_G.TagsVisible = _G.TagsVisible or true
_G.MyTagVisible = _G.MyTagVisible or true
local PlayerTagCache = {}

local function fetchPlayerTagFromDB(player)
    -- Usa a função de request do executor para evitar o erro de "blocked function"
    local req = (syn and syn.request) or (http and http.request) or request or http_request
    if not req then return nil end

    local success, response = pcall(function()
        return req({
            Url = API_URL .. tostring(player.UserId),
            Method = "GET",
            Headers = { ["x-api-key"] = INGEST_KEY }
        })
    end)

    -- Corrigido: Agora aceita o status 200 como sucesso
    if success and (response.StatusCode == 200 or response.Success) then
        local data = HttpService:JSONDecode(response.Body)
        print("[DOBE DEBUG] Tag encontrada para " .. player.Name .. ": " .. tostring(data.tag))
        return data.tag
    end
    return nil
end

local function createPrettyTag(player, head, tagText)
    if not tagText or tagText == "" or tagText == "Nenhuma" then return end

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
    text.TextSize = 14
    text.TextColor3 = Color3.new(1, 1, 1)
    
    -- Formatação de ícones
    local cleanTag = tagText:upper()
    if cleanTag:find("SERVER BOOSTER") then text.Text = "🚀 " .. cleanTag 
    elseif cleanTag:find("CREATOR") then text.Text = "👑 " .. cleanTag
    else text.Text = cleanTag end
    
    text.Parent = gui
    print("[DOBE DEBUG] Tag visual aplicada com sucesso em " .. player.Name)
end

local function applyTag(player)
    player.CharacterAdded:Connect(function(char)
        local head = char:WaitForChild("Head", 10)
        local tag = fetchPlayerTagFromDB(player)
        if tag then createPrettyTag(player, head, tag) end
    end)
    if player.Character then 
        local head = player.Character:FindFirstChild("Head")
        if head then
            local tag = fetchPlayerTagFromDB(player)
            if tag then createPrettyTag(player, head, tag) end
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)
