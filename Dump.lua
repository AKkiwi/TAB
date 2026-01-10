-- RNG GAME - COMPLETE EXPLOIT VECTOR AUDIT
-- Version Android optimisée avec gestion des rapports volumineux

--[[
═══════════════════════════════════════════════════════════════
  INSTRUCTIONS D'UTILISATION :
  
  1. Colle ce script dans ton executor (sur Android)
  2. Un bouton "🔒 AUDIT" apparaît en haut à droite
  3. Clique dessus pour lancer l'analyse complète
  4. L'analyse prend 3-5 secondes
  5. Un rapport détaillé s'affiche
  
  ✅ OPTIMISÉ POUR ANDROID
  ✅ Gestion automatique des rapports volumineux (>200k chars)
  ✅ Mode compact pour réduire la taille
  
  ⚠️ DEBUG MODE: Active pour voir les erreurs détaillées
═══════════════════════════════════════════════════════════════
--]]

-- MODE DEBUG (change en true pour voir où ça plante)
local DEBUG_MODE = false

-- MODE COMPACT (réduit la taille du rapport de ~50%)
local COMPACT_MODE = true

local currentSection = "NONE"

local function debugPrint(section, message)
    currentSection = section
    if DEBUG_MODE then
        print("[DEBUG - " .. section .. "] " .. message)
    end
end

-- Fonction safe pour les appels potentiellement dangereux
local function safeCall(func, errorContext)
    local success, result = pcall(func)
    if not success then
        debugPrint("ERROR", errorContext .. ": " .. tostring(result))
        if DEBUG_MODE then
            warn("⚠️ Error in section: " .. currentSection)
            warn("⚠️ Context: " .. errorContext)
            warn("⚠️ Details: " .. tostring(result))
        end
        return nil, result
    end
    return result, nil
end

-- Fonction safe pour GetDescendants
local function safeGetDescendants(parent, contextName)
    local descendants = {}
    local success, err = pcall(function()
        descendants = parent:GetDescendants()
    end)
    
    if not success then
        debugPrint("ERROR", "Failed to get descendants from " .. contextName .. ": " .. tostring(err))
        return {}
    end
    
    debugPrint("SAFE_GET", contextName .. " returned " .. #descendants .. " objects")
    return descendants
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- Fonction principale d'audit
local function runSecurityAudit()
    
-- Réinitialise les variables
char = player.Character or player.CharacterAdded:Wait()

debugPrint("INIT", "Starting security audit...")

local dump = {}
local stats = {
    remotes=0, values=0, scripts=0, vulnerabilities=0,
    suspiciousPatterns=0, criticalIssues=0
}

local function log(t) table.insert(dump, t) end
local function header(t) log(""); log("═══════════ " .. t .. " ═══════════") end
local function vuln(t) stats.vulnerabilities += 1; log("⚠️ VULN: " .. t) end
local function critical(t) stats.criticalIssues += 1; log("🔴 CRITICAL: " .. t) end
local function pattern(t) stats.suspiciousPatterns += 1; log("🔍 PATTERN: " .. t) end

log("╔════════════════════════════════════════════╗")
log("║  ADVANCED RNG EXPLOIT VECTOR ANALYSIS     ║")
log("║           ANDROID OPTIMIZED               ║")
log("╚════════════════════════════════════════════╝")
log("Player: " .. player.Name .. " | ID: " .. player.UserId)
log("Platform: " .. (UIS.TouchEnabled and "📱 Mobile" or "💻 Desktop"))
log("Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S"))
log("Mode: " .. (COMPACT_MODE and "Compact" or "Verbose"))
log("")

--------------------------------------------------
-- 🔴 SECTION 1: REMOTES + DATASTORE PATTERNS
--------------------------------------------------
debugPrint("SECTION 1", "Scanning remotes...")
header("1. REMOTE EVENTS + DATASTORE LEAK PATTERNS")

local dangerousPatterns = {
    "save", "load", "data", "profile", "session", "sync", "update",
    "give", "add", "reward", "claim", "redeem", "purchase", "buy",
    "roll", "spin", "hatch", "open", "unlock", "chance", "luck",
    "admin", "mod", "dev", "debug", "test", "cheat",
    "kick", "ban", "verify", "check", "validate"
}

local remotesByCategory = {
    datastore = {},
    economy = {},
    rng = {},
    admin = {},
    suspicious = {},
    other = {}
}

debugPrint("SECTION 1", "Getting ReplicatedStorage descendants...")
local rsDescendants = safeGetDescendants(RS, "ReplicatedStorage")

debugPrint("SECTION 1", "Processing " .. #rsDescendants .. " objects...")

for _, obj in ipairs(rsDescendants) do
    pcall(function()
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            stats.remotes += 1
            local name = obj.Name:lower()
            local fullPath = obj:GetFullName()
            local category = "other"
            
            for _, keyword in ipairs(dangerousPatterns) do
                if name:match(keyword) then
                    if keyword:match("save") or keyword:match("load") or keyword:match("data") 
                    or keyword:match("profile") or keyword:match("session") then
                        category = "datastore"
                        critical("DataStore pattern: " .. obj.Name)
                    elseif keyword:match("give") or keyword:match("add") or keyword:match("reward") 
                    or keyword:match("purchase") then
                        category = "economy"
                        critical("Economy remote: " .. obj.Name)
                    elseif keyword:match("roll") or keyword:match("spin") or keyword:match("hatch") 
                    or keyword:match("luck") then
                        category = "rng"
                        vuln("RNG trigger: " .. obj.Name)
                    elseif keyword:match("admin") or keyword:match("mod") or keyword:match("dev") then
                        category = "admin"
                        critical("ADMIN REMOTE: " .. obj.Name)
                    end
                    break
                end
            end
            
            table.insert(remotesByCategory[category], obj)
            
            -- En mode compact, on log seulement les remotes critiques
            if not COMPACT_MODE or category ~= "other" then
                log(obj.ClassName .. " | " .. fullPath .. " [" .. category:upper() .. "]")
            end
            
            -- Détection de noms trop génériques
            if #name <= 4 or name:match("^event%d*$") or name:match("^remote%d*$") then
                pattern("Generic name: " .. obj.Name)
            end
        elseif obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            if not COMPACT_MODE then
                log("Bindable | " .. obj:GetFullName())
            end
            pattern("Internal comm: " .. obj.Name)
        end
    end)
end

debugPrint("SECTION 1", "Remotes scanned successfully")

log("")
log("📊 Remote Distribution:")
for category, list in pairs(remotesByCategory) do
    if #list > 0 then
        log("  " .. category:upper() .. ": " .. #list)
    end
end

--------------------------------------------------
-- 🔴 SECTION 2: CLIENT VALUES + ATTRIBUTES
--------------------------------------------------
debugPrint("SECTION 2", "Scanning client values...")
header("2. CLIENT-SIDE VALUES & ATTRIBUTES")

local rngRelatedNames = {
    "luck", "chance", "multi", "boost", "aura", "power", "streak",
    "combo", "multiplier", "bonus", "buff", "pity", "guarantee"
}

local economyNames = {
    "coin", "cash", "money", "currency", "gem", "diamond", "credit",
    "token", "point", "balance", "wallet"
}

local function checkValue(obj, location)
    stats.values += 1
    local name = obj.Name:lower()
    local value = tostring(obj.Value)
    
    -- En mode compact, on ne log que les valeurs sensibles
    local isSensitive = false
    
    for _, keyword in ipairs(rngRelatedNames) do
        if name:match(keyword) then
            critical("RNG MODIFIER: " .. obj.Name .. " = " .. value)
            isSensitive = true
            break
        end
    end
    
    if not isSensitive then
        for _, keyword in ipairs(economyNames) do
            if name:match(keyword) then
                critical("CURRENCY: " .. obj.Name .. " = " .. value)
                isSensitive = true
                break
            end
        end
    end
    
    if not COMPACT_MODE and not isSensitive then
        log(obj.ClassName .. " | " .. location .. "." .. obj.Name .. " = " .. value)
        vuln("Value exposed: " .. obj.Name)
    end
end

-- Player values
debugPrint("SECTION 2", "Checking player descendants...")
local playerDescendants = safeGetDescendants(player, "Player")

for _, obj in ipairs(playerDescendants) do
    if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") 
    or obj:IsA("StringValue") then
        checkValue(obj, "Player")
    end
end

-- Character values
if char then
    debugPrint("SECTION 2", "Checking character descendants...")
    local charDescendants = safeGetDescendants(char, "Character")
    
    for _, obj in ipairs(charDescendants) do
        if obj:IsA("ValueBase") then
            checkValue(obj, "Character")
        end
    end
end

-- Attributes
log("")
log("🔍 Attributes Analysis:")

local function auditAttributes(parent, parentName)
    local count = 0
    pcall(function()
        local attrs = parent:GetAttributes()
        for name, value in pairs(attrs) do
            count += 1
            
            local lowerName = name:lower()
            local isImportant = false
            
            for _, keyword in ipairs(rngRelatedNames) do
                if lowerName:match(keyword) then
                    critical("RNG attribute: " .. name)
                    isImportant = true
                    break
                end
            end
            
            if not isImportant then
                for _, keyword in ipairs(economyNames) do
                    if lowerName:match(keyword) then
                        critical("Economy attribute: " .. name)
                        isImportant = true
                        break
                    end
                end
            end
            
            if not COMPACT_MODE or isImportant then
                log("  " .. parentName .. "." .. name .. " = " .. tostring(value))
            end
        end
    end)
    return count
end

debugPrint("SECTION 2", "Checking attributes...")
local playerAttrCount = auditAttributes(player, "Player")
local charAttrCount = char and auditAttributes(char, "Character") or 0

if playerAttrCount > 0 or charAttrCount > 0 then
    vuln("Total attributes: " .. (playerAttrCount + charAttrCount))
end

--------------------------------------------------
-- 🔴 SECTION 3: LEADERSTATS (ECONOMY LEAK)
--------------------------------------------------
debugPrint("SECTION 3", "Checking leaderstats...")
header("3. LEADERSTATS & ECONOMY")

local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
    critical("Leaderstats exists (client-visible economy)")
    for _, stat in ipairs(leaderstats:GetChildren()) do
        log("  " .. stat.Name .. " = " .. tostring(stat.Value))
        critical("Stat exposed: " .. stat.Name)
    end
else
    log("✅ No leaderstats (good)")
end

-- UI economy displays (version compacte)
if not COMPACT_MODE then
    log("")
    log("UI Economy Elements:")
    local guiDescendants = safeGetDescendants(player.PlayerGui, "PlayerGui")
    local uiEcoCount = 0
    for _, obj in ipairs(guiDescendants) do
        pcall(function()
            if obj:IsA("TextLabel") then
                local text = obj.Text:lower()
                if text:match("coin") or text:match("gem") or text:match("cash") then
                    uiEcoCount += 1
                end
            end
        end)
    end
    if uiEcoCount > 0 then
        pattern(uiEcoCount .. " currency displays in UI")
    end
end

--------------------------------------------------
-- 🔴 SECTION 4: INPUT BINDINGS
--------------------------------------------------
header("4. INPUT SERVICE BINDINGS")

log("⚠️ ContextActionService & UserInputService")
log("  Can be hooked for auto-roll exploits")
log("")

-- Recherche de boutons de roll/spin
log("🎰 RNG Trigger Buttons:")
local rollButtons = {}
for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        local name = obj.Name:lower()
        local text = obj:IsA("TextButton") and obj.Text:lower() or ""
        
        if name:match("roll") or name:match("spin") or name:match("hatch") 
        or name:match("open") or text:match("roll") or text:match("spin") then
            table.insert(rollButtons, obj)
            critical("RNG button: " .. obj.Name)
        end
    end
end

log("Total RNG buttons: " .. #rollButtons)

--------------------------------------------------
-- 🔴 SECTION 5: MARKETPLACE
--------------------------------------------------
header("5. MARKETPLACE & MONETIZATION")

log("🛒 GamePass/Product References:")
local gamepassCount = 0
local productCount = 0

for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("IntValue") then
        local name = obj.Name:lower()
        if name:match("gamepass") or name:match("pass") then
            gamepassCount += 1
            if not COMPACT_MODE then
                vuln("GamePass ID: " .. obj.Value)
            end
        elseif name:match("product") or name:match("shop") then
            productCount += 1
            if not COMPACT_MODE then
                vuln("Product ID: " .. obj.Value)
            end
        end
    end
end

log("  GamePasses found: " .. gamepassCount)
log("  Products found: " .. productCount)

if gamepassCount > 0 or productCount > 0 then
    critical("Monetization IDs exposed - possible bypass")
end

--------------------------------------------------
-- 🔴 SECTION 6: TIMERS & COOLDOWNS
--------------------------------------------------
header("6. CLIENT-SIDE TIMERS")

log("⏱️ Cooldown Detection:")
local cooldownCount = 0

for _, obj in ipairs(player:GetDescendants()) do
    local name = obj.Name:lower()
    if (name:match("cooldown") or name:match("timer") or name:match("debounce")) 
    and obj:IsA("ValueBase") then
        cooldownCount += 1
        critical("CLIENT COOLDOWN: " .. obj.Name .. " = " .. tostring(obj.Value))
    end
end

log("Total cooldowns found: " .. cooldownCount)
log("")
log("⚠️ ALL CLIENT TIMERS ARE BYPASSABLE")

--------------------------------------------------
-- 🔴 SECTION 7: SCRIPTS ANALYSIS
--------------------------------------------------
header("7. LOCALSCRIPTS & CODE")

local scriptCategories = {
    input = {},
    timer = {},
    rng = {},
    anticheat = {},
    other = {}
}

for _, location in ipairs({RS, player, player.PlayerGui}) do
    for _, script in ipairs(location:GetDescendants()) do
        if script:IsA("LocalScript") then
            stats.scripts += 1
            local name = script.Name:lower()
            local category = "other"
            
            if name:match("input") or name:match("control") then
                category = "input"
                pattern("Input script: " .. script.Name)
            elseif name:match("timer") or name:match("cooldown") then
                category = "timer"
                critical("Timer script: " .. script.Name)
            elseif name:match("roll") or name:match("spin") or name:match("hatch") then
                category = "rng"
                critical("RNG logic: " .. script.Name)
            elseif name:match("anti") or name:match("cheat") then
                category = "anticheat"
                vuln("Anti-cheat exposed: " .. script.Name)
            end
            
            table.insert(scriptCategories[category], script)
            
            if not COMPACT_MODE or category ~= "other" then
                log("[" .. category:upper() .. "] " .. script.Name)
            end
        end
    end
end

log("")
log("📊 Script Distribution:")
for cat, scripts in pairs(scriptCategories) do
    if #scripts > 0 then
        log("  " .. cat:upper() .. ": " .. #scripts)
    end
end

--------------------------------------------------
-- 🔴 SECTION 8: MODULES
--------------------------------------------------
header("8. MODULESCRIPTS")

local criticalModules = 0
for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        local name = obj.Name:lower()
        if name:match("rng") or name:match("gacha") or name:match("luck") 
        or name:match("config") or name:match("data") then
            criticalModules += 1
            critical("Sensitive module: " .. obj.Name)
        end
    end
end

log("Critical modules found: " .. criticalModules)
if criticalModules > 0 then
    vuln("Modules can be require()'d by exploits")
end

--------------------------------------------------
-- 🔴 SECTION 9: WORKSPACE INTERACTIONS
--------------------------------------------------
header("9. WORKSPACE INTERACTIONS")

local interactions = {click = 0, prox = 0, touch = 0}

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ClickDetector") then
        interactions.click += 1
        if obj.MaxActivationDistance > 100 then
            vuln("Excessive range ClickDetector")
        end
        local parent = obj.Parent
        if parent and (parent.Name:lower():match("roll") or parent.Name:lower():match("spin")) then
            critical("Physical RNG trigger: " .. parent.Name)
        end
    elseif obj:IsA("ProximityPrompt") then
        interactions.prox += 1
    elseif obj:IsA("TouchTransmitter") then
        interactions.touch += 1
    end
end

log("  ClickDetectors: " .. interactions.click)
log("  ProximityPrompts: " .. interactions.prox)
log("  TouchTransmitters: " .. interactions.touch)

--------------------------------------------------
-- 🔴 SECTION 10: RNG SPECIFIC
--------------------------------------------------
header("10. RNG MECHANICS")

log("🎰 RNG System Analysis:")

-- Pity systems
local pityCount = 0
for _, obj in ipairs(player:GetDescendants()) do
    if obj.Name:lower():match("pity") or obj.Name:lower():match("guarantee") then
        pityCount += 1
        critical("Pity counter: " .. obj.Name)
    end
end

-- Luck multipliers
local luckValues = {}
for _, obj in ipairs(player:GetDescendants()) do
    local name = obj.Name:lower()
    if (name:match("luck") or name:match("multi") or name:match("boost")) 
    and obj:IsA("ValueBase") then
        table.insert(luckValues, obj)
        critical("Luck value: " .. obj.Name .. " = " .. tostring(obj.Value))
    end
end

log("  Pity counters: " .. pityCount)
log("  Luck values: " .. #luckValues)

-- Inventory
local inventoryCount = 0
for _, obj in ipairs(player:GetDescendants()) do
    if obj:IsA("Folder") and (obj.Name:lower():match("inventory") 
    or obj.Name:lower():match("collection")) then
        inventoryCount += 1
        log("Inventory: " .. obj.Name .. " (" .. #obj:GetChildren() .. " items)")
    end
end

--------------------------------------------------
-- 🔴 SECTION 11: ADVANCED PATTERNS
--------------------------------------------------
header("11. ADVANCED PATTERNS")

-- Debounce côté client
local debounceCount = 0
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("BoolValue") and obj.Name:lower():match("debounce") then
        debounceCount += 1
    end
end

if debounceCount > 0 then
    critical(debounceCount .. " client-side debounces (bypassable)")
end

-- Audio cues
local soundCues = 0
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Sound") then
        local name = obj.Name:lower()
        if name:match("win") or name:match("rare") or name:match("legendary") then
            soundCues += 1
        end
    end
end

if soundCues > 0 then
    pattern(soundCues .. " result audio cues (readable by exploits)")
end

--------------------------------------------------
-- 🔴 SECTION 12: ANTI-CHEAT
--------------------------------------------------
header("12. ANTI-CHEAT ANALYSIS")

local anticheatScripts = 0
for _, script in ipairs(game:GetDescendants()) do
    if script:IsA("LocalScript") then
        local name = script.Name:lower()
        if name:match("anti") or name:match("detect") or name:match("cheat") then
            anticheatScripts += 1
        end
    end
end

if anticheatScripts > 0 then
    critical(anticheatScripts .. " anti-cheat scripts on client!")
    log("⚠️ Can be bypassed with hookfunction()")
    log("✅ Recommendation: Move to ServerScriptService")
else
    log("✅ No visible client-side anti-cheat")
end

--------------------------------------------------
-- 🔴 SECTION 13: DATA PERSISTENCE
--------------------------------------------------
header("13. DATA PERSISTENCE")

local saveRemotes = {}
for _, remote in ipairs(RS:GetDescendants()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        local name = remote.Name:lower()
        if name:match("save") or name:match("load") or name:match("update") then
            table.insert(saveRemotes, remote)
        end
    end
end

if #saveRemotes > 0 then
    critical(#saveRemotes .. " data persistence remotes")
    log("⚠️ Exploit scenarios: duplication, rollback, injection")
end

--------------------------------------------------
-- 📊 FINAL STATISTICS
--------------------------------------------------
header("AUDIT SUMMARY")

log("📊 Statistics:")
log("  Total Remotes: " .. stats.remotes)
log("  Total Values: " .. stats.values)
log("  Total Scripts: " .. stats.scripts)
log("")
log("🚨 Issues Found:")
log("  Vulnerabilities: " .. stats.vulnerabilities)
log("  Critical Issues: " .. stats.criticalIssues)
log("  Suspicious Patterns: " .. stats.suspiciousPatterns)
log("")

local totalIssues = stats.vulnerabilities + stats.criticalIssues + stats.suspiciousPatterns
local securityScore = math.max(0, 100 - (totalIssues * 2))

log("═══════════════════════════════════════")
log("SECURITY SCORE: " .. securityScore .. "/100")
log("═══════════════════════════════════════")

if stats.criticalIssues > 5 then
    log("🔴 RATING: CRITICAL")
    log("Game is HIGHLY exploitable")
elseif stats.criticalIssues > 0 then
    log("🟠 RATING: HIGH RISK")
    log("Major vulnerabilities present")
elseif stats.vulnerabilities > 10 then
    log("🟡 RATING: MODERATE")
    log("Some concerns exist")
else
    log("🟢 RATING: ACCEPTABLE")
    log("Good security foundation")
end

log("")
log("Top Priorities:")
if #remotesByCategory.datastore > 0 then
    log("  1. DataStore leaks (" .. #remotesByCategory.datastore .. ")")
end
if #remotesByCategory.economy > 0 then
    log("  2. Economy remotes (" .. #remotesByCategory.economy .. ")")
end
if #remotesByCategory.rng > 0 then
    log("  3. RNG triggers (" .. #remotesByCategory.rng .. ")")
end
if #luckValues > 0 then
    log("  4. Client luck values (" .. #luckValues .. ")")
end

log("")
log("📚 Best Practices:")
log("  • Never trust client input")
log("  • All rewards server-side")
log("  • Use remote rate limiting")
log("  • Validate every argument")
log("  • Server-side cooldowns")
log("  • Regular security audits")

--------------------------------------------------
-- 💾 SAVE & DISPLAY
--------------------------------------------------
local finalText = table.concat(dump, "\n")

-- Storage avec chunking pour contourner la limite de 200k chars
local auditFolder = Instance.new("Folder")
auditFolder.Name = "SecurityAudit_" .. os.time()
auditFolder.Parent = player

-- Découpe le texte en morceaux de 150k caractères
local MAX_CHUNK_SIZE = 150000
local chunks = {}
local totalLength = #finalText

for i = 1, totalLength, MAX_CHUNK_SIZE do
    local chunk = finalText:sub(i, math.min(i + MAX_CHUNK_SIZE - 1, totalLength))
    table.insert(chunks, chunk)
end

-- Crée un StringValue pour chaque chunk
for i, chunk in ipairs(chunks) do
    local sv = Instance.new("StringValue")
    sv.Name = "Part" .. i
    sv.Value = chunk
    sv.Parent = auditFolder
end

-- Métadonnées
local metaFolder = Instance.new("Folder")
metaFolder.Name = "Metadata"
metaFolder.Parent = auditFolder

local function createMeta(name, value)
    local v = Instance.new("IntValue")
    v.Name = name
    v.Value = value
    v.Parent = metaFolder
end

createMeta("Vulnerabilities", stats.vulnerabilities)
createMeta("CriticalIssues", stats.criticalIssues)
createMeta("SuspiciousPatterns", stats.suspiciousPatterns)
createMeta("SecurityScore", securityScore)
createMeta("Remotes", stats.remotes)
createMeta("Values", stats.values)
createMeta("Scripts", stats.scripts)
createMeta("Chunks", #chunks)

-- UI Display (OPTIMISÉE POUR MOBILE)
local gui = Instance.new("ScreenGui")
gui.Name = "SecurityAuditUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

-- Background
local overlay = Instance.new("Frame", gui)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0

-- Main frame (plus grand sur mobile)
local frame = Instance.new("Frame", overlay)
frame.Size = UDim2.fromScale(0.95, 0.9)
frame.Position = UDim2.fromScale(0.025, 0.05)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
frame.BorderSizePixel = 3
frame.BorderColor3 = securityScore > 70 and Color3.fromRGB(50, 200, 50) 
                     or securityScore > 40 and Color3.fromRGB(255, 150, 0)
                     or Color3.fromRGB(255, 50, 50)

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

-- Title bar (plus grande sur mobile)
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔒 SECURITY AUDIT\nScore: " .. securityScore .. "/100"
title.TextColor3 = securityScore > 70 and Color3.fromRGB(50, 255, 50)
                   or securityScore > 40 and Color3.fromRGB(255, 200, 0)
                   or Color3.fromRGB(255, 80, 80)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

-- Stats panel (optimisé mobile)
local statsPanel = Instance.new("Frame", frame)
statsPanel.Size = UDim2.new(1, -20, 0, 80)
statsPanel.Position = UDim2.new(0, 10, 0, 70)
statsPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
statsPanel.BorderSizePixel = 1
statsPanel.BorderColor3 = Color3.fromRGB(40, 40, 40)

local statsCorner = Instance.new("UICorner", statsPanel)
statsCorner.CornerRadius = UDim.new(0, 6)

local function createStat(text, position, color)
    local label = Instance.new("TextLabel", statsPanel)
    label.Size = UDim2.new(0.5, -5, 0.5, -5)
    label.Position = UDim2.new((position % 2) * 0.5, 2, math.floor(position / 2) * 0.5, 2)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextWrapped = true
end

createStat("🚨 Vulns\n" .. stats.vulnerabilities, 0, Color3.fromRGB(255, 150, 0))
createStat("🔴 Critical\n" .. stats.criticalIssues, 1, Color3.fromRGB(255, 80, 80))
createStat("🔍 Patterns\n" .. stats.suspiciousPatterns, 2, Color3.fromRGB(150, 150, 255))
createStat("📡 Remotes\n" .. stats.remotes, 3, Color3.fromRGB(100, 200, 255))

-- ScrollingFrame (optimisé mobile avec gros scrollbar)
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 1, -240)
scroll.Position = UDim2.new(0, 10, 0, 160)
scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
scroll.BorderSizePixel = 1
scroll.BorderColor3 = Color3.fromRGB(30, 30, 30)
scroll.ScrollBarThickness = 15 -- Plus épais pour mobile
scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)

local scrollCorner = Instance.new("UICorner", scroll)
scrollCorner.CornerRadius = UDim.new(0, 6)

-- TextBox
local box = Instance.new("TextBox", scroll)
box.Size = UDim2.new(1, -20, 0, 0)
box.AutomaticSize = Enum.AutomaticSize.Y
box.BackgroundTransparency = 1
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextSize = 13 -- Légèrement plus gros pour mobile
box.Font = Enum.Font.Code
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = false
box.Text = finalText
box.TextColor3 = Color3.fromRGB(0, 255, 120)
box.RichText = false

-- Button panel (plus grand sur mobile)
local buttonPanel = Instance.new("Frame", frame)
buttonPanel.Size = UDim2.new(1, 0, 0, 70)
buttonPanel.Position = UDim2.new(0, 0, 1, -70)
buttonPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonPanel.BorderSizePixel = 0

-- Close button
local closeBtn = Instance.new("TextButton", buttonPanel)
closeBtn.Size = UDim2.new(0, 100, 0, 50)
closeBtn.Position = UDim2.new(1, -110, 0.5, -25)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.Text = "✖ CLOSE"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15

local closeBtnCorner = Instance.new("UICorner", closeBtn)
closeBtnCorner.CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Copy All button (NOUVEAU)
local copyBtn = Instance.new("TextButton", buttonPanel)
copyBtn.Size = UDim2.new(0, 120, 0, 50)
copyBtn.Position = UDim2.new(0.5, -60, 0.5, -25)
copyBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
copyBtn.Text = "📄 COPY ALL"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 15

local copyBtnCorner = Instance.new("UICorner", copyBtn)
copyBtnCorner.CornerRadius = UDim.new(0, 8)

copyBtn.MouseButton1Click:Connect(function()
    -- Utilise setclipboard si disponible (la plupart des executors)
    if setclipboard then
        setclipboard(finalText)
        copyBtn.Text = "✓ COPIED!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        task.wait(2)
        copyBtn.Text = "📄 COPY ALL"
        copyBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
        -- Fallback: sélectionne tout le texte
        box:CaptureFocus()
        box.CursorPosition = #box.Text + 1
        box.SelectionStart = 1
        copyBtn.Text = "✓ SELECTED"
        copyBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        task.wait(2)
        copyBtn.Text = "📄 COPY ALL"
        copyBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    end
end)

-- Select button
local selectBtn = Instance.new("TextButton", buttonPanel)
selectBtn.Size = UDim2.new(0, 100, 0, 50)
selectBtn.Position = UDim2.new(0, 10, 0.5, -25)
selectBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
selectBtn.Text = "📋 SELECT"
selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectBtn.Font = Enum.Font.GothamBold
selectBtn.TextSize = 15

local selectBtnCorner = Instance.new("UICorner", selectBtn)
selectBtnCorner.CornerRadius = UDim.new(0, 8)

selectBtn.MouseButton1Click:Connect(function()
    box:CaptureFocus()
    box.CursorPosition = #box.Text + 1
    box.SelectionStart = 1
    selectBtn.Text = "✓ DONE"
    selectBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    task.wait(1.5)
    selectBtn.Text = "📋 SELECT"
    selectBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
end)

-- Update scroll canvas
scroll.CanvasSize = UDim2.new(0, 0, 0, box.AbsoluteSize.Y + 20)
box:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, box.AbsoluteSize.Y + 20)
end)

-- Hover effects
local function addHover(button, normal, hover)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hover
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = normal
    end)
end

addHover(closeBtn, Color3.fromRGB(220, 60, 60), Color3.fromRGB(255, 80, 80))
addHover(selectBtn, Color3.fromRGB(60, 150, 255), Color3.fromRGB(80, 170, 255))
addHover(copyBtn, Color3.fromRGB(100, 200, 100), Color3.fromRGB(120, 220, 120))

-- Console output
warn("╔════════════════════════════════════════════╗")
warn("║   SECURITY AUDIT COMPLETE (ANDROID)       ║")
warn("╚════════════════════════════════════════════╝")
warn("")
warn("📊 Results:")
warn("  • Score: " .. securityScore .. "/100")
warn("  • Vulnerabilities: " .. stats.vulnerabilities)
warn("  • Critical: " .. stats.criticalIssues)
warn("  • Patterns: " .. stats.suspiciousPatterns)
warn("")
warn("💾 Saved in: Player." .. auditFolder.Name)
warn("📄 Report chunks: " .. #chunks)
warn("📱 UI optimized for mobile")
warn("")

if stats.criticalIssues > 5 then
    warn("🔴 CRITICAL: Major security flaws!")
elseif stats.criticalIssues > 0 then
    warn("🟠 WARNING: Significant vulnerabilities")
else
    warn("✅ Good! No critical issues")
end

end -- Fin de runSecurityAudit()

--================================================
-- 🎮 LAUNCHER BUTTON (OPTIMISÉ MOBILE)
--================================================

if player.PlayerGui:FindFirstChild("SecurityAuditLauncher") then
    player.PlayerGui.SecurityAuditLauncher:Destroy()
end

local launcherGui = Instance.new("ScreenGui")
launcherGui.Name = "SecurityAuditLauncher"
launcherGui.ResetOnSpawn = false
launcherGui.IgnoreGuiInset = true
launcherGui.DisplayOrder = 999
launcherGui.Parent = player.PlayerGui

-- Bouton plus grand pour mobile
local launchButton = Instance.new("TextButton", launcherGui)
launchButton.Size = UDim2.new(0, 120, 0, 60)
launchButton.Position = UDim2.new(1, -130, 0, 10)
launchButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
launchButton.BorderSizePixel = 2
launchButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
launchButton.Text = "🔒 AUDIT"
launchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
launchButton.Font = Enum.Font.GothamBold
launchButton.TextSize = 18
launchButton.AutoButtonColor = false

local btnCorner = Instance.new("UICorner", launchButton)
btnCorner.CornerRadius = UDim.new(0, 10)

local gradient = Instance.new("UIGradient", launchButton)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
}
gradient.Rotation = 90

-- Status
local statusLabel = Instance.new("TextLabel", launcherGui)
statusLabel.Size = UDim2.new(0, 120, 0, 25)
statusLabel.Position = UDim2.new(1, -130, 0, 75)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 12
statusLabel.Visible = false

local isRunning = false
local lastRunTime = 0
local COOLDOWN = 5

local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
    statusLabel.Visible = true
    task.delay(3, function()
        if statusLabel.Text == text then
            statusLabel.Visible = false
        end
    end)
end

launchButton.MouseButton1Click:Connect(function()
    local timeSince = tick() - lastRunTime
    if timeSince < COOLDOWN then
        local remaining = math.ceil(COOLDOWN - timeSince)
        updateStatus("Wait " .. remaining .. "s", Color3.fromRGB(255, 150, 0))
        return
    end
    
    if isRunning then
        updateStatus("Running...", Color3.fromRGB(255, 100, 100))
        return
    end
    
    isRunning = true
    lastRunTime = tick()
    
    launchButton.Text = "⏳ SCAN"
    launchButton.BackgroundColor3 = Color3.fromRGB(80, 80, 20)
    updateStatus("Analyzing...", Color3.fromRGB(255, 200, 0))
    
    task.spawn(function()
        local success, errorMsg = pcall(function()
            local oldReport = player.PlayerGui:FindFirstChild("SecurityAuditUI")
            if oldReport then
                oldReport:Destroy()
                task.wait(0.1)
            end
            
            runSecurityAudit()
        end)
        
        task.wait(0.5)
        isRunning = false
        launchButton.Text = "🔒 AUDIT"
        launchButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        if success then
            updateStatus("✓ Complete!", Color3.fromRGB(100, 255, 100))
        else
            updateStatus("✗ Error", Color3.fromRGB(255, 100, 100))
            warn("❌ AUDIT ERROR:")
            warn(tostring(errorMsg))
        end
    end)
end)

-- Version label
local versionLabel = Instance.new("TextLabel", launcherGui)
versionLabel.Size = UDim2.new(0, 120, 0, 18)
versionLabel.Position = UDim2.new(1, -130, 0, 105)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v3.0 Android"
versionLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
versionLabel.Font = Enum.Font.Code
versionLabel.TextSize = 10

-- Drag functionality
local dragging = false
local dragInput, mousePos, framePos

launchButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = launchButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

launchButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        launchButton.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
        statusLabel.Position = UDim2.new(
            launchButton.Position.X.Scale,
            launchButton.Position.X.Offset,
            launchButton.Position.Y.Scale,
            launchButton.Position.Y.Offset + 65
        )
        versionLabel.Position = UDim2.new(
            launchButton.Position.X.Scale,
            launchButton.Position.X.Offset,
            launchButton.Position.Y.Scale,
            launchButton.Position.Y.Offset + 95
        )
    end
end)

-- Notifications
print("╔════════════════════════════════════════════╗")
print("║  SECURITY AUDIT TOOL - ANDROID READY      ║")
print("╚════════════════════════════════════════════╝")
print("")
print("✅ Launcher created (top-right)")
print("📱 Optimized for mobile/touch")
print("🔄 Draggable button")
print("⏱️  ~3-5 seconds scan time")
print("💾 Auto-chunking for large reports")
print("📊 Compact mode enabled")
print("")
print("💡 Tap '🔒 AUDIT' to start")
print("⏳ Cooldown: " .. COOLDOWN .. "s between scans")
print("")
