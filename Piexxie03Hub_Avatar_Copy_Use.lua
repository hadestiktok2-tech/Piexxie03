--[[
    Piexxie03Hub
    Simple standalone UI
    Place this as a LocalScript in StarterPlayerScripts or StarterGui.
    Intended for your own Roblox experience in Roblox Studio.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local WALK_SPEED_DEFAULT = 16
local WALK_SPEED_MAX = 100

local walkSpeed = WALK_SPEED_DEFAULT
local infiniteJumpEnabled = false
local minimized = false

local oldGui = playerGui:FindFirstChild("Piexxie03Hub")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "Piexxie03Hub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 30, 60)
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

local function makeLabel(parent, text, size, position, fontSize, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextSize = fontSize or 13
    label.TextColor3 = color or Color3.fromRGB(245, 245, 247)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function makeButton(parent, text, size, position)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(245, 245, 247)
    button.Parent = parent
    addCorner(button, 7)
    return button
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(310, 520)
main.Position = UDim2.new(0.5, -155, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
main.BorderSizePixel = 0
main.Parent = gui
addCorner(main, 10)
addStroke(main, Color3.fromRGB(255, 30, 60), 1.4)

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 46)
topbar.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
topbar.BorderSizePixel = 0
topbar.Parent = main
addCorner(topbar, 10)

local title = makeLabel(
    topbar,
    "☠  PIEXXIE03HUB",
    UDim2.new(1, -105, 1, 0),
    UDim2.fromOffset(14, 0),
    16,
    Color3.fromRGB(255, 70, 95)
)
title.Font = Enum.Font.GothamBold

local minimizeButton = makeButton(topbar, "—", UDim2.fromOffset(30, 28), UDim2.new(1, -72, 0, 9))
minimizeButton.BackgroundColor3 = Color3.fromRGB(41, 41, 51)

local closeButton = makeButton(topbar, "X", UDim2.fromOffset(30, 28), UDim2.new(1, -36, 0, 9))
closeButton.BackgroundColor3 = Color3.fromRGB(201, 22, 48)

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -24, 1, -58)
content.Position = UDim2.fromOffset(12, 52)
content.BackgroundTransparency = 1
content.Parent = main

makeLabel(
    content,
    "MOVEMENT",
    UDim2.new(1, 0, 0, 20),
    UDim2.fromOffset(2, 0),
    10,
    Color3.fromRGB(146, 146, 159)
).Font = Enum.Font.GothamBold

local speedBox = Instance.new("TextBox")
speedBox.Name = "WalkSpeedInput"
speedBox.Size = UDim2.new(1, -104, 0, 38)
speedBox.Position = UDim2.fromOffset(0, 28)
speedBox.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
speedBox.BorderSizePixel = 0
speedBox.ClearTextOnFocus = false
speedBox.Font = Enum.Font.Gotham
speedBox.PlaceholderText = "WalkSpeed (default 16)"
speedBox.PlaceholderColor3 = Color3.fromRGB(119, 119, 131)
speedBox.Text = tostring(WALK_SPEED_DEFAULT)
speedBox.TextColor3 = Color3.fromRGB(245, 245, 247)
speedBox.TextSize = 13
speedBox.Parent = content
addCorner(speedBox, 7)

local applyButton = makeButton(
    content,
    "APPLY",
    UDim2.fromOffset(92, 38),
    UDim2.new(1, -92, 0, 28)
)
applyButton.BackgroundColor3 = Color3.fromRGB(255, 30, 60)

local speedStatus = makeLabel(
    content,
    "WalkSpeed: 16",
    UDim2.new(1, 0, 0, 20),
    UDim2.fromOffset(2, 72),
    11,
    Color3.fromRGB(182, 182, 194)
)

-- WalkSpeed slider (drag the knob to change speed).
local sliderTrack = Instance.new("Frame")
sliderTrack.Name = "WalkSpeedSlider"
sliderTrack.Size = UDim2.new(1, -4, 0, 8)
sliderTrack.Position = UDim2.fromOffset(2, 101)
sliderTrack.BackgroundColor3 = Color3.fromRGB(51, 51, 62)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = content
addCorner(sliderTrack, 6)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(walkSpeed / WALK_SPEED_MAX, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack
addCorner(sliderFill, 6)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.fromOffset(16, 16)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(walkSpeed / WALK_SPEED_MAX, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 70, 95)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderTrack
addCorner(sliderKnob, 8)
addStroke(sliderKnob, Color3.fromRGB(245, 245, 247), 1)

local sliderMin = makeLabel(
    content, "0", UDim2.fromOffset(24, 16),
    UDim2.fromOffset(2, 114), 10,
    Color3.fromRGB(146, 146, 159)
)
local sliderMax = makeLabel(
    content, "100", UDim2.fromOffset(35, 16),
    UDim2.new(1, -37, 0, 114), 10,
    Color3.fromRGB(146, 146, 159)
)
sliderMax.TextXAlignment = Enum.TextXAlignment.Right

local jumpButton = makeButton(
    content,
    "INFINITE JUMP  :  OFF",
    UDim2.new(1, 0, 0, 40),
    UDim2.fromOffset(0, 143)
)
jumpButton.BackgroundColor3 = Color3.fromRGB(41, 41, 51)

local refreshButton = makeButton(
    content,
    "↻  REFRESH CHARACTER",
    UDim2.new(1, 0, 0, 38),
    UDim2.fromOffset(0, 194)
)
refreshButton.BackgroundColor3 = Color3.fromRGB(41, 41, 51)

-- Avatar copy/use controls (for players in this server).
makeLabel(
    content,
    "AVATAR",
    UDim2.new(1, 0, 0, 18),
    UDim2.fromOffset(2, 240),
    10,
    Color3.fromRGB(146, 146, 159)
).Font = Enum.Font.GothamBold

local selectedPlayer = nil
local copiedDescription = nil

local playerSelectButton = makeButton(
    content,
    "SELECT PLAYER  ▼",
    UDim2.new(1, 0, 0, 34),
    UDim2.fromOffset(0, 261)
)
playerSelectButton.TextXAlignment = Enum.TextXAlignment.Left
playerSelectButton.Text = "  SELECT PLAYER  ▼"

local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, 0, 0, 100)
playerList.Position = UDim2.fromOffset(0, 300)
playerList.BackgroundColor3 = Color3.fromRGB(22, 22, 31)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.Visible = false
playerList.CanvasSize = UDim2.fromOffset(0, 0)
playerList.Parent = content
addCorner(playerList, 7)

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 3)
playerListLayout.Parent = playerList

local avatarActionRow = Instance.new("Frame")
avatarActionRow.Size = UDim2.new(1, 0, 0, 36)
avatarActionRow.Position = UDim2.fromOffset(0, 408)
avatarActionRow.BackgroundTransparency = 1
avatarActionRow.Parent = content

local copyAvatarButton = makeButton(
    avatarActionRow,
    "COPY AVATAR",
    UDim2.new(0.5, -4, 1, 0),
    UDim2.fromOffset(0, 0)
)
copyAvatarButton.BackgroundColor3 = Color3.fromRGB(41, 41, 51)

local useAvatarButton = makeButton(
    avatarActionRow,
    "USE AVATAR",
    UDim2.new(0.5, -4, 1, 0),
    UDim2.new(0.5, 4, 0, 0)
)
useAvatarButton.BackgroundColor3 = Color3.fromRGB(255, 30, 60)

local avatarStatus = makeLabel(
    content,
    "Choose a player, then copy their avatar.",
    UDim2.new(1, 0, 0, 18),
    UDim2.fromOffset(2, 446),
    9,
    Color3.fromRGB(182, 182, 194)
)

local function getHumanoid()
    local character = player.Character
    if not character then
        return nil
    end
    return character:FindFirstChildOfClass("Humanoid")
end

local function refreshPlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local count = 0
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            count += 1
            local item = makeButton(
                playerList,
                otherPlayer.DisplayName .. "  (@" .. otherPlayer.Name .. ")",
                UDim2.new(1, -6, 0, 30),
                UDim2.fromOffset(3, 0)
            )
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer
                playerSelectButton.Text = "  " .. otherPlayer.DisplayName .. "  ▼"
                playerList.Visible = false
                avatarStatus.Text = "Selected: " .. otherPlayer.Name
            end)
        end
    end

    playerList.CanvasSize = UDim2.fromOffset(0, count * 33)
    if count == 0 then
        avatarStatus.Text = "No other players in this server."
    end
end

playerSelectButton.MouseButton1Click:Connect(function()
    refreshPlayerList()
    playerList.Visible = not playerList.Visible
end)

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if selectedPlayer == leavingPlayer then
        selectedPlayer = nil
        copiedDescription = nil
        playerSelectButton.Text = "  SELECT PLAYER  ▼"
        avatarStatus.Text = "Selected player left the server."
    end
    refreshPlayerList()
end)

copyAvatarButton.MouseButton1Click:Connect(function()
    if not selectedPlayer or selectedPlayer.Parent ~= Players then
        avatarStatus.Text = "Select a player first."
        return
    end

    avatarStatus.Text = "Copying avatar..."
    local success, result = pcall(function()
        return Players:GetHumanoidDescriptionFromUserIdAsync(selectedPlayer.UserId)
    end)

    if success and result then
        copiedDescription = result
        avatarStatus.Text = "Avatar copied: " .. selectedPlayer.Name
    else
        avatarStatus.Text = "Could not copy this avatar."
        warn("[Piexxie03Hub] Avatar copy failed:", result)
    end
end)

useAvatarButton.MouseButton1Click:Connect(function()
    if not copiedDescription then
        avatarStatus.Text = "Copy an avatar first."
        return
    end

    local humanoid = getHumanoid()
    if not humanoid or humanoid.Health <= 0 then
        avatarStatus.Text = "Character is not ready."
        return
    end

    local success, err = pcall(function()
        humanoid:ApplyDescription(copiedDescription)
    end)

    if success then
        avatarStatus.Text = "Avatar applied locally."
    else
        avatarStatus.Text = "Could not apply avatar."
        warn("[Piexxie03Hub] Avatar apply failed:", err)
    end
end)

refreshButton.MouseButton1Click:Connect(function()
    local humanoid = getHumanoid()
    if humanoid and humanoid.Health > 0 then
        -- Reset the character; CharacterAdded reapplies the selected WalkSpeed.
        humanoid.Health = 0
    end
end)

local function applyWalkSpeed()
    local value = tonumber(speedBox.Text)
    if not value then
        speedStatus.Text = "Enter a valid number."
        return
    end

    walkSpeed = math.clamp(value, 0, WALK_SPEED_MAX)
    speedBox.Text = tostring(walkSpeed)

    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
    end

    speedStatus.Text = "WalkSpeed: " .. tostring(walkSpeed)
    local percent = walkSpeed / WALK_SPEED_MAX
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
end

applyButton.MouseButton1Click:Connect(applyWalkSpeed)

speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        applyWalkSpeed()
    end
end)

local sliderDragging = false

local function setWalkSpeedFromSlider(inputX)
    local trackWidth = sliderTrack.AbsoluteSize.X
    if trackWidth <= 0 then
        return
    end

    local relativeX = math.clamp(
        inputX - sliderTrack.AbsolutePosition.X,
        0,
        trackWidth
    )
    local percent = relativeX / trackWidth
    walkSpeed = math.floor(percent * WALK_SPEED_MAX + 0.5)

    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
    speedBox.Text = tostring(walkSpeed)
    speedStatus.Text = "WalkSpeed: " .. tostring(walkSpeed)

    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
    end
end

local function updateSliderFromInput(input)
    setWalkSpeedFromSlider(input.Position.X)
end

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSliderFromInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateSliderFromInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

jumpButton.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled

    if infiniteJumpEnabled then
        jumpButton.Text = "INFINITE JUMP  :  ON"
        jumpButton.BackgroundColor3 = Color3.fromRGB(201, 22, 48)
    else
        jumpButton.Text = "INFINITE JUMP  :  OFF"
        jumpButton.BackgroundColor3 = Color3.fromRGB(41, 41, 51)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not infiniteJumpEnabled then
        return
    end

    local humanoid = getHumanoid()
    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized

    if minimized then
        -- Collapse the whole hub into a small skull button.
        main.Size = UDim2.fromOffset(48, 48)
        topbar.Size = UDim2.fromOffset(48, 48)
        title.Visible = false
        closeButton.Visible = false
        minimizeButton.Size = UDim2.fromOffset(38, 38)
        minimizeButton.Position = UDim2.fromOffset(5, 5)
        minimizeButton.Text = "☠"
        minimizeButton.TextSize = 24
        minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
    else
        -- Restore the normal hub header and controls.
        main.Size = UDim2.fromOffset(310, 520)
        topbar.Size = UDim2.new(1, 0, 0, 46)
        title.Visible = true
        closeButton.Visible = true
        minimizeButton.Size = UDim2.fromOffset(30, 28)
        minimizeButton.Position = UDim2.new(1, -72, 0, 9)
        minimizeButton.Text = "—"
        minimizeButton.TextSize = 12
        minimizeButton.BackgroundColor3 = Color3.fromRGB(41, 41, 51)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Drag the window using the top bar (mouse or touch).
local dragging = false
local dragInput
local dragStart
local startPosition

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

print("[Piexxie03Hub] Loaded successfully.")
