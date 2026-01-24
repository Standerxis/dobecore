-- =========================
-- CONFIGURAÇÕES E SUPORTE
-- =========================
local S = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VIM = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService")
}
local Player = S.Players.LocalPlayer

local Bot = {
    Enabled = false,
    Selling = false,
    MinigameActive = false,
    LastClick = 0,
    LastHookClick = 0,
    LastActionTime = tick(), -- Para verificar se o bot travou
    HookCooldown = 0.8,
    Conn = nil
}

-- Pega o Remote de forma mais segura
local function GetRemote()
    local modules = S.ReplicatedStorage:FindFirstChild("Modules")
    local events = modules and modules:FindFirstChild("Events")
    return events and events:FindFirstChild("RemoteEvent")
end

-- Equipar qualquer vara que esteja no inventário ou mochila
local function EquipRod()
    local char = Player.Character
    if not char then return end
    
    -- Procura por qualquer item que tenha "Rod" no nome
    local rod = char:FindFirstChildWhichIsA("Tool")
    if not (rod and rod.Name:lower():find("rod")) then
        for _, item in ipairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("rod") then
                item.Parent = char
                task.wait(0.5)
                break
            end
        end
    end
end

local function Click(x, y)
    S.VIM:SendTapEvent(x, y)
    Bot.LastActionTime = tick() -- Reseta o timer de inatividade
end

local function DoAction(action)
    local r = GetRemote()
    if not r then return end
    
    if action == "Throw" then
        EquipRod()
        task.wait(0.3)
        r:FireServer("Throw", 1)
        Bot.LastActionTime = tick()
    elseif action == "Sell" then
        -- Lógica de venda simplificada para não travar
        Bot.Selling = true
        local npc = workspace:FindFirstChild("NPCS") and workspace.NPCS:FindFirstChild("Fisherman")
        if npc and Player.Character then
            local oldPos = Player.Character.PrimaryPart.CFrame
            Player.Character:PivotTo(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3))
            task.wait(0.5)
            r:FireServer("SellAllFishes")
            task.wait(0.5)
            r:FireServer("RepairAllFishingRods")
            task.wait(0.5)
            Player.Character:PivotTo(oldPos)
        end
        Bot.Selling = false
        task.wait(0.5)
        DoAction("Throw")
    end
end

-- =========================
-- LOOP PRINCIPAL
-- =========================
local function StartBot()
    if Bot.Conn then Bot.Conn:Disconnect() end
    Bot.Enabled = true
    Bot.LastActionTime = tick()
    
    -- Joga a vara pela primeira vez
    task.spawn(function()
        DoAction("Throw")
    end)

    -- Loop de Verificação (Se o bot ficar parado, ele joga a vara)
    task.spawn(function()
        while Bot.Enabled do
            if not Bot.Selling and not Bot.MinigameActive then
                -- Se passar 7 segundos sem nenhuma ação (clique ou fisgada), tenta jogar a vara
                if tick() - Bot.LastActionTime > 7 then
                    DoAction("Throw")
                end
            end
            task.wait(2)
        end
    end)

    Bot.Conn = S.RunService.Heartbeat:Connect(function()
        if not Bot.Enabled or Bot.Selling then return end

        local gui = Player.PlayerGui
        
        -- 1. Detecção da Fisgada (Círculo na tela)
        local hook = gui:FindFirstChild("HookMeter")
        if hook then
            local mid = hook:FindFirstChild("MiddleCircle", true)
            if mid and mid.Visible and mid.ImageTransparency < 0.5 then
                if os.clock() - Bot.LastHookClick >= Bot.HookCooldown then
                    Bot.LastHookClick = os.clock()
                    local pos = mid.AbsolutePosition
                    local size = mid.AbsoluteSize
                    Click(pos.X + size.X/2, pos.Y + size.Y/2)
                end
            end
        end

        -- 2. Minigame dos Alvos (Targets)
        local catch = gui:FindFirstChild("CatchIndicator")
        local img = catch and catch:FindFirstChild("ImageButton")
        
        if img and img.Visible then
            Bot.MinigameActive = true
            local moving, target
            for _, v in ipairs(img:GetDescendants()) do
                if v:IsA("Frame") then
                    if v.BackgroundColor3 == Color3.fromRGB(242, 84, 84) then moving = v
                    elseif v.BackgroundColor3 == Color3.fromRGB(67, 200, 120) then target = v end
                end
            end

            if moving and target then
                local mPos = moving.AbsolutePosition.X
                local tPos = target.AbsolutePosition.X
                local tSize = target.AbsoluteSize.X
                
                -- Se o marcador vermelho estiver dentro do verde
                if mPos >= (tPos - 2) and mPos <= (tPos + tSize + 2) then
                    if tick() - Bot.LastClick > 0.15 then 
                        Bot.LastClick = tick()
                        local pos = target.AbsolutePosition
                        local size = target.AbsoluteSize
                        Click(pos.X + size.X/2, pos.Y + size.Y/2)
                    end
                end
            end
        else
            -- Se o minigame sumiu da tela e estava ativo, o peixe foi pego
            if Bot.MinigameActive then
                Bot.MinigameActive = false
                task.wait(1.2)
                local r = GetRemote()
                if r then r:FireServer("FishDecision", true) end
                task.wait(1.0)
                if Bot.Enabled then DoAction("Throw") end
            end
        end
    end)
end

-- Para ligar/desligar (Integre com sua aba de Toggle)
-- StartBot() para ligar
-- Bot.Enabled = false para desligar
