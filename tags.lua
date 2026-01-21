local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Configurações de Tag
local TagConfig = {
    Creator = {
        Priority = 3,
        Users = {
            "taylafofinha2",
            "Mv_Cap",
            "SolterYourBad"
        }
    },

    Booster = {
        Priority = 2,
        Users = {
            "taylafofinha2",
            "greenlauren1"
        }
    },

    Veterano = {
        Priority = 1,
        Users = {
            -- Adicione nomes aqui
        }
    }
}

-- Funções Auxiliares
local function hasName(list, name)
    for _, v in ipairs(list) do
        if string.lower(v) == string.lower(name) then
            return true
        end
    end
    return false
end

local function getPlayerTag(player)
    local best = nil
    local bestPriority = -1

    for tagName, data in pairs(TagConfig) do
        if hasName(data.Users, player.Name) then
            if data.Priority > bestPriority then
                best = tagName
                bestPriority = data.Priority
            end
        end
    end
    return best
end

local function clearTag(char)
    local head = char:FindFirstChild("Head")
    if head then
        local old = head:FindFirstChild("DobeTag")
        if old then old:Destroy() end
    end
end

-- Gerador de Base da UI (Para manter o padrão de "Tag" pequena e fixa)
local function createBaseGui(head, sizeX, sizeY)
    local gui = Instance.new("BillboardGui")
    gui.Name = "DobeTag"
    gui.Size = UDim2.new(0, sizeX, 0, sizeY) -- Usando Offset (0, pixel) para não crescer com a distância
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 100 -- Desaparece se estiver muito longe
    gui.Parent = head
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    return gui, frame
end

-- TAG: CREATOR (Dourado com Brilho)
local function createCreatorTag(head)
    local gui, frame = createBaseGui(head, 180, 35)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "DOBE CREATOR"
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 13
    text.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
    }
    grad.Parent = stroke

    task.spawn(function()
        local counter = 0
        while gui.Parent do
            counter = counter + 0.02
            grad.Offset = Vector2.new(math.sin(counter), 0)
            RunService.RenderStepped:Wait()
        end
    end)
end

-- TAG: BOOSTER (Rosa Estilo Pílula)
local function createBoosterTag(head)
    local gui, frame = createBaseGui(head, 160, 30)
    frame.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
    frame.UICorner.CornerRadius = UDim.new(0, 20) -- Formato arredondado
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "✦ SERVER BOOSTER"
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 11
    text.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 200))
    }
    grad.Parent = frame

    task.spawn(function()
        while gui.Parent do
            grad.Rotation = (grad.Rotation + 2) % 360
            RunService.RenderStepped:Wait()
        end
    end)
end

-- TAG: VETERANO (Azul/Prata)
local function createVeteranoTag(head)
    local gui, frame = createBaseGui(head, 140, 28)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "VETERANO"
    text.TextColor3 = Color3.fromRGB(200, 200, 200)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 11
    text.Parent = frame
end

-- Aplicação das Tags
local function applyTag(player)
    local function setup(char)
        task.wait(0.5) -- Espera o personagem carregar totalmente
        clearTag(char)
        
        local tag = getPlayerTag(player)
        if not tag then return end
        
        local head = char:FindFirstChild("Head")
        if not head then return end
        
        if tag == "Creator" then
            createCreatorTag(head)
        elseif tag == "Booster" then
            createBoosterTag(head)
        elseif tag == "Veterano" then
            createVeteranoTag(head)
        end
    end

    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

-- Inicialização
for _, plr in ipairs(Players:GetPlayers()) do
    applyTag(plr)
end

Players.PlayerAdded:Connect(applyTag)
