-- Piexxie03 | Visual FOV Circle (Roblox Studio)
-- Pasang sebagai LocalScript di StarterPlayer > StarterPlayerScripts.
-- Ini hanya lingkaran visual; tidak mencari, memilih, atau mengunci pemain/NPC.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("PiexxieVisualFOV")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "PiexxieVisualFOV"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Lingkaran merah yang selalu berada di tengah layar.
local circle = Instance.new("Frame")
circle.Name = "FOVCircle"
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.fromScale(0.5, 0.5)
circle.Size = UDim2.fromOffset(180, 180)
circle.BackgroundTransparency = 1
circle.Visible = false
circle.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = circle

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 35, 35)
stroke.Thickness = 2
stroke.Transparency = 0
stroke.Parent = circle

-- Panel pengaturan sederhana.
local panel = Instance.new("Frame")
panel.Name = "ControlPanel"
panel.Size = UDim2.fromOffset(230, 112)
panel.Position = UDim2.new(0, 16, 0.5, -56)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 25)
title.Position = UDim2.fromOffset(8, 5)
title.BackgroundTransparency = 1
title.Text = "PIEXXIE03 | VISUAL FOV"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(88, 27)
toggle.Position = UDim2.fromOffset(8, 36)
toggle.BackgroundColor3 = Color3.fromRGB(125, 45, 45)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 12
toggle.Font = Enum.Font.GothamBold
toggle.Text = "FOV: OFF"
toggle.Parent = panel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggle

local sizeText = Instance.new("TextLabel")
sizeText.Size = UDim2.fromOffset(116, 24)
sizeText.Position = UDim2.fromOffset(105, 37)
sizeText.BackgroundTransparency = 1
sizeText.Text = "Ukuran: 180"
sizeText.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeText.TextSize = 12
sizeText.Font = Enum.Font.Gotham
sizeText.Parent = panel

local minus = Instance.new("TextButton")
minus.Size = UDim2.fromOffset(32, 27)
minus.Position = UDim2.fromOffset(8, 73)
minus.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
minus.Text = "-"
minus.TextColor3 = Color3.new(1, 1, 1)
minus.TextSize = 18
minus.Font = Enum.Font.GothamBold
minus.Parent = panel

local plus = Instance.new("TextButton")
plus.Size = UDim2.fromOffset(32, 27)
plus.Position = UDim2.fromOffset(48, 73)
plus.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
plus.Text = "+"
plus.TextColor3 = Color3.new(1, 1, 1)
plus.TextSize = 18
plus.Font = Enum.Font.GothamBold
plus.Parent = panel

local hint = Instance.new("TextLabel")
hint.Size = UDim2.fromOffset(132, 27)
hint.Position = UDim2.fromOffset(89, 73)
hint.BackgroundTransparency = 1
hint.Text = "Tombol F6: tampil/sembunyi"
hint.TextColor3 = Color3.fromRGB(190, 190, 200)
hint.TextSize = 10
hint.Font = Enum.Font.Gotham
hint.Parent = panel

local diameter = 180
local enabled = false

local function updateCircle()
    circle.Size = UDim2.fromOffset(diameter, diameter)
    sizeText.Text = "Ukuran: " .. diameter
    circle.Visible = enabled
    toggle.Text = enabled and "FOV: ON" or "FOV: OFF"
    toggle.BackgroundColor3 = enabled
        and Color3.fromRGB(35, 125, 65)
        or Color3.fromRGB(125, 45, 45)
end

toggle.Activated:Connect(function()
    enabled = not enabled
    updateCircle()
end)

minus.Activated:Connect(function()
    diameter = math.max(60, diameter - 20)
    updateCircle()
end)

plus.Activated:Connect(function()
    diameter = math.min(600, diameter + 20)
    updateCircle()
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        enabled = not enabled
        updateCircle()
    end
end)

updateCircle()
