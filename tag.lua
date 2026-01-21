local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- CONFIGURAÇÕES DO BANCO (Sincronizado com Lovable)
local API_URL = "https://bzaanfwkntyekealgiwi.supabase.co/functions/v1/api/players/" 
local INGEST_KEY = "dobecore_secret"

-- Variáveis de controle globais
_G.TagsVisible = _G.TagsVisible or true
_G.MyTagVisible = _G.MyTagVisible or true

-- Cache para não sobrecarregar a API (armazena as tags dos players que já carregaram)
local PlayerTagCache = {}

-- ==========================================
-- FUNÇÕES DE BUSCA (API)
-- ==========================================

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

    if success and response.Success then
        local data = HttpService:JSONDecode(response.Body)
        -- Retorna a tag do banco (ex: "DOBECORE CREATOR", "Influencer", etc)
        return data and data.tag or nil
    end
    return nil
end

-- ==========================================
-- FUNÇÕES DE CONTROLE (UI)
-- ==========================================

function _G.toggleAllTags(state)
    _G.TagsVisible = state
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        local tag = head and head:FindFirstChild("DobeTag")
        if tag then tag.Enabled = state end
    end
end

function _G.toggleMyTag(state)
    _G.MyTagVisible = state
    local char = Players.LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    local tag = head and head:FindFirstChild("DobeTag")
    if tag then tag.Enabled = state end
end

-- ==========================================
-- CRIAÇÃO VISUAL DA TAG
-- ==========================================

local function createPrettyTag(player, head, tagText)
    if not tagText or tagText == "" or tagText == "Nenhuma" then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 160, 0, 40)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 80
    
    -- Controle de Visibilidade
    if not _G.TagsVisible then
        gui.Enabled = false
    elseif player == Players.LocalPlayer and not _G.MyTagVisible then
        gui.Enabled = false
    end
    
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 14
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Text = tagText:upper()
    text.Parent = gui

    local textGrad = Instance.new("UIGradient")
    
    -- Cores baseadas no texto da tag vindo do Banco
    if tagText:find("CREATOR") then
        text.Text = "👑 " .. tagText:upper()
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
        }
    elseif tagText:find("Influencer") then
        text.Text = "🎥 " .. tagText:upper()
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }
    elseif tagText:find("Booster") then
        text.Text = "🚀 " .. tagText:upper()
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 200)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 200))
        }
    else -- Veterano ou outros
        textGrad.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 255, 255))
    end
    
    textGrad.Parent = text

    -- Animação de Brilho
    task.spawn(function()
        local offset = -1
        while gui.Parent do
            offset = offset + 0.02
            if offset > 1 then offset = -1 end
            textGrad.Offset = Vector2.new(offset, 0)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- ==========================================
-- APLICAÇÃO E LOOP
-- ==========================================

local function applyTag(player)
    local function onCharacter(char)
        task.wait(0.8) -- Espera o char carregar
        local head = char:WaitForChild("Head", 10)
        if not head then return end
        
        -- Busca tag (do cache ou da API)
        local tag = PlayerTagCache[player.UserId]
        if not tag then
            tag = fetchPlayerTagFromDB(player)
            PlayerTagCache[player.UserId] = tag
        end

        if tag and tag ~= "Nenhuma" then
            if head:FindFirstChild("DobeTag") then head.DobeTag:Destroy() end
            createPrettyTag(player, head, tag)
        end
    end

    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.spawn(onCharacter, player.Character) end
end

-- Gerenciar quem já está e quem entra
for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)

-- Loop para atualizar tags em tempo real (caso mude no site)
task.spawn(function()
    while true do
        for _, plr in ipairs(Players:GetPlayers()) do
            local newTag = fetchPlayerTagFromDB(plr)
            if newTag ~= PlayerTagCache[plr.UserId] then
                PlayerTagCache[plr.UserId] = newTag
                if plr.Character then onCharacter(plr.Character) end
            end
        end
        task.wait(40) -- Verifica mudanças globais a cada 40s
    end
end)
