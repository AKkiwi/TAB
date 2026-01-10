-- TEST SIMPLE ROBLOX
print("🔥 SCRIPT STARTED!")

-- Créer un texte visible à l'écran
local player = game:GetService("Players").LocalPlayer
local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = "TestGUI"
screen_gui.ResetOnSpawn = false

-- Essayer CoreGui d'abord (plus sûr), sinon PlayerGui
local success = pcall(function()
    screen_gui.Parent = game:GetService("CoreGui")
end)

if not success then
    screen_gui.Parent = player:WaitForChild("PlayerGui")
end

-- Créer le texte
local text_label = Instance.new("TextLabel")
text_label.Size = UDim2.new(0, 400, 0, 100)
text_label.Position = UDim2.new(0.5, -200, 0.5, -50)
text_label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
text_label.BorderSizePixel = 0
text_label.Font = Enum.Font.GothamBold
text_label.Text = "✅ SCRIPT FONCTIONNE!\nTap pour fermer"
text_label.TextColor3 = Color3.fromRGB(0, 255, 0)
text_label.TextSize = 24
text_label.TextWrapped = true
text_label.Parent = screen_gui

-- Coins arrondis
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = text_label

-- Bouton pour fermer
local close_button = Instance.new("TextButton")
close_button.Size = UDim2.new(0, 200, 0, 60)
close_button.Position = UDim2.new(0.5, -100, 1, 20)
close_button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
close_button.BorderSizePixel = 0
close_button.Font = Enum.Font.GothamBold
close_button.Text = "❌ FERMER"
close_button.TextColor3 = Color3.fromRGB(255, 255, 255)
close_button.TextSize = 20
close_button.Parent = screen_gui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 10)
corner2.Parent = close_button

-- Clic pour fermer (compatible mobile + PC)
close_button.Activated:Connect(function()
    print("❌ GUI fermé par l'utilisateur")
    screen_gui:Destroy()
end)

-- Feedback visuel quand on tape
close_button.MouseButton1Down:Connect(function()
    close_button.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
end)

close_button.MouseButton1Up:Connect(function()
    close_button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end)

print("✅ GUI créé avec succès!")
print("📍 Parent du GUI:", screen_gui.Parent.Name)

-- Test après 3 secondes
task.wait(3)
text_label.Text = "✅ TOUT FONCTIONNE!\n3 secondes écoulées"
text_label.TextColor3 = Color3.fromRGB(0, 255, 255)
print("⏰ 3 secondes écoulées - test réussi!")

-- Auto-destruction après 30 secondes
task.wait(27)
print("⚠️ Auto-destruction dans 3 secondes...")
text_label.Text = "Fermeture dans 3..."
task.wait(1)
text_label.Text = "Fermeture dans 2..."
task.wait(1)
text_label.Text = "Fermeture dans 1..."
task.wait(1)
screen_gui:Destroy()
print("🔚 Script terminé")
