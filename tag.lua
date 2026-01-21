local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- CONFIGURAÇÕES DO BANCO
local API_URL = "https://bzaanfwkntyekealgiwi.supabase.co/functions/v1/api/players/" 
local INGEST_KEY = "dobecore_secret"

-- Variáveis de controle globais
_G.TagsVisible = _G.TagsVisible or true
_G.MyTagVisible = _G.MyTagVisible or true

local PlayerTagCache = {}

-- ==========================================
-- FUNÇÕES DE BUSCA (API) COM DEBUG
-- ==========================================

local function fetchPlayerTagFromDB(player)
    local req = (syn and syn.request) or (http and http.request) or request or http_request
    if not req then 
        warn("[DOBE DEBUG] Executor não suporta HTTP requests.")
        return nil 
    end

    local success, response = pcall(function()
        return req({
            Url = API_URL .. tostring(player.UserId),
            Method = "GET",
            Headers = { ["x-api-key"] = INGEST_KEY }
        })
    end)

    if not success then
        warn("[DOBE DEBUG] Erro crítico ao tentar conectar na API: " .. tostring(response))
        return nil
    end

    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if data then
            print("[DOBE DEBUG] Dados recebidos para " .. player.Name .. ": Tag = " .. tostring(data.tag))
            return data.tag
        else
            warn("[DOBE DEBUG] Resposta da API vazia para " .. player.Name)
        end
    else
        warn("[DOBE DEBUG] API retornou erro " .. tostring(response.StatusCode) .. " para o jogador " .. player.Name)
        print("[DOBE DEBUG] Resposta do Servidor: " .. response.Body)
    end
    return nil
end

-- ==========================================
-- CRIAÇÃO VISUAL DA TAG
-- ==========================================

local function createPrettyTag(player, head, tagText)
    if not tagText or tagText == "" or tagText == "Nenhuma" then return end
    
    print("[DOBE DEBUG] Criando tag visual: " .. tagText .. " para " .. player.Name)

    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, 160, 0, 40)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 80
    
    if not _G.TagsVisible then gui.Enabled = false
    elseif player == Players.LocalPlayer and not _G.MyTagVisible then gui.Enabled = false end
    
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 14
    text.TextColor3 = Color3.new(1, 1, 1)
    
    -- Lógica de Nome/Ícone
    local cleanTag = tagText:upper()
    if cleanTag:find("CREATOR") then text.Text = "👑 " .. cleanTag
    elseif cleanTag:find("INFLUENCER") then text.Text = "🎥 " .. cleanTag
    elseif cleanTag:find("BOOSTER") then text.Text = "🚀 " .. cleanTag
    else text.Text = cleanTag end
    
    text.Parent = gui

    local textGrad = Instance.new("UIGradient")
    if cleanTag:find("CREATOR") then
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
        }
    elseif cleanTag:find("INFLUENCER") then
        textGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150))
    else
        textGrad.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 255, 255))
    end
    textGrad.Parent = text

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
-- LÓGICA DE APLICAÇÃO
-- ==========================================

local function applyTag(player)
    local function onCharacter(char)
        task.wait(1)
        local head = char:WaitForChild("Head", 10)
        if not head then return end
        
        print("[DOBE DEBUG] Buscando tag para " .. player.Name)
        local tag = fetchPlayerTagFromDB(player)
        PlayerTagCache[player.UserId] = tag

        if tag and tag ~= "Nenhuma" then
            if head:FindFirstChild("DobeTag") then head.DobeTag:Destroy() end
            createPrettyTag(player, head, tag)
        else
            print("[DOBE DEBUG] Jogador " .. player.Name .. " não possui tag no banco.")
        end
    end

    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.spawn(onCharacter, player.Character) end
end

for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)

-- Loop de Atualização em Tempo Real
task.spawn(function()
    while true do
        task.wait(40)
        for _, plr in ipairs(Players:GetPlayers()) do
            local newTag = fetchPlayerTagFromDB(plr)
            if newTag ~= PlayerTagCache[plr.UserId] then
                print("[DOBE DEBUG] Mudança de tag detectada para " .. plr.Name)
                PlayerTagCache[plr.UserId] = newTag
                if plr.Character then 
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        if head:FindFirstChild("DobeTag") then head.DobeTag:Destroy() end
                        createPrettyTag(plr, head, newTag)
                    end
                end
            end
        end
    end
end)
