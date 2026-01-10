--[[
    Steal A Brainrot Script - Rayfield UI Version
    Optimisé pour Android/Mobile
]]

local start_tick = tick()

-- Services
local replicated_storage = game:GetService("ReplicatedStorage")
local virtual_user = game:GetService("VirtualUser")
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local run_service = game:GetService("RunService")

local local_player = players.LocalPlayer

-- Game Objects
local game_objects = workspace:WaitForChild("GameObjects")
local brainrots = game_objects:WaitForChild("Brainrots")
local plots = game_objects:WaitForChild("Plots")
local plot

for _, v in plots:GetChildren() do
    if v:GetAttribute("Owner") == local_player.Name then
        plot = v
        break
    end
end

if not plot then
    return local_player:Kick("Plot not found")
end

local logic = plot:WaitForChild("Logic")
local player_eggs = logic:WaitForChild("Eggs")
local customers = logic:WaitForChild("Customers")
local brainrot_slots = logic:WaitForChild("BrainrotSlots")

-- Modules
local packages = replicated_storage:WaitForChild("Packages")
local info = replicated_storage:WaitForChild("Info")
local game_info = info:WaitForChild("Game")

local eggs_module = require(game_info:WaitForChild("Eggs"))
local knit_module = require(packages:WaitForChild("Knit"))

local data_controller = knit_module.GetController("DataController")

-- Services
local sell_brainrot_service = knit_module.GetService("SellBrainrotService")
local npc_trade_service = knit_module.GetService("NpcTradeService")
local spin_service = knit_module.GetService("SpinService")
local egg_service = knit_module.GetService("EggService")

-- Configuration
local selected_eggs = {}
local eggs = {}
local flags = {
    auto_trade = false,
    auto_trade_delay = 1,
    accept_multiple_npc = false,  -- Nouveau
    accept_multiple_mine = false, -- Nouveau
    auto_collect_cash = false,
    auto_collect_cash_delay = 1,
    auto_buy_eggs = false,
    auto_buy_eggs_delay = 1,
    anti_afk = false,
    auto_wheel = false
}

-- Populate eggs table
for k, v in pairs(eggs_module.List) do
    table.insert(eggs, k)
end

-- Utility Functions
local function safe_call(func, error_message)
    local success, result = pcall(func)
    if not success then
        warn("[Script Error]:", result)
        return false, result
    end
    return true, result
end

local function get_egg_price(egg_name)
    if not eggs_module.List[egg_name] then
        return 0
    end
    return tonumber(eggs_module.List[egg_name].Price) or 0
end

local function held_brainrot()
    for _, v in brainrots:GetChildren() do
        if v.Name:find(local_player.Name) then
            return v
        end
    end
    return nil
end

local function get_spins(wheel)
    local replica = data_controller:GetReplica()
    if not replica or not replica.Data or not replica.Data.Spins then
        return 0
    end
    
    for i, v in pairs(replica.Data.Spins) do
        if i == wheel then
            return v
        end
    end
    return 0
end

local function get_money()
    local replica = data_controller:GetReplica()
    if not replica or not replica.Data or not replica.Data.Currency then
        return 0
    end
    return math.round(replica.Data.Currency.Cash)
end

local function get_trade_info(customer)
    local head = customer:FindFirstChild("Head")
    if not head then return nil end
    
    local trade_gui = head:FindFirstChild("Trade")
    if not trade_gui or not trade_gui.Enabled then return nil end
    
    local trade_brainrot_gui = trade_gui:FindFirstChild("Trade")
    if not trade_brainrot_gui then return nil end
    
    local frame = trade_brainrot_gui:FindFirstChild("Frame")
    if not frame then return nil end
    
    local npc_offer = frame:FindFirstChild("Them")
    if not npc_offer then return nil end
    
    local your_offer = frame:FindFirstChild("You")
    if not your_offer then return nil end
    
    local fairness_meter = trade_gui:FindFirstChild("FairnessMeter")
    if not fairness_meter then return nil end
    
    local trade_fairness = fairness_meter:FindFirstChild("TradeFairness")
    if not trade_fairness then return nil end
    
    local trade_text = trade_fairness:FindFirstChild("TextLabel")
    if not trade_text then return nil end
    
    return {
        npc_offer = npc_offer,
        your_offer = your_offer,
        trade_text = trade_text,
        position_scale = trade_fairness.Position.X.Scale
    }
end

local function count_brainrots_in_offer(npc_offer)
    local count = 0
    for _, v in npc_offer:GetChildren() do
        -- Ignorer Icon, Seperator, et CustomerExtra (+1)
        if v:IsA("Frame") and v.Name ~= "Icon" and v.Name ~= "Seperator" and v.Name ~= "CustomerExtra" then
            count = count + 1
        end
    end
    return count
end

-- Extraire le prix d'un brainrot depuis le texte (ex: "$645/s" -> 645)
local function extract_price_from_text(text)
    if not text then return 0 end
    local price = string.match(text, "%$([%d%.]+)")
    return tonumber(price) or 0
end

-- Calculer la valeur totale d'une offre
local function calculate_offer_value(offer_frame)
    local total = 0
    for _, item in offer_frame:GetChildren() do
        if item:IsA("Frame") and item.Name ~= "Icon" and item.Name ~= "Seperator" and item.Name ~= "CustomerExtra" then
            -- Chercher le TextLabel avec le prix
            for _, child in item:GetDescendants() do
                if child:IsA("TextLabel") and child.Text:find("%$") then
                    local price = extract_price_from_text(child.Text)
                    total = total + price
                    break
                end
            end
        end
    end
    return total
end

-- Nouvelle logique de trade basée sur les prix
local function evaluate_trade(trade_info)
    local npc_offer = trade_info.npc_offer
    local your_offer = trade_info.your_offer
    
    if not npc_offer or not your_offer then
        return nil, "Missing offer data"
    end
    
    local npc_brainrot_count = count_brainrots_in_offer(npc_offer)
    local my_brainrot_count = count_brainrots_in_offer(your_offer)
    
    -- Vérifier les options pour trades multiples
    if npc_brainrot_count >= 2 and not flags.accept_multiple_npc then
        return "Decline", "NPC has 2+ brainrots (option disabled)"
    end
    
    if my_brainrot_count >= 2 and not flags.accept_multiple_mine then
        return "Decline", "You have 2+ brainrots (option disabled)"
    end
    
    -- Calculer les valeurs totales
    local npc_value = calculate_offer_value(npc_offer)
    local my_value = calculate_offer_value(your_offer)
    
    print(string.format("💰 Trade Evaluation: NPC=$%.1f/s vs MY=$%.1f/s", npc_value, my_value))
    
    -- Logique de décision basée sur les prix
    if my_value < npc_value then
        -- Je gagne au change
        return "Accept", string.format("Good trade! (+$%.1f/s)", npc_value - my_value)
    elseif my_value > npc_value then
        -- Je perds au change
        return "Decline", string.format("Bad trade! (-$%.1f/s)", my_value - npc_value)
    else
        -- Égalité
        return "AddMore", "Equal trade, requesting more"
    end
end

-- Fonction pour dump le contenu du trade
local function dump_trade_contents()
    print("==================== TRADE DUMP ====================")
    
    for _, customer in customers:GetChildren() do
        local head = customer:FindFirstChild("Head")
        if not head then continue end
        
        local trade_gui = head:FindFirstChild("Trade")
        if not trade_gui or not trade_gui.Enabled then continue end
        
        print("📦 Found active trade with:", customer.Name)
        
        local trade_brainrot_gui = trade_gui:FindFirstChild("Trade")
        if not trade_brainrot_gui then continue end
        
        local frame = trade_brainrot_gui:FindFirstChild("Frame")
        if not frame then continue end
        
        -- NPC Offer (ce qu'ils proposent)
        local npc_offer = frame:FindFirstChild("Them")
        if npc_offer then
            local npc_value = calculate_offer_value(npc_offer)
            local npc_count = count_brainrots_in_offer(npc_offer)
            print(string.format("  🎁 NPC OFFERS: %d brainrot(s), Total: $%.1f/s", npc_count, npc_value))
            for _, item in npc_offer:GetChildren() do
                if item:IsA("Frame") then
                    print("    - " .. item.Name .. " (ClassName: " .. item.ClassName .. ")")
                    
                    -- Chercher les détails de l'item
                    for _, child in item:GetDescendants() do
                        if child:IsA("TextLabel") then
                            print("      └─ Text: " .. child.Text)
                        elseif child:IsA("ImageLabel") then
                            print("      └─ Image: " .. child.Image)
                        end
                    end
                end
            end
        end
        
        -- Your Offer (ce que tu proposes)
        local your_offer = frame:FindFirstChild("You")
        if your_offer then
            local my_value = calculate_offer_value(your_offer)
            local my_count = count_brainrots_in_offer(your_offer)
            print(string.format("  💼 YOUR OFFERS: %d brainrot(s), Total: $%.1f/s", my_count, my_value))
            for _, item in your_offer:GetChildren() do
                if item:IsA("Frame") then
                    print("    - " .. item.Name .. " (ClassName: " .. item.ClassName .. ")")
                    
                    for _, child in item:GetDescendants() do
                        if child:IsA("TextLabel") then
                            print("      └─ Text: " .. child.Text)
                        elseif child:IsA("ImageLabel") then
                            print("      └─ Image: " .. child.Image)
                        end
                    end
                end
            end
        end
        
        -- Trade Fairness
        local fairness_meter = trade_gui:FindFirstChild("FairnessMeter")
        if fairness_meter then
            local trade_fairness = fairness_meter:FindFirstChild("TradeFairness")
            if trade_fairness then
                local trade_text = trade_fairness:FindFirstChild("TextLabel")
                if trade_text then
                    print("  ⚖️ TRADE FAIRNESS: " .. trade_text.Text)
                    print("  📊 Position Scale: " .. trade_fairness.Position.X.Scale)
                end
            end
        end
        
        -- Évaluation automatique
        local trade_info = get_trade_info(customer)
        if trade_info then
            local action, reason = evaluate_trade(trade_info)
            if action then
                print("  🎯 RECOMMENDED ACTION: " .. action)
                print("  📝 REASON: " .. reason)
            end
        end
        
        print("====================================================")
    end
    
    print("✅ Trade dump complete!")
end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎀 Astolfo Ware - Steal A Brainrot",
    LoadingTitle = "Astolfo Ware",
    LoadingSubtitle = "by Astolfo",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AstolfoWare",
        FileName = "SAB_Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Créer un bouton toggle visible (pour mobile)
local function create_toggle_button()
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "AstolfoToggleButton"
    screen_gui.ResetOnSpawn = false
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen_gui.Parent = game:GetService("CoreGui")
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(1, -70, 0.5, -30)
    button.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = "🎀"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 30
    button.Parent = screen_gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200, 150, 160)
    stroke.Thickness = 3
    stroke.Parent = button
    
    -- Toggle l'UI Rayfield (compatible mobile)
    button.Activated:Connect(function()
        Rayfield:Toggle()
        print("🎀 UI toggled!")
        
        -- Animation
        button.Size = UDim2.new(0, 55, 0, 55)
        task.wait(0.1)
        button.Size = UDim2.new(0, 60, 0, 60)
    end)
    
    -- Feedback visuel
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(230, 170, 180)
    end)
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
    end)
    
    -- Drag (mobile + PC)
    local dragging = false
    local drag_input, drag_start, start_pos
    
    local function update(input)
        local delta = input.Position - drag_start
        button.Position = UDim2.new(
            start_pos.X.Scale,
            start_pos.X.Offset + delta.X,
            start_pos.Y.Scale,
            start_pos.Y.Offset + delta.Y
        )
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            drag_input = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == drag_input and dragging then
            update(input)
        end
    end)
    
    return screen_gui
end

local toggle_button_gui = create_toggle_button()

print("🎀 ASTOLFO WARE LOADED! Tap the pink button to toggle UI!")

-- Tabs
local MainTab = Window:CreateTab("🎯 Main", 4483362458)
local EggTab = Window:CreateTab("🥚 Eggs", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- Trade Section
local TradeSection = MainTab:CreateSection("Trade Automation")

local auto_trade_connection
local waiting_for_accept = false
MainTab:CreateToggle({
    Name = "Auto Trade",
    CurrentValue = false,
    Flag = "AutoTrade",
    Callback = function(value)
        flags.auto_trade = value
        waiting_for_accept = false
        
        if auto_trade_connection then
            auto_trade_connection:Disconnect()
            auto_trade_connection = nil
        end
        
        if flags.auto_trade then
            local last_trade_time = 0
            auto_trade_connection = run_service.Heartbeat:Connect(function()
                if tick() - last_trade_time < flags.auto_trade_delay then
                    return
                end
                
                for _, customer in customers:GetChildren() do
                    local trade_info = get_trade_info(customer)
                    if not trade_info then continue end
                    
                    -- Si on attend un accept après AddMore
                    if waiting_for_accept then
                        safe_call(function()
                            npc_trade_service:Clicked("Accept")
                            print("✅ Accepted after AddMore")
                        end)
                        waiting_for_accept = false
                        last_trade_time = tick()
                        break
                    end
                    
                    -- Évaluer le trade avec la nouvelle logique
                    local action, reason = evaluate_trade(trade_info)
                    
                    if not action then
                        print("⚠️ Could not evaluate trade:", reason)
                        continue
                    end
                    
                    print("🎯 Action:", action, "-", reason)
                    
                    safe_call(function()
                        npc_trade_service:Clicked(action)
                        
                        -- Si AddMore, préparer l'accept rapide
                        if action == "AddMore" then
                            waiting_for_accept = true
                        end
                    end)
                    
                    last_trade_time = tick()
                    break
                end
            end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Accept 2+ NPC Brainrots",
    CurrentValue = false,
    Flag = "AcceptMultipleNPC",
    Callback = function(value)
        flags.accept_multiple_npc = value
    end,
})

MainTab:CreateToggle({
    Name = "Accept 2+ My Brainrots",
    CurrentValue = false,
    Flag = "AcceptMultipleMine",
    Callback = function(value)
        flags.accept_multiple_mine = value
    end,
})

MainTab:CreateSlider({
    Name = "Auto Trade Delay (seconds)",
    Range = {0.5, 10},
    Increment = 0.5,
    CurrentValue = 1,
    Flag = "AutoTradeDelay",
    Callback = function(value)
        flags.auto_trade_delay = value
    end,
})

-- Plot Section
local PlotSection = MainTab:CreateSection("Plot Management")

local auto_collect_connection
MainTab:CreateToggle({
    Name = "Auto Collect Cash",
    CurrentValue = false,
    Flag = "AutoCollectCash",
    Callback = function(value)
        flags.auto_collect_cash = value
        
        if auto_collect_connection then
            auto_collect_connection:Disconnect()
            auto_collect_connection = nil
        end
        
        if flags.auto_collect_cash then
            local last_collect_time = 0
            auto_collect_connection = run_service.Heartbeat:Connect(function()
                if tick() - last_collect_time < flags.auto_collect_cash_delay then
                    return
                end
                
                local character = local_player.Character
                if not character or not character.PrimaryPart then return end
                
                for _, slot in brainrot_slots:GetChildren() do
                    local item_folder = slot:FindFirstChild("Item")
                    if not item_folder or not item_folder:FindFirstChild("Brainrot") then
                        continue
                    end
                    
                    local cash_collect = slot:FindFirstChild("CashCollect")
                    if cash_collect then
                        safe_call(function()
                            firetouchinterest(character.PrimaryPart, cash_collect, 0)
                            firetouchinterest(character.PrimaryPart, cash_collect, 1)
                        end)
                    end
                end
                
                last_collect_time = tick()
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "Collect Cash Delay (seconds)",
    Range = {1, 60},
    Increment = 1,
    CurrentValue = 1,
    Flag = "CollectDelay",
    Callback = function(value)
        flags.auto_collect_cash_delay = value
    end,
})

-- Sell Section
local SellSection = MainTab:CreateSection("Sell Brainrots")

MainTab:CreateButton({
    Name = "Sell Held Brainrot",
    Callback = function()
        local brainrot = held_brainrot()
        if not brainrot then
            Rayfield:Notify({
                Title = "Error",
                Content = "Not holding a brainrot",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end
        
        safe_call(function()
            sell_brainrot_service:Sell():await()
            Rayfield:Notify({
                Title = "Success",
                Content = "Sold brainrot!",
                Duration = 3,
                Image = 4483362458,
            })
        end)
    end,
})

MainTab:CreateButton({
    Name = "Sell All Brainrots",
    Callback = function()
        safe_call(function()
            sell_brainrot_service:SellAll():await()
            Rayfield:Notify({
                Title = "Success",
                Content = "Sold all brainrots!",
                Duration = 3,
                Image = 4483362458,
            })
        end)
    end,
})

-- Egg Tab
local EggSection = EggTab:CreateSection("Egg Automation")

local auto_egg_connection
EggTab:CreateToggle({
    Name = "Auto Buy Eggs",
    CurrentValue = false,
    Flag = "AutoBuyEggs",
    Callback = function(value)
        flags.auto_buy_eggs = value
        
        if auto_egg_connection then
            auto_egg_connection:Disconnect()
            auto_egg_connection = nil
        end
        
        if flags.auto_buy_eggs then
            local last_buy_time = 0
            auto_egg_connection = run_service.Heartbeat:Connect(function()
                if tick() - last_buy_time < flags.auto_buy_eggs_delay then
                    return
                end
                
                local current_money = get_money()
                
                for _, egg_obj in player_eggs:GetChildren() do
                    local hitbox = egg_obj:FindFirstChild("Hitbox")
                    if not hitbox then continue end
                    
                    local top_attachment = hitbox:FindFirstChild("TopAttachment")
                    if not top_attachment then continue end
                    
                    local egg_purchase = top_attachment:FindFirstChild("EggPurchase")
                    if not egg_purchase then continue end
                    
                    local frame = egg_purchase:FindFirstChild("Frame")
                    if not frame then continue end
                    
                    local egg_name_label = frame:FindFirstChild("EggName")
                    if not egg_name_label then continue end
                    
                    local egg_name = egg_name_label.Text
                    
                    for _, selected_egg in ipairs(selected_eggs) do
                        if egg_name == selected_egg then
                            local egg_cost = get_egg_price(selected_egg)
                            if current_money >= egg_cost then
                                safe_call(function()
                                    egg_service:BuyEgg(egg_obj.Name)
                                    current_money = current_money - egg_cost
                                end)
                            end
                            break
                        end
                    end
                end
                
                last_buy_time = tick()
            end)
        end
    end,
})

EggTab:CreateSlider({
    Name = "Buy Eggs Delay (seconds)",
    Range = {1, 60},
    Increment = 1,
    CurrentValue = 1,
    Flag = "EggDelay",
    Callback = function(value)
        flags.auto_buy_eggs_delay = value
    end,
})

EggTab:CreateDropdown({
    Name = "Select Eggs to Buy",
    Options = eggs,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SelectedEggs",
    Callback = function(options)
        selected_eggs = options
    end,
})

-- Player Tab
local PlayerSection = PlayerTab:CreateSection("Player Settings")

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(value)
        flags.anti_afk = value
    end,
})

local_player.Idled:Connect(function()
    if flags.anti_afk then
        virtual_user:CaptureController()
        virtual_user:ClickButton2(Vector2.new())
    end
end)

PlayerTab:CreateInput({
    Name = "Join Private Server",
    PlaceholderText = "Enter server code",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text and text ~= "" then
            Rayfield:Notify({
                Title = "Joining Server",
                Content = "Code: " .. text,
                Duration = 2,
                Image = 4483362458,
            })
            safe_call(function()
                game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(game.PlaceId, "", text)
            end)
        end
    end,
})

-- Misc Section
local MiscSection = PlayerTab:CreateSection("Miscellaneous")

local auto_wheel_connection
PlayerTab:CreateToggle({
    Name = "Auto Wheel Spin",
    CurrentValue = false,
    Flag = "AutoWheel",
    Callback = function(value)
        flags.auto_wheel = value
        
        if auto_wheel_connection then
            auto_wheel_connection:Disconnect()
            auto_wheel_connection = nil
        end
        
        if flags.auto_wheel then
            auto_wheel_connection = run_service.Heartbeat:Connect(function()
                if get_spins("Galaxy") > 0 then
                    safe_call(function()
                        spin_service:Spin()
                    end)
                end
            end)
        end
    end,
})

-- Settings Tab
local InfoSection = SettingsTab:CreateSection("Information")

SettingsTab:CreateParagraph({
    Title = "🎀 Astolfo Ware",
    Content = "Steal A Brainrot automation script. Configure your settings in the Main and Eggs tabs."
})

SettingsTab:CreateButton({
    Name = "Show Current Money",
    Callback = function()
        Rayfield:Notify({
            Title = "Current Balance",
            Content = "$" .. tostring(get_money()),
            Duration = 4,
            Image = 4483362458,
        })
    end,
})

-- Debug Section
local DebugSection = SettingsTab:CreateSection("Debug Tools")

SettingsTab:CreateButton({
    Name = "Dump Trade Contents",
    Callback = function()
        dump_trade_contents()
        Rayfield:Notify({
            Title = "Trade Dump",
            Content = "Check console (F9) for details!",
            Duration = 4,
            Image = 4483362458,
        })
    end,
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        if auto_trade_connection then auto_trade_connection:Disconnect() end
        if auto_collect_connection then auto_collect_connection:Disconnect() end
        if auto_egg_connection then auto_egg_connection:Disconnect() end
        if auto_wheel_connection then auto_wheel_connection:Disconnect() end
        
        if toggle_button_gui then toggle_button_gui:Destroy() end
        Rayfield:Destroy()
    end,
})

-- Load notification
Rayfield:Notify({
    Title = "✅ Loaded Successfully",
    Content = "Script loaded in " .. string.format("%.2f", tick() - start_tick) .. " seconds",
    Duration = 5,
    Image = 4483362458,
})
