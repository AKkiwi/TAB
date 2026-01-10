-- TEST SIMPLE ROBLOX - VERSION MOBILE
print("🔥 SCRIPT STARTED!")

local player = game:GetService("Players").LocalPlayer
local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = "TestGUI"
screen_gui.ResetOnSpawn = false

-- Essayer CoreGui d'abord
local success = pcall(function()
    screen_gui.Parent = game:GetService("CoreGui")
end)

if not success then
    screen_gui.Parent = player:WaitForChild("PlayerGui")
end

-- Frame container
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 350, 0, 250)
container.Position = UDim2.new(0.5, -175, 0.5, -125)
container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
container.BorderSizePixel = 0
container.Parent = screen_gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = container

-- Titre
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 60)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "✅ SCRIPT OK!"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextSize = 28
title.Parent = container

-- Message
local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -20, 0, 80)
message.Position = UDim2.new(0, 10, 0, 80)
message.BackgroundTransparency = 1
message.Font = Enum.Font.Gotham
message.Text = "Le GUI fonctionne!\nTape le bouton rouge ci-dessous"
message.TextColor3 = Color3.fromRGB(255, 255, 255)
message.TextSize = 18
message.TextWrapped = true
message.Parent = container

-- BOUTON (dans le container cette fois)
local close_button = Instance.new("TextButton")
close_button.Size = UDim2.new(0.8, 0, 0, 60)
close_button.Position = UDim2.new(0.1, 0, 1, -70)
close_button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
close_button.BorderSizePixel = 0
close_button.Font = Enum.Font.GothamBold
close_button.Text = "❌ FERMER"
close_button.TextColor3 = Color3.fromRGB(255, 255, 255)
close_button.TextSize = 22
close_button.Parent = container

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 10)
corner2.Parent = close_button

print("✅ Bouton créé! Position:", close_button.Position)
print("✅ Bouton visible:", close_button.Visible)
print("✅ Bouton taille:", close_button.Size)

-- Clic compatible mobile
close_button.Activated:Connect(function()
    print("❌ BOUTON CLIQUÉ!")
    message.Text = "Bouton fonctionne!\nFermeture..."
    task.wait(1)
    screen_gui:Destroy()
end)

-- Animation visuelle
close_button.MouseButton1Down:Connect(function()
    print("👇 Bouton appuyé")
    close_button.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    close_button.Size = UDim2.new(0.75, 0, 0, 55)
end)

close_button.MouseButton1Up:Connect(function()
    print("👆 Bouton relâché")
    close_button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    close_button.Size = UDim2.new(0.8, 0, 0, 60)
end)

print("✅ GUI complet créé!")
print("📍 Parent:", screen_gui.Parent.Name)

-- Test après 3 secondes
task.wait(3)
title.Text = "⏰ 3 SECONDES!"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
message.Text = "Timer fonctionne!\nBouton visible en bas"
print("⏰ 3 secondes OK")

-- Compte à rebours
task.wait(7)
for i = 10, 1, -1 do
    message.Text = "Auto-fermeture dans "..i.." sec\nOu tape le bouton rouge"
    task.wait(1)
end

screen_gui:Destroy()
print("🔚 Fin du test")
