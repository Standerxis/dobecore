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
        return data and data.tag or nil
    end
    return nil
end

local function createPrettyTag(player, head, tagType)
    if not tagType or tagType == "" or tagType == "Nenhuma" then return end

    -- Remove tag antiga se existir
    local old = head:FindFirstChild("DobeTag")
    if old then old:Destroy() end

    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    -- Voltando para o tamanho da sua UI original:
    gui.Size = UDim2.new(0, 140, 0, 30) 
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 80 -- Mantendo seu MaxDistance original
    
    -- Controle de visibilidade global
    if not _G.TagsVisible then
        gui.Enabled = false
    elseif player == Players.LocalPlayer and not _G.MyTagVisible then
        gui.Enabled = false
    end
    
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.BorderSizePixel = 0
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 12 -- Sua TextSize original
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Parent = gui

    local textGrad = Instance.new("UIGradient")
    local cleanTag = tagType:upper()

    -- CONFIGURAÇÃO DE CORES EXATA DO SEU PEDIDO
    if cleanTag:find("CREATOR") then
        text.Text = "👑 " .. cleanTag
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)), -- Dourado
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)), -- Sombra Preta
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))   -- Dourado
        }
    elseif cleanTag:find("BOOSTER") then
        text.Text = "🚀 " .. cleanTag
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)), -- Rosa
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), -- Sombra Branca
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147))
        }
    elseif cleanTag:find("INFLUENCER") then
        text.Text = "🎥 " .. cleanTag
        textGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), -- Branco
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),       -- Sombra Preta
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }
    elseif cleanTag:find("VETERANO") then
        text.Text = "🛡️ " .. cleanTag
        textGrad.Color = ColorSequence.new{ -- 5 cores
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
        }
    else
        text.Text = cleanTag
        textGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.6,0.6,0.6))
    end
    
    textGrad.Parent = text

    -- Sua animação original de RenderStepped
    task.spawn(function()
        local offsetText = -1
        while gui.Parent do
            offsetText = offsetText + 0.015 -- Sua velocidade original
            if offsetText > 1 then offsetText = -1 end
            textGrad.Offset = Vector2.new(offsetText, 0)
            RunService.RenderStepped:Wait()
        end
    end)
end

local function applyTag(player)
    local function onCharacter(char)
        task.wait(0.6)
        local head = char:WaitForChild("Head", 10)
        if head then
            local tag = fetchPlayerTagFromDB(player)
            PlayerTagCache[player.UserId] = tag
            createPrettyTag(player, head, tag)
        end
    end
    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.spawn(onCharacter, player.Character) end
end

for _, plr in ipairs(Players:GetPlayers()) do applyTag(plr) end
Players.PlayerAdded:Connect(applyTag)

-- LOOP DE ATUALIZAÇÃO (Reinserido)
task.spawn(function()
    while true do
        task.wait(40)
        for _, plr in ipairs(Players:GetPlayers()) do
            local newTag = fetchPlayerTagFromDB(plr)
            if newTag ~= PlayerTagCache[plr.UserId] then
                PlayerTagCache[plr.UserId] = newTag
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    createPrettyTag(plr, plr.Character.Head, newTag)
                end
            end
        end
    end
end)
