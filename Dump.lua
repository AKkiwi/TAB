-- SIMPLE AUDIT & DUMP - VERSION LÉGÈRE
-- Pour Maitresse Fatima

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local logs = {}
local function log(text)
    table.insert(logs, text)
end

local function separator(title)
    log("")
    log("========================================")
    log("   " .. title:upper())
    log("========================================")
end

-- Fonction pour détecter les mots-clés dangereux
local function isSuspicious(name)
    name = name:lower()
    return name:match("admin") or name:match("ban") or name:match("money") or 
           name:match("cash") or name:match("give") or name:match("luck") or 
           name:match("roll") or name:match("reward")
end

log("🔍 AUDIT SIMPLIFIÉ DÉMARRÉ...")
log("Joueur: " .. player.Name)

-- 1. VÉRIFICATION DES "LEADERSTATS" (ERREUR CLASSIQUE)
separator("1. ÉCONOMIE & STATS")
local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
    log("🔴 DANGER: Dossier 'leaderstats' trouvé !")
    log("   Si les valeurs changent ici, assure-toi que")
    log("   le serveur ne fait pas confiance à ces données.")
    for _, v in ipairs(leaderstats:GetChildren()) do
        log("   - " .. v.Name .. ": " .. tostring(v.Value))
    end
else
    log("✅ Pas de leaderstats (Bon signe !)")
end

-- 2. VÉRIFICATION DES VALEURS DU JOUEUR (LUCK, COINS...)
separator("2. VALEURS CLIENT (Player & Char)")
local function scanValues(parent, context)
    for _, v in ipairs(parent:GetDescendants()) do
        if v:IsA("ValueBase") and not v:IsDescendantOf(player.PlayerGui) then
            local prefix = "   "
            if isSuspicious(v.Name) then
                prefix = "🔴 " -- Marque rouge si suspect
            end
            log(prefix .. context .. " > " .. v.Name .. " (" .. v.ClassName .. ") = " .. tostring(v.Value))
        end
    end
end
scanValues(player, "Player")
if player.Character then
    scanValues(player.Character, "Character")
end

-- 3. LISTE DES REMOTE EVENTS/FUNCTIONS
separator("3. REMOTE EVENTS (Portes d'entrée)")
local remotes = {}
for _, v in ipairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        table.insert(remotes, v)
    end
end

if #remotes == 0 then
    log("Aucun Remote trouvé dans ReplicatedStorage.")
else
    for _, remote in ipairs(remotes) do
        local name = remote.Name
        if isSuspicious(name) then
            log("🔴 " .. remote.ClassName .. ": " .. remote:GetFullName())
            log("   ⚠️ Vérifie que ce remote est sécurisé côté serveur !")
        else
            log("   " .. remote.ClassName .. ": " .. remote.Name)
        end
    end
end

-- 4. LISTE DES SCRIPTS LOCAUX
separator("4. LOCAL SCRIPTS")
local scripts = {}
for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("LocalScript") and (v:IsDescendantOf(player) or v:IsDescendantOf(RS)) then
        if v.Name:lower():match("anti") or v.Name:lower():match("cheat") then
            log("🔴 ANTICHEAT CLIENT: " .. v:GetFullName())
            log("   ⚠️ Un anticheat local peut être supprimé par un cheater.")
        else
            log("   " .. v.Name .. " (dans " .. v.Parent.Name .. ")")
        end
    end
end

-- 5. INTERACTIONS PHYSIQUES (Workspace)
separator("5. INTERACTIONS (Workspace)")
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
        local parentName = v.Parent.Name
        if isSuspicious(v.Name) or isSuspicious(parentName) then
            log("🔴 Interaction Suspecte: " .. parentName .. " [" .. v.ClassName .. "]")
        end
    end
end

log("")
log("✅ FIN DE L'AUDIT.")

-- ====================================================
-- INTERFACE GRAPHIQUE SIMPLE (GUI)
-- ====================================================

local gui = Instance.new("ScreenGui")
gui.Name = "SimpleAudit"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.8, 0, 0.8, 0)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "AUDIT SIMPLIFIÉ - LISTE & ERREURS"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, 0, 0, 0)
textBox.AutomaticSize = Enum.AutomaticSize.Y
textBox.BackgroundTransparency = 1
textBox.TextColor3 = Color3.fromRGB(200, 200, 200)
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Top
textBox.Font = Enum.Font.Code
textBox.TextSize = 14
textBox.MultiLine = true
textBox.ClearTextOnFocus = false
textBox.TextEditable = false
textBox.Text = table.concat(logs, "\n")
textBox.Parent = scroll

print("Audit terminé. Vérifie l'interface.")
