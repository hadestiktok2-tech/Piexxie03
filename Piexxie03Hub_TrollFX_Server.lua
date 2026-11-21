-- Piexxie03Hub Shared Troll FX
-- Pasang sebagai Script di ServerScriptService pada EXPERIENCE MILIKMU.
-- Efek aman: Highlight neon + tulisan lucu, tanpa mengubah gerakan/health pemain.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Untuk game milik akun pribadi, pemilik otomatis diizinkan.
-- Untuk game milik grup, tambahkan UserId admin ke daftar ini, contoh: [123456789] = true
local ADMIN_USER_IDS = {
    -- [123456789] = true,
}

local EVENT_NAME = "PiexxieSharedTrollFX"
local COOLDOWN_SECONDS = 8
local EFFECT_SECONDS = 4
local lastUse = {}

local event = ReplicatedStorage:FindFirstChild(EVENT_NAME)
if event and not event:IsA("RemoteEvent") then
    error(EVENT_NAME .. " sudah dipakai oleh objek yang bukan RemoteEvent")
end
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = EVENT_NAME
    event.Parent = ReplicatedStorage
end

local function isAdmin(player)
    if ADMIN_USER_IDS[player.UserId] == true then return true end
    if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
        return true
    end
    return false
end

event.OnServerEvent:Connect(function(sender, targetUserId)
    if not isAdmin(sender) then return end
    if typeof(targetUserId) ~= "number" then return end

    local now = os.clock()
    if lastUse[sender.UserId] and now - lastUse[sender.UserId] < COOLDOWN_SECONDS then return end

    local target = Players:GetPlayerByUserId(targetUserId)
    if not target or target == sender then return end
    local character = target.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local head = character and character:FindFirstChild("Head")
    if not character or not humanoid or humanoid.Health <= 0 or not root then return end

    lastUse[sender.UserId] = now

    local highlight = Instance.new("Highlight")
    highlight.Name = "PiexxieNeonSurprise"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 30, 90)
    highlight.OutlineColor = Color3.fromRGB(80, 220, 255)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    Debris:AddItem(highlight, EFFECT_SECONDS)

    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PiexxieTrollMessage"
        billboard.Adornee = head
        billboard.Size = UDim2.fromOffset(180, 44)
        billboard.StudsOffset = Vector3.new(0, 3.2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "KENA NEON!"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.15
        label.TextStrokeColor3 = Color3.fromRGB(255, 20, 100)
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.Parent = billboard
        Debris:AddItem(billboard, EFFECT_SECONDS)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastUse[player.UserId] = nil
end)
