-- RNG GAME - COMPLETE EXPLOIT VECTOR AUDIT
-- Version avancée avec détection des patterns d'attaque réels

--[[
═══════════════════════════════════════════════════════════════
  INSTRUCTIONS D'UTILISATION :
  
  1. Colle ce script dans ton executor
  2. Un bouton "🔒 AUDIT" apparaît en haut à droite
  3. Clique dessus pour lancer l'analyse complète
  4. L'analyse prend 3-5 secondes
  5. Un rapport détaillé s'affiche
  
  Le bouton reste accessible pour relancer l'audit à tout moment
  
  ⚠️ DEBUG MODE: Active pour voir les erreurs détaillées
═══════════════════════════════════════════════════════════════
--]]

-- MODE DEBUG (change en true pour voir où ça plante)
local DEBUG_MODE = true

local function debugPrint(section, message)
    if DEBUG_MODE then
        print("[DEBUG - " .. section .. "] " .. message)
    end
end

-- Fonction safe pour les appels potentiellement dangereux
local function safeCall(func, errorContext)
    local success, result = pcall(func)
    if not success then
        debugPrint("ERROR", errorContext .. ": " .. tostring(result))
        return nil, result
    end
    return result, nil
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local MPS = game:GetService("MarketplaceService")
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
log("╚════════════════════════════════════════════╝")
log("Player: " .. player.Name .. " | ID: " .. player.UserId)
log("Platform: " .. (UIS.TouchEnabled and "Mobile" or "Desktop"))
log("Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S"))
log("")

--------------------------------------------------
-- 🔴 SECTION 1: REMOTES + DATASTORE PATTERNS
--------------------------------------------------
debugPrint("SECTION 1", "Scanning remotes...")
header("1. REMOTE EVENTS + DATASTORE LEAK PATTERNS")

local dangerousPatterns = {
    -- DataStore related
    "save", "load", "data", "profile", "session", "sync", "update",
    -- Rewards/Economy
    "give", "add", "reward", "claim", "redeem", "purchase", "buy",
    -- RNG specific
    "roll", "spin", "hatch", "open", "unlock", "chance", "luck",
    -- Admin/Debug
    "admin", "mod", "dev", "debug", "test", "cheat",
    -- Anti-cheat bypass
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

for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        stats.remotes += 1
        local name = obj.Name:lower()
        local fullPath = obj:GetFullName()
        local category = "other"
        
        -- Catégorisation intelligente
        for _, keyword in ipairs(dangerousPatterns) do
            if name:match(keyword) then
                if keyword:match("save") or keyword:match("load") or keyword:match("data") 
                or keyword:match("profile") or keyword:match("session") then
                    category = "datastore"
                    critical("DataStore pattern exposed: " .. obj.Name)
                elseif keyword:match("give") or keyword:match("add") or keyword:match("reward") 
                or keyword:match("purchase") then
                    category = "economy"
                    critical("Economy remote exposed: " .. obj.Name)
                elseif keyword:match("roll") or keyword:match("spin") or keyword:match("hatch") 
                or keyword:match("luck") then
                    category = "rng"
                    vuln("RNG trigger remote: " .. obj.Name)
                elseif keyword:match("admin") or keyword:match("mod") or keyword:match("dev") then
                    category = "admin"
                    critical("ADMIN REMOTE EXPOSED: " .. obj.Name)
                end
                break
            end
        end
        
        table.insert(remotesByCategory[category], obj)
        log(obj.ClassName .. " | " .. fullPath .. " [" .. category:upper() .. "]")
        
        -- Détection de noms trop génériques (faciles à deviner)
        if #name <= 4 or name:match("^event%d*$") or name:match("^remote%d*$") then
            pattern("Generic remote name easy to bruteforce: " .. obj.Name)
        end
    elseif obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
        log("Bindable | " .. obj:GetFullName())
        pattern("Internal communication visible: " .. obj.Name)
    end
end

log("")
log("📊 Remote Distribution:")
for category, list in pairs(remotesByCategory) do
    if #list > 0 then
        log("  " .. category:upper() .. ": " .. #list .. " remotes")
    end
end

--------------------------------------------------
-- 🔴 SECTION 2: CLIENT VALUES + ATTRIBUTES
--------------------------------------------------
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
    
    log(obj.ClassName .. " | " .. location .. "." .. obj.Name .. " = " .. value)
    
    -- RNG modifiers
    for _, keyword in ipairs(rngRelatedNames) do
        if name:match(keyword) then
            critical("RNG MODIFIER ON CLIENT: " .. obj.Name .. " = " .. value)
            return
        end
    end
    
    -- Economy values
    for _, keyword in ipairs(economyNames) do
        if name:match(keyword) then
            critical("CURRENCY ON CLIENT: " .. obj.Name .. " = " .. value)
            return
        end
    end
    
    vuln("Value exposed: " .. obj.Name)
end

-- Player values
for _, obj in ipairs(player:GetDescendants()) do
    if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") 
    or obj:IsA("StringValue") then
        checkValue(obj, "Player")
    end
end

-- Character values
if char then
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("ValueBase") then
            checkValue(obj, "Character")
        end
    end
end

-- Attributes (SOUVENT OUBLIÉS)
log("")
log("🔍 Attributes Analysis:")

local function auditAttributes(parent, parentName)
    local attrs = parent:GetAttributes()
    local count = 0
    for name, value in pairs(attrs) do
        count += 1
        log("  " .. parentName .. "." .. name .. " = " .. tostring(value))
        
        local lowerName = name:lower()
        for _, keyword in ipairs(rngRelatedNames) do
            if lowerName:match(keyword) then
                critical("RNG attribute on client: " .. name)
            end
        end
        for _, keyword in ipairs(economyNames) do
            if lowerName:match(keyword) then
                critical("Economy attribute on client: " .. name)
            end
        end
    end
    return count
end

local playerAttrCount = auditAttributes(player, "Player")
local charAttrCount = char and auditAttributes(char, "Character") or 0

if playerAttrCount > 0 or charAttrCount > 0 then
    vuln("Total attributes exposed: " .. (playerAttrCount + charAttrCount))
end

--------------------------------------------------
-- 🔴 SECTION 3: LEADERSTATS (ECONOMY LEAK)
--------------------------------------------------
header("3. LEADERSTATS & ECONOMY EXPOSURE")

local leaderstats = player:FindFirstChild("leaderstats")
if leaderstats then
    critical("Leaderstats folder exists (client-visible economy)")
    for _, stat in ipairs(leaderstats:GetChildren()) do
        log("  " .. stat.Name .. " = " .. tostring(stat.Value) .. " (" .. stat.ClassName .. ")")
        critical("Stat exposed: " .. stat.Name)
    end
else
    log("✅ No leaderstats folder (good practice)")
end

-- PlayerGui economy displays
log("")
log("UI Economy Elements:")
for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
    if obj:IsA("TextLabel") then
        local text = obj.Text:lower()
        if text:match("coin") or text:match("gem") or text:match("cash") 
        or text:match("%d+,?%d*") then -- Détecte les nombres formatés
            pattern("Currency display in UI: " .. obj:GetFullName())
        end
    end
end

--------------------------------------------------
-- 🔴 SECTION 4: INPUT BINDINGS (EXPLOIT HOOKS)
--------------------------------------------------
header("4. INPUT SERVICE BINDINGS (Hook Targets)")

log("⚠️ ContextActionService & UserInputService Analysis:")
log("")

-- CAS Actions (souvent utilisé pour roll/spin buttons)
log("ContextActionService bound actions:")
local casActions = {}
local success, result = pcall(function()
    -- Malheureusement on ne peut pas lister directement les actions
    -- Mais on peut détecter les patterns dans les scripts
    for _, script in ipairs(player.PlayerGui:GetDescendants()) do
        if script:IsA("LocalScript") then
            if script.Name:lower():match("input") or script.Name:lower():match("control") then
                pattern("Input handling script: " .. script:GetFullName())
            end
        end
    end
end)

-- UIS Detection
log("")
log("UserInputService hooks to watch:")
log("  - InputBegan (can be hooked for auto-roll)")
log("  - InputEnded (can bypass cooldowns)")
log("  - TouchTap (mobile roll triggers)")

-- Recherche de boutons de roll/spin
log("")
log("🎰 RNG Trigger UI Elements:")
local rollButtons = {}
for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        local name = obj.Name:lower()
        local text = obj:IsA("TextButton") and obj.Text:lower() or ""
        
        if name:match("roll") or name:match("spin") or name:match("hatch") 
        or name:match("open") or text:match("roll") or text:match("spin") 
        or text:match("summon") or text:match("pull") then
            table.insert(rollButtons, obj)
            critical("RNG trigger button: " .. obj:GetFullName())
            
            -- Check si le bouton a un cooldown visible
            local cooldownUI = obj.Parent:FindFirstChild("Cooldown") 
                             or obj.Parent:FindFirstChild("Timer")
            if cooldownUI then
                pattern("Cooldown UI detected: " .. cooldownUI:GetFullName())
            end
        end
    end
end

log("Total RNG buttons found: " .. #rollButtons)

--------------------------------------------------
-- 🔴 SECTION 5: MARKETPLACESERVICE EXPOSURE
--------------------------------------------------
header("5. MARKETPLACE & MONETIZATION LEAKS")

log("🛒 MarketplaceService Analysis:")
log("")

-- Recherche de GamePass IDs
log("GamePass References:")
local gamepassIDs = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("IntValue") and (obj.Name:lower():match("gamepass") or obj.Name:lower():match("pass")) then
        table.insert(gamepassIDs, obj.Value)
        vuln("GamePass ID exposed: " .. obj.Name .. " = " .. obj.Value)
    end
end

-- Recherche de Developer Products
log("")
log("Developer Product References:")
local productIDs = {}
for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("IntValue") and (obj.Name:lower():match("product") or obj.Name:lower():match("shop")) then
        table.insert(productIDs, obj.Value)
        vuln("Product ID exposed: " .. obj.Name .. " = " .. obj.Value)
    end
end

-- Folders de shop/store
log("")
log("Shop/Store Structures:")
for _, obj in ipairs(RS:GetChildren()) do
    if obj:IsA("Folder") and (obj.Name:lower():match("shop") or obj.Name:lower():match("store") 
    or obj.Name:lower():match("product")) then
        pattern("Shop folder in ReplicatedStorage: " .. obj.Name)
        
        -- Liste le contenu
        for _, item in ipairs(obj:GetDescendants()) do
            if item:IsA("IntValue") or item:IsA("NumberValue") then
                log("  Item: " .. item:GetFullName() .. " = " .. tostring(item.Value))
            end
        end
    end
end

if #gamepassIDs > 0 or #productIDs > 0 then
    critical("Monetization IDs exposed - possible purchase bypass")
end

--------------------------------------------------
-- 🔴 SECTION 6: TIMERS & COOLDOWNS
--------------------------------------------------
header("6. CLIENT-SIDE TIMERS (Manipulable)")

log("⏱️ Timer Detection:")
log("")

-- Valeurs de cooldown
log("Cooldown Values:")
for _, obj in ipairs(player:GetDescendants()) do
    local name = obj.Name:lower()
    if (name:match("cooldown") or name:match("timer") or name:match("debounce") 
    or name:match("wait") or name:match("delay")) and obj:IsA("ValueBase") then
        critical("CLIENT COOLDOWN: " .. obj:GetFullName() .. " = " .. tostring(obj.Value))
    end
end

-- Scripts de timer
log("")
log("Timer Scripts:")
for _, script in ipairs(player.PlayerGui:GetDescendants()) do
    if script:IsA("LocalScript") then
        if script.Name:lower():match("cooldown") or script.Name:lower():match("timer") then
            critical("Timer script found: " .. script:GetFullName())
        end
    end
end

log("")
log("⚠️ Timer Exploit Vectors:")
log("  • tick() - Can be hooked/frozen")
log("  • os.clock() - Can be manipulated")
log("  • task.delay() - Can be cancelled")
log("  • task.wait() - Can be skipped")
log("  → ALL CLIENT TIMERS ARE BYPASSABLE")

--------------------------------------------------
-- 🔴 SECTION 7: LOCALSCRIPTS ANALYSIS
--------------------------------------------------
header("7. LOCALSCRIPTS & CODE EXPOSURE")

local scriptCategories = {
    input = {},
    timer = {},
    rng = {},
    ui = {},
    anticheat = {},
    other = {}
}

for _, location in ipairs({RS, player, player.PlayerGui, workspace}) do
    for _, script in ipairs(location:GetDescendants()) do
        if script:IsA("LocalScript") then
            stats.scripts += 1
            local name = script.Name:lower()
            local category = "other"
            
            if name:match("input") or name:match("control") then
                category = "input"
                pattern("Input script: " .. script:GetFullName())
            elseif name:match("timer") or name:match("cooldown") then
                category = "timer"
                critical("Timer script: " .. script:GetFullName())
            elseif name:match("roll") or name:match("spin") or name:match("hatch") then
                category = "rng"
                critical("RNG logic script: " .. script:GetFullName())
            elseif name:match("ui") or name:match("gui") then
                category = "ui"
            elseif name:match("anti") or name:match("cheat") or name:match("detect") then
                category = "anticheat"
                vuln("Anti-cheat script exposed: " .. script:GetFullName())
            end
            
            table.insert(scriptCategories[category], script)
            log("[" .. category:upper() .. "] " .. script:GetFullName())
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
-- 🔴 SECTION 8: MODULESCRIPTS (Logic Leaks)
--------------------------------------------------
header("8. MODULESCRIPTS & SHARED LOGIC")

local modules = {}
for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        table.insert(modules, obj)
        log("Module: " .. obj:GetFullName())
        
        local name = obj.Name:lower()
        if name:match("rng") or name:match("gacha") or name:match("luck") then
            critical("RNG logic module exposed: " .. obj.Name)
        elseif name:match("config") or name:match("setting") then
            critical("Config module exposed: " .. obj.Name)
        elseif name:match("data") or name:match("profile") then
            critical("Data module exposed: " .. obj.Name)
        end
    end
end

log("Total modules: " .. #modules)

if #modules > 0 then
    vuln("Modules in ReplicatedStorage can be require()'d by exploits")
end

--------------------------------------------------
-- 🔴 SECTION 9: WORKSPACE INTERACTIONS
--------------------------------------------------
header("9. WORKSPACE PHYSICAL INTERACTIONS")

local interactions = {
    click = {},
    prox = {},
    touch = {},
    parts = {}
}

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ClickDetector") then
        table.insert(interactions.click, obj)
        log("ClickDetector: " .. obj:GetFullName())
        log("  MaxDistance: " .. obj.MaxActivationDistance)
        
        if obj.MaxActivationDistance > 100 then
            vuln("Excessive range ClickDetector: " .. obj.Parent.Name)
        end
        
        -- Check si c'est un RNG trigger
        local parent = obj.Parent
        if parent and (parent.Name:lower():match("roll") or parent.Name:lower():match("spin")) then
            critical("Physical RNG trigger: " .. parent.Name)
        end
        
    elseif obj:IsA("ProximityPrompt") then
        table.insert(interactions.prox, obj)
        log("ProximityPrompt: " .. obj:GetFullName())
        log("  MaxDistance: " .. obj.MaxActivationDistance)
        
    elseif obj:IsA("TouchTransmitter") then
        table.insert(interactions.touch, obj)
        pattern("Touch trigger: " .. obj:GetFullName())
        
    elseif obj:IsA("BasePart") and obj.Name:lower():match("trigger") then
        table.insert(interactions.parts, obj)
        pattern("Trigger part: " .. obj:GetFullName())
    end
end

log("")
log("Interaction Summary:")
log("  ClickDetectors: " .. #interactions.click)
log("  ProximityPrompts: " .. #interactions.prox)
log("  TouchTransmitters: " .. #interactions.touch)
log("  Trigger Parts: " .. #interactions.parts)

--------------------------------------------------
-- 🔴 SECTION 10: CHARACTER PROPERTIES
--------------------------------------------------
header("10. CHARACTER MANIPULATION VECTORS")

if char then
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        log("Humanoid Properties:")
        log("  WalkSpeed: " .. humanoid.WalkSpeed)
        log("  JumpHeight: " .. (humanoid.JumpHeight or 0))
        log("  MaxHealth: " .. humanoid.MaxHealth)
        log("  Health: " .. humanoid.Health)
        
        if humanoid.WalkSpeed ~= 16 then
            pattern("Non-standard WalkSpeed: " .. humanoid.WalkSpeed)
        end
        if (humanoid.JumpHeight or 0) ~= 7.2 and humanoid.JumpPower ~= 50 then
            pattern("Modified jump values detected")
        end
    end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        log("")
        log("RootPart Properties:")
        log("  Position: " .. tostring(root.Position))
        log("  Anchored: " .. tostring(root.Anchored))
        log("  CanCollide: " .. tostring(root.CanCollide))
        
        if not root.Anchored then
            pattern("RootPart not anchored - teleport possible")
        end
    end
    
    -- Network ownership check
    log("")
    log("Network Ownership:")
    log("⚠️ Network ownership can only be checked server-side")
    log("  → Exploits can still manipulate unanchored parts")
    log("  → Recommendation: Anchor important parts or use server validation")
end

--------------------------------------------------
-- 🔴 SECTION 11: REPLICATED STORAGE STRUCTURE
--------------------------------------------------
header("11. REPLICATED STORAGE DEEP SCAN")

local function scanDeep(parent, indent, depth)
    if depth > 3 then return end
    indent = indent or ""
    
    for _, child in ipairs(parent:GetChildren()) do
        local info = indent .. child.ClassName .. " | " .. child.Name
        log(info)
        
        if child:IsA("Configuration") then
            critical("Configuration exposed: " .. child:GetFullName())
            scanDeep(child, indent .. "  ", depth + 1)
        elseif child:IsA("Folder") then
            local name = child.Name:lower()
            if name:match("config") or name:match("setting") or name:match("data") then
                critical("Sensitive folder: " .. child.Name)
            end
            scanDeep(child, indent .. "  ", depth + 1)
        end
    end
end

scanDeep(RS, "", 0)

--------------------------------------------------
-- 🔴 SECTION 12: UI INTERACTIVE ELEMENTS
--------------------------------------------------
header("12. UI INTERACTIVE ELEMENTS")

local uiElements = {
    buttons = {},
    textboxes = {},
    frames = {}
}

for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        table.insert(uiElements.buttons, obj)
        
        local name = obj.Name:lower()
        if name:match("admin") or name:match("dev") or name:match("debug") then
            critical("ADMIN UI ELEMENT: " .. obj:GetFullName())
        end
        
    elseif obj:IsA("TextBox") then
        table.insert(uiElements.textboxes, obj)
        
        if obj.Name:lower():match("code") or obj.Name:lower():match("redeem") then
            pattern("Code redemption UI: " .. obj:GetFullName())
        end
        
    elseif obj:IsA("Frame") and obj.Visible == false then
        local name = obj.Name:lower()
        if name:match("admin") or name:match("dev") then
            critical("HIDDEN ADMIN PANEL: " .. obj:GetFullName())
        end
    end
end

log("UI Element Count:")
log("  Buttons: " .. #uiElements.buttons)
log("  TextBoxes: " .. #uiElements.textboxes)

--------------------------------------------------
-- 🔴 SECTION 13: SERVICES & APIs
--------------------------------------------------
header("13. ACCESSIBLE SERVICES & APIs")

local criticalServices = {
    "HttpService", "TeleportService", "DataStoreService",
    "MessagingService", "MarketplaceService"
}

local standardServices = {
    "Lighting", "SoundService", "Teams", "StarterGui",
    "UserInputService", "ContextActionService", "TweenService"
}

log("Critical Services:")
for _, sName in ipairs(criticalServices) do
    local success = pcall(function() game:GetService(sName) end)
    if success then
        log("  ⚠️ " .. sName .. " accessible")
        vuln("Critical service accessible: " .. sName)
    else
        log("  ✓ " .. sName .. " blocked")
    end
end

log("")
log("Standard Services:")
for _, sName in ipairs(standardServices) do
    local success = pcall(function() game:GetService(sName) end)
    log("  " .. (success and "✓" or "✗") .. " " .. sName)
end

--------------------------------------------------
-- 🔴 SECTION 14: EXPLOIT ENVIRONMENT
--------------------------------------------------
header("14. EXECUTOR ENVIRONMENT DETECTION")

local exploitFuncs = {
    "getconnections", "hookmetamethod", "getnamecallmethod",
    "firesignal", "hookfunction", "getcallingscript",
    "getloadedmodules", "getsenv", "getgc", "getgenv",
    "setclipboard", "readfile", "writefile"
}

local detected = false
log("Exploit Function Detection:")
for _, fname in ipairs(exploitFuncs) do
    local exists = (getgenv and getgenv()[fname] ~= nil) or (_G and _G[fname] ~= nil)
    log("  " .. fname .. ": " .. tostring(exists))
    if exists then detected = true end
end

log("")
if detected then
    log("🔴 EXECUTOR DETECTED - Test environment confirmed")
else
    log("✅ Normal Roblox client detected")
end

--------------------------------------------------
-- 🔴 SECTION 15: RNG SPECIFIC PATTERNS
--------------------------------------------------
header("15. RNG GAME SPECIFIC VULNERABILITIES")

log("🎰 RNG Mechanic Analysis:")
log("")

-- Pity systems
log("Pity System Detection:")
for _, obj in ipairs(player:GetDescendants()) do
    if obj.Name:lower():match("pity") or obj.Name:lower():match("guarantee") then
        critical("Pity counter on client: " .. obj:GetFullName())
    end
end

-- Luck multipliers
log("")
log("Luck System Detection:")
local luckValues = {}
for _, obj in ipairs(game:GetDescendants()) do
    local name = obj.Name:lower()
    if (name:match("luck") or name:match("multi") or name:match("boost")) 
    and obj:IsA("ValueBase") and obj:IsDescendantOf(player) then
        table.insert(luckValues, obj)
        critical("Luck value on client: " .. obj:GetFullName() .. " = " .. tostring(obj.Value))
    end
end

-- Inventory/Collection
log("")
log("Inventory System:")
local inventoryFolders = {}
for _, obj in ipairs(player:GetDescendants()) do
    if obj:IsA("Folder") and (obj.Name:lower():match("inventory") 
    or obj.Name:lower():match("collection") or obj.Name:lower():match("items")) then
        table.insert(inventoryFolders, obj)
        log("Inventory folder: " .. obj:GetFullName())
        log("  Items: " .. #obj:GetChildren())
        
        -- Liste quelques items
        for i, item in ipairs(obj:GetChildren()) do
            if i <= 5 then
                log("    • " .. item.Name)
            end
        end
        if #obj:GetChildren() > 5 then
            log("    ... and " .. (#obj:GetChildren() - 5) .. " more")
        end
    end
end

-- Roll history (si stocké client-side)
log("")
log("Roll History Detection:")
for _, obj in ipairs(player:GetDescendants()) do
    if obj.Name:lower():match("history") or obj.Name:lower():match("log") then
        pattern("Roll history on client: " .. obj:GetFullName())
    end
end

--------------------------------------------------
-- 📊 FINAL STATISTICS & SECURITY SCORE
--------------------------------------------------
header("COMPREHENSIVE AUDIT SUMMARY")

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
    log("🔴 RATING: CRITICAL - Immediate action required")
    log("Your game is HIGHLY exploitable")
elseif stats.criticalIssues > 0 then
    log("🟠 RATING: HIGH RISK - Major vulnerabilities")
    log("Exploits can easily break game economy")
elseif stats.vulnerabilities > 10 then
    log("🟡 RATING: MODERATE - Some concerns")
    log("Consider server-side validation improvements")
elseif stats.vulnerabilities > 0 then
    log("🟢 RATING: ACCEPTABLE - Minor issues")
    log("Good foundation, polish remaining issues")
else
    log("✅ RATING: EXCELLENT - Well secured")
    log("No major vulnerabilities detected")
end

log("")
log("Top Exploit Vectors to Fix:")
local priorities = {}
if #remotesByCategory.datastore > 0 then
    table.insert(priorities, "1. DataStore pattern leaks (" .. #remotesByCategory.datastore .. " remotes)")
end
if #remotesByCategory.economy > 0 then
    table.insert(priorities, "2. Economy remotes (" .. #remotesByCategory.economy .. " remotes)")
end
if #remotesByCategory.rng > 0 then
    table.insert(priorities, "3. RNG trigger exposure (" .. #remotesByCategory.rng .. " remotes)")
end
if #luckValues > 0 then
    table.insert(priorities, "4. Client-side luck values (" .. #luckValues .. " found)")
end
if #rollButtons > 0 then
    table.insert(priorities, "5. UI roll triggers (" .. #rollButtons .. " buttons)")
end

for _, priority in ipairs(priorities) do
    log("  " .. priority)
end

if #priorities == 0 then
    log("  ✅ No critical priorities - good job!")
end

--------------------------------------------------
-- 🔴 SECTION 16: ADVANCED PATTERN DETECTION
--------------------------------------------------
header("16. ADVANCED EXPLOIT PATTERNS")

log("🔍 Behavioral Pattern Analysis:")
log("")

-- Pattern 1: Débounce côté client
log("Anti-Spam Patterns (Client-Side):")
local debouncePatterns = 0
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("BoolValue") and obj.Name:lower():match("debounce") then
        debouncePatterns += 1
        critical("Client debounce: " .. obj:GetFullName())
    end
end
log("  Found " .. debouncePatterns .. " client-side debounce values")
if debouncePatterns > 0 then
    log("  ⚠️ These can be bypassed by exploits!")
end

-- Pattern 2: Animation-based triggers
log("")
log("Animation-Based Triggers:")
local animTriggers = 0
for _, obj in ipairs(char and char:GetDescendants() or {}) do
    if obj:IsA("Animation") then
        animTriggers += 1
        log("  Animation: " .. obj.Name)
        if obj.Name:lower():match("roll") or obj.Name:lower():match("spin") then
            pattern("RNG animation detected: " .. obj.Name)
        end
    end
end

-- Pattern 3: Sound cues (peuvent leak le résultat du roll)
log("")
log("Audio Cue Detection:")
local soundCues = {}
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Sound") then
        local name = obj.Name:lower()
        if name:match("win") or name:match("lose") or name:match("rare") 
        or name:match("legendary") or name:match("mythic") then
            table.insert(soundCues, obj)
            pattern("Result audio cue: " .. obj.Name .. " | SoundId: " .. obj.SoundId)
        end
    end
end
log("  Total result sounds: " .. #soundCues)
if #soundCues > 0 then
    log("  ⚠️ Exploits can read sounds before they play!")
end

-- Pattern 4: Particle effects (même chose)
log("")
log("Visual Effect Detection:")
local vfxCount = 0
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
        local name = obj.Name:lower()
        if name:match("rare") or name:match("legendary") or name:match("win") then
            vfxCount += 1
            pattern("Result VFX: " .. obj:GetFullName())
        end
    end
end

-- Pattern 5: TweenService usage (animations UI)
log("")
log("Tween-Based Animations:")
log("  ⚠️ UI animations can be cancelled/skipped by exploits")
log("  → Consider server-authoritative result delivery")

--------------------------------------------------
-- 🔴 SECTION 17: NETWORK TRAFFIC ANALYSIS
--------------------------------------------------
header("17. NETWORK EXPLOIT VECTORS")

log("🌐 Network Analysis:")
log("")

-- Remote spam potential
log("Remote Spam Risk Assessment:")
for category, remotes in pairs(remotesByCategory) do
    if #remotes > 0 and category ~= "other" then
        log("  " .. category:upper() .. " remotes:")
        for _, remote in ipairs(remotes) do
            log("    • " .. remote.Name)
            if remote:IsA("RemoteEvent") then
                log("      ⚠️ Can be spam-fired without rate limit")
            end
        end
    end
end

log("")
log("Recommended Protections:")
log("  1. Server-side rate limiting (per player)")
log("  2. Cooldown tracking in ServerScriptService")
log("  3. Argument validation on ALL remotes")
log("  4. Anti-spam kick system")

--------------------------------------------------
-- 🔴 SECTION 18: MEMORY MANIPULATION VECTORS
--------------------------------------------------
header("18. MEMORY MANIPULATION DETECTION")

log("💾 Memory Exploit Vectors:")
log("")

-- Instances qui peuvent être modifiées en mémoire
log("Modifiable Instance Properties:")
local modifiableProps = {
    {class = "Humanoid", props = {"WalkSpeed", "JumpHeight", "Health"}},
    {class = "BasePart", props = {"CFrame", "Position", "Velocity"}},
    {class = "Camera", props = {"CFrame", "FieldOfView"}}
}

for _, data in ipairs(modifiableProps) do
    log("  " .. data.class .. ":")
    for _, prop in ipairs(data.props) do
        log("    • " .. prop .. " - Can be changed client-side")
    end
end

log("")
log("⚠️ Memory Scan Tools:")
log("  • Cheat Engine - Can freeze/modify values")
log("  • ReClass - Can map game structures")
log("  • IDA Pro - Can reverse engineer logic")
log("  → Server validation is MANDATORY")

--------------------------------------------------
-- 🔴 SECTION 19: ANTI-CHEAT BYPASS VECTORS
--------------------------------------------------
header("19. ANTI-CHEAT WEAKNESSES")

log("🛡️ Anti-Cheat Analysis:")
log("")

-- Détection des anti-cheats visibles
local anticheatScripts = 0
for _, script in ipairs(game:GetDescendants()) do
    if script:IsA("LocalScript") then
        local name = script.Name:lower()
        if name:match("anti") or name:match("detect") or name:match("cheat") 
        or name:match("kick") or name:match("ban") then
            anticheatScripts += 1
            log("Anti-cheat script: " .. script:GetFullName())
        end
    end
end

if anticheatScripts > 0 then
    critical(anticheatScripts .. " anti-cheat scripts visible to client!")
    log("")
    log("⚠️ Bypass Methods:")
    log("  1. hookfunction() - Replace detection functions")
    log("  2. getcallingscript() - Spoof script identity")
    log("  3. setreadonly() - Modify protected tables")
    log("  4. Script deletion - Remove anti-cheat entirely")
    log("")
    log("✅ Recommendation:")
    log("  • Move ALL anti-cheat to ServerScriptService")
    log("  • Use server-side validation only")
    log("  • Never trust client checks")
else
    log("✅ No visible client-side anti-cheat (good)")
end

--------------------------------------------------
-- 🔴 SECTION 20: DATA PERSISTENCE LEAKS
--------------------------------------------------
header("20. DATA PERSISTENCE ANALYSIS")

log("💽 Data Saving Patterns:")
log("")

-- Recherche de patterns de sauvegarde
log("Save/Load Remote Detection:")
local saveRemotes = {}
for _, remote in ipairs(RS:GetDescendants()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        local name = remote.Name:lower()
        if name:match("save") or name:match("load") or name:match("update") 
        or name:match("sync") or name:match("set") then
            table.insert(saveRemotes, remote)
            log("  " .. remote.Name .. " | " .. remote.ClassName)
        end
    end
end

if #saveRemotes > 0 then
    critical("Found " .. #saveRemotes .. " data persistence remotes")
    log("")
    log("⚠️ Exploit Scenarios:")
    log("  1. Data duplication (rapid save/load)")
    log("  2. Rollback exploits (load old data)")
    log("  3. Data injection (modify save data)")
    log("  4. Cross-account transfers")
end

-- Auto-save patterns
log("")
log("Auto-Save Detection:")
for _, script in ipairs(player.PlayerGui:GetDescendants()) do
    if script:IsA("LocalScript") and script.Name:lower():match("save") then
        pattern("Client-side save script: " .. script:GetFullName())
    end
end

--------------------------------------------------
-- 🔴 SECTION 21: SOCIAL ENGINEERING VECTORS
--------------------------------------------------
header("21. SOCIAL EXPLOIT OPPORTUNITIES")

log("👥 Social Engineering Risks:")
log("")

-- Trading systems
log("Trading System Detection:")
local tradingUI = player.PlayerGui:FindFirstChild("Trading", true) 
               or player.PlayerGui:FindFirstChild("Trade", true)
if tradingUI then
    critical("Trading UI detected: " .. tradingUI:GetFullName())
    log("  ⚠️ Potential scam vectors:")
    log("    • Fast-trade exploits")
    log("    • Item duplication")
    log("    • Display manipulation")
end

-- Chat commands
log("")
log("Command System Detection:")
for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
    if obj:IsA("TextBox") and (obj.Name:lower():match("command") 
    or obj.Name:lower():match("console") or obj.Name:lower():match("input")) then
        pattern("Command input detected: " .. obj:GetFullName())
    end
end

-- Code redemption
log("")
log("Code Redemption Detection:")
local codeBoxes = {}
for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
    if obj:IsA("TextBox") and (obj.Name:lower():match("code") 
    or obj.Name:lower():match("redeem") or obj.Name:lower():match("promo")) then
        table.insert(codeBoxes, obj)
        log("  Code input: " .. obj:GetFullName())
    end
end

if #codeBoxes > 0 then
    log("  ⚠️ Bruteforce risk if not rate-limited")
end

--------------------------------------------------
-- 🔴 SECTION 22: FINAL RECOMMENDATIONS
--------------------------------------------------
header("22. SECURITY RECOMMENDATIONS")

log("🔧 Critical Fixes Required:")
log("")

local fixes = {}
local fixNum = 1

if stats.criticalIssues > 0 then
    table.insert(fixes, fixNum .. ". CRITICAL: Move ALL sensitive logic to server")
    fixNum += 1
end

if #remotesByCategory.datastore > 0 then
    table.insert(fixes, fixNum .. ". Remove DataStore patterns from remote names")
    fixNum += 1
end

if #remotesByCategory.economy > 0 then
    table.insert(fixes, fixNum .. ". Validate ALL economy remote arguments server-side")
    fixNum += 1
end

if #luckValues > 0 then
    table.insert(fixes, fixNum .. ". Remove luck/multiplier values from client")
    fixNum += 1
end

if debouncePatterns > 0 then
    table.insert(fixes, fixNum .. ". Implement server-side cooldown tracking")
    fixNum += 1
end

if #saveRemotes > 0 then
    table.insert(fixes, fixNum .. ". Add rate limiting to save/load remotes")
    fixNum += 1
end

if anticheatScripts > 0 then
    table.insert(fixes, fixNum .. ". Move anti-cheat to ServerScriptService")
    fixNum += 1
end

if #modules > 0 then
    table.insert(fixes, fixNum .. ". Move sensitive modules to ServerStorage")
    fixNum += 1
end

for _, fix in ipairs(fixes) do
    log("  " .. fix)
end

if #fixes == 0 then
    log("  ✅ No critical fixes needed!")
end

-- Modules (SAFE - sans require pour éviter les erreurs)
log("")
log("📚 Best Practices:")
log("  • Never trust client input")
log("  • All rewards determined server-side")
log("  • Use remote rate limiting")
log("  • Validate every argument")
log("  • Log suspicious activity")
log("  • Use ServerScriptService for logic")
log("  • Implement server-side cooldowns")
log("  • Regular security audits")
log("  • Never use GetNetworkOwner() client-side")
log("  • Anchor important physics objects")

--------------------------------------------------
-- 💾 SAVE & DISPLAY
--------------------------------------------------
local finalText = table.concat(dump, "\n")

-- StringValue storage with metadata
local sv = Instance.new("StringValue")
sv.Name = "SecurityAudit_" .. os.time()
sv.Value = finalText
sv.Parent = player

local metaFolder = Instance.new("Folder")
metaFolder.Name = "AuditMetadata"
metaFolder.Parent = sv

local function createMeta(name, value)
    local v = Instance.new("IntValue")
    v.Name = name
    v.Value = value
    v.Parent = metaFolder
end

createMeta("TotalVulnerabilities", stats.vulnerabilities)
createMeta("CriticalIssues", stats.criticalIssues)
createMeta("SuspiciousPatterns", stats.suspiciousPatterns)
createMeta("SecurityScore", securityScore)
createMeta("RemoteCount", stats.remotes)
createMeta("ValueCount", stats.values)
createMeta("ScriptCount", stats.scripts)

-- UI Display
local gui = Instance.new("ScreenGui")
gui.Name = "AdvancedSecurityAuditUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player.PlayerGui

-- Background overlay
local overlay = Instance.new("Frame", gui)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.BorderSizePixel = 0

-- Main frame
local frame = Instance.new("Frame", overlay)
frame.Size = UDim2.fromScale(0.9, 0.88)
frame.Position = UDim2.fromScale(0.05, 0.06)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
frame.BorderSizePixel = 3
frame.BorderColor3 = securityScore > 70 and Color3.fromRGB(50, 200, 50) 
                     or securityScore > 40 and Color3.fromRGB(255, 150, 0)
                     or Color3.fromRGB(255, 50, 50)

-- Corner rounding
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

-- Title bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -150, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔒 ADVANCED SECURITY AUDIT - Score: " .. securityScore .. "/100"
title.TextColor3 = securityScore > 70 and Color3.fromRGB(50, 255, 50)
                   or securityScore > 40 and Color3.fromRGB(255, 200, 0)
                   or Color3.fromRGB(255, 80, 80)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

-- Stats panel
local statsPanel = Instance.new("Frame", frame)
statsPanel.Size = UDim2.new(1, -20, 0, 60)
statsPanel.Position = UDim2.new(0, 10, 0, 60)
statsPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
statsPanel.BorderSizePixel = 1
statsPanel.BorderColor3 = Color3.fromRGB(40, 40, 40)

local statsCorner = Instance.new("UICorner", statsPanel)
statsCorner.CornerRadius = UDim.new(0, 6)

local function createStat(text, position, color)
    local label = Instance.new("TextLabel", statsPanel)
    label.Size = UDim2.new(0.25, -10, 1, 0)
    label.Position = UDim2.new(position * 0.25, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextWrapped = true
end

createStat("🚨 Vulnerabilities\n" .. stats.vulnerabilities, 0, Color3.fromRGB(255, 150, 0))
createStat("🔴 Critical Issues\n" .. stats.criticalIssues, 1, Color3.fromRGB(255, 80, 80))
createStat("🔍 Patterns\n" .. stats.suspiciousPatterns, 2, Color3.fromRGB(150, 150, 255))
createStat("📡 Remotes\n" .. stats.remotes, 3, Color3.fromRGB(100, 200, 255))

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 1, -200)
scroll.Position = UDim2.new(0, 10, 0, 130)
scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
scroll.BorderSizePixel = 1
scroll.BorderColor3 = Color3.fromRGB(30, 30, 30)
scroll.ScrollBarThickness = 10
scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)

local scrollCorner = Instance.new("UICorner", scroll)
scrollCorner.CornerRadius = UDim.new(0, 6)

-- TextBox
local box = Instance.new("TextBox", scroll)
box.Size = UDim2.new(1, -15, 0, 0)
box.AutomaticSize = Enum.AutomaticSize.Y
box.BackgroundTransparency = 1
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextSize = 12
box.Font = Enum.Font.Code
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = false
box.Text = finalText
box.TextColor3 = Color3.fromRGB(0, 255, 120)
box.RichText = false

-- Button panel
local buttonPanel = Instance.new("Frame", frame)
buttonPanel.Size = UDim2.new(1, 0, 0, 50)
buttonPanel.Position = UDim2.new(0, 0, 1, -50)
buttonPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonPanel.BorderSizePixel = 0

-- Close button
local closeBtn = Instance.new("TextButton", buttonPanel)
closeBtn.Size = UDim2.new(0, 120, 0, 35)
closeBtn.Position = UDim2.new(1, -130, 0.5, -17.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.Text = "✖ CLOSE"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14

local closeBtnCorner = Instance.new("UICorner", closeBtn)
closeBtnCorner.CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Copy button
local copyBtn = Instance.new("TextButton", buttonPanel)
copyBtn.Size = UDim2.new(0, 120, 0, 35)
copyBtn.Position = UDim2.new(1, -260, 0.5, -17.5)
copyBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
copyBtn.Text = "📋 SELECT"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 14

local copyBtnCorner = Instance.new("UICorner", copyBtn)
copyBtnCorner.CornerRadius = UDim.new(0, 6)

copyBtn.MouseButton1Click:Connect(function()
    box:CaptureFocus()
    box.CursorPosition = #box.Text + 1
    box.SelectionStart = 1
    copyBtn.Text = "✓ SELECTED"
    task.wait(1.5)
    copyBtn.Text = "📋 SELECT"
end)

-- Export button
local exportBtn = Instance.new("TextButton", buttonPanel)
exportBtn.Size = UDim2.new(0, 120, 0, 35)
exportBtn.Position = UDim2.new(0, 10, 0.5, -17.5)
exportBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
exportBtn.Text = "💾 SAVED"
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.Font = Enum.Font.GothamBold
exportBtn.TextSize = 14

local exportBtnCorner = Instance.new("UICorner", exportBtn)
exportBtnCorner.CornerRadius = UDim.new(0, 6)

-- Update scroll canvas
scroll.CanvasSize = UDim2.new(0, 0, 0, box.AbsoluteSize.Y + 20)
box:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, box.AbsoluteSize.Y + 20)
end)

-- Button hover effects
local function addHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = normalColor
    end)
end

addHoverEffect(closeBtn, Color3.fromRGB(220, 60, 60), Color3.fromRGB(255, 80, 80))
addHoverEffect(copyBtn, Color3.fromRGB(60, 150, 255), Color3.fromRGB(80, 170, 255))

-- Console output
warn("╔════════════════════════════════════════════╗")
warn("║    ADVANCED SECURITY AUDIT COMPLETE       ║")
warn("╚════════════════════════════════════════════╝")
warn("")
warn("📊 Results:")
warn("  • Security Score: " .. securityScore .. "/100")
warn("  • Vulnerabilities: " .. stats.vulnerabilities)
warn("  • Critical Issues: " .. stats.criticalIssues)
warn("  • Suspicious Patterns: " .. stats.suspiciousPatterns)
warn("")
warn("💾 Report saved in: Player." .. sv.Name)
warn("🔍 UI displayed for detailed analysis")
warn("")

if stats.criticalIssues > 5 then
    warn("🔴 CRITICAL: Your game has MAJOR security flaws!")
    warn("⚠️  DO NOT release until these are fixed!")
elseif stats.criticalIssues > 0 then
    warn("🟠 WARNING: Significant vulnerabilities detected")
    warn("⚠️  Highly recommended to fix before release")
else
    warn("✅ Good job! No critical issues found")
end

end -- Fin de la fonction runSecurityAudit()

--================================================
-- 🎮 UI LAUNCHER - BOUTON PERMANENT
--================================================

-- Supprime les anciennes instances si elles existent
if player.PlayerGui:FindFirstChild("SecurityAuditLauncher") then
    player.PlayerGui.SecurityAuditLauncher:Destroy()
end

-- Crée le launcher GUI (bouton permanent)
local launcherGui = Instance.new("ScreenGui")
launcherGui.Name = "SecurityAuditLauncher"
launcherGui.ResetOnSpawn = false
launcherGui.IgnoreGuiInset = true
launcherGui.DisplayOrder = 999
launcherGui.Parent = player.PlayerGui

-- Bouton principal
local launchButton = Instance.new("TextButton", launcherGui)
launchButton.Size = UDim2.new(0, 140, 0, 50)
launchButton.Position = UDim2.new(1, -150, 0, 10)
launchButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
launchButton.BorderSizePixel = 2
launchButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
launchButton.Text = "🔒 SECURITY\nAUDIT"
launchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
launchButton.Font = Enum.Font.GothamBold
launchButton.TextSize = 14
launchButton.AutoButtonColor = false

local btnCorner = Instance.new("UICorner", launchButton)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Gradient pour le bouton
local gradient = Instance.new("UIGradient", launchButton)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
}
gradient.Rotation = 90

-- Status label
local statusLabel = Instance.new("TextLabel", launcherGui)
statusLabel.Size = UDim2.new(0, 140, 0, 20)
statusLabel.Position = UDim2.new(1, -150, 0, 65)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.Visible = false

-- Variables pour le cooldown
local isRunning = false
local lastRunTime = 0
local COOLDOWN = 5 -- secondes

-- Fonction de mise à jour du statut
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

-- Animation du bouton
local function animateButton(button, scale, duration)
    local tween = game:GetService("TweenService"):Create(
        button,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 140 * scale, 0, 50 * scale)}
    )
    tween:Play()
end

-- Effets hover
launchButton.MouseEnter:Connect(function()
    if not isRunning then
        launchButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        animateButton(launchButton, 1.05, 0.2)
    end
end)

launchButton.MouseLeave:Connect(function()
    launchButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    animateButton(launchButton, 1, 0.2)
end)

-- Click handler
launchButton.MouseButton1Click:Connect(function()
    -- Check cooldown
    local timeSinceLastRun = tick() - lastRunTime
    if timeSinceLastRun < COOLDOWN then
        local remaining = math.ceil(COOLDOWN - timeSinceLastRun)
        updateStatus("Cooldown: " .. remaining .. "s", Color3.fromRGB(255, 150, 0))
        return
    end
    
    if isRunning then
        updateStatus("Already running...", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Lance l'audit
    isRunning = true
    lastRunTime = tick()
    
    -- Animation de lancement
    launchButton.Text = "⏳ SCANNING..."
    launchButton.BackgroundColor3 = Color3.fromRGB(80, 80, 20)
    updateStatus("Analyzing game...", Color3.fromRGB(255, 200, 0))
    
    -- Exécute l'audit dans un thread séparé
    task.spawn(function()
        local success, errorMsg = pcall(function()
            debugPrint("MAIN", "Launching audit function...")
            
            -- Ferme l'ancien rapport s'il existe
            local oldReport = player.PlayerGui:FindFirstChild("AdvancedSecurityAuditUI")
            if oldReport then
                debugPrint("CLEANUP", "Removing old report UI...")
                oldReport:Destroy()
                task.wait(0.1)
            end
            
            runSecurityAudit()
        end)
        
        -- Réinitialise le bouton
        task.wait(0.5)
        isRunning = false
        launchButton.Text = "🔒 SECURITY\nAUDIT"
        launchButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        if success then
            updateStatus("✓ Audit complete!", Color3.fromRGB(100, 255, 100))
        else
            updateStatus("✗ Error occurred", Color3.fromRGB(255, 100, 100))
            warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            warn("❌ AUDIT ERROR DETAILS:")
            warn(tostring(errorMsg))
            warn("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            -- Affiche une UI d'erreur
            local errorGui = Instance.new("ScreenGui")
            errorGui.Name = "AuditErrorReport"
            errorGui.Parent = player.PlayerGui
            
            local errorFrame = Instance.new("Frame", errorGui)
            errorFrame.Size = UDim2.fromScale(0.5, 0.3)
            errorFrame.Position = UDim2.fromScale(0.25, 0.35)
            errorFrame.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
            errorFrame.BorderSizePixel = 3
            errorFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
            
            local errorTitle = Instance.new("TextLabel", errorFrame)
            errorTitle.Size = UDim2.new(1, 0, 0, 40)
            errorTitle.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
            errorTitle.Text = "⚠️ AUDIT ERROR"
            errorTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
            errorTitle.TextSize = 18
            errorTitle.Font = Enum.Font.GothamBold
            
            local errorText = Instance.new("TextLabel", errorFrame)
            errorText.Size = UDim2.new(1, -20, 1, -100)
            errorText.Position = UDim2.new(0, 10, 0, 50)
            errorText.BackgroundTransparency = 1
            errorText.Text = "Error:\n" .. tostring(errorMsg) .. "\n\nCheck console (F9) for details"
            errorText.TextColor3 = Color3.fromRGB(255, 200, 200)
            errorText.TextSize = 14
            errorText.Font = Enum.Font.Code
            errorText.TextWrapped = true
            errorText.TextXAlignment = Enum.TextXAlignment.Left
            errorText.TextYAlignment = Enum.TextYAlignment.Top
            
            local closeError = Instance.new("TextButton", errorFrame)
            closeError.Size = UDim2.new(0, 100, 0, 35)
            closeError.Position = UDim2.new(0.5, -50, 1, -45)
            closeError.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            closeError.Text = "CLOSE"
            closeError.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeError.Font = Enum.Font.GothamBold
            closeError.TextSize = 14
            closeError.MouseButton1Click:Connect(function()
                errorGui:Destroy()
            end)
        end
    end)
end)

-- Indicateur de version
local versionLabel = Instance.new("TextLabel", launcherGui)
versionLabel.Size = UDim2.new(0, 140, 0, 15)
versionLabel.Position = UDim2.new(1, -150, 0, 90)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v2.5 Advanced"
versionLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
versionLabel.Font = Enum.Font.Code
versionLabel.TextSize = 9

-- Drag functionality (optionnel)
local dragging = false
local dragInput, mousePos, framePos

launchButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement then
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
        -- Met à jour la position des autres éléments
        statusLabel.Position = UDim2.new(
            launchButton.Position.X.Scale,
            launchButton.Position.X.Offset,
            launchButton.Position.Y.Scale,
            launchButton.Position.Y.Offset + 55
        )
        versionLabel.Position = UDim2.new(
            launchButton.Position.X.Scale,
            launchButton.Position.X.Offset,
            launchButton.Position.Y.Scale,
            launchButton.Position.Y.Offset + 80
        )
    end
end)

-- Notifications initiales
print("╔════════════════════════════════════════════╗")
print("║   SECURITY AUDIT TOOL LOADED              ║")
print("╚════════════════════════════════════════════╝")
print("")
print("✅ Launcher button created in top-right corner")
print("📌 Click '🔒 SECURITY AUDIT' to start analysis")
print("🔄 Button can be dragged to reposition")
print("⏱️  Analysis takes ~3-5 seconds")
print("")
print("💡 TIP: You can run the audit multiple times")
print("    Cooldown: " .. COOLDOWN .. " seconds between runs")
print("")
