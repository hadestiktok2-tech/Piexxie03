-- AUTO WALK RECORD & REPLAY
print("[WalkRecordReplay] Skrip mulai dijalankan")
-- Versi dengan simpan/muat/hapus konfigurasi, daftar yang bisa digulir,
-- serta tombol minimalkan, pulihkan, dan tutup.
-- Penyimpanan permanen memakai API executor: writefile/readfile/isfile/listfiles/delfile.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local CONFIG_FOLDER = "WalkRecordReplayConfigs"

local recording = false
local playing = false
local autoLoop = true
local infinityJump = false
local speedMultiplier = 1
local records = {}
local playbackIndex = 1
local playbackStart = 0
local minimized = false
local maximized = false
local selectedConfig = nil
local originalSize = UDim2.fromOffset(300, 470)

local function getCharacter()
    return player.Character
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local statusLabel

local function setStatus(message)
    if statusLabel then
        statusLabel.Text = "Status: " .. tostring(message)
    end
end

local function hasFileApi()
    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
        and type(listfiles) == "function"
end

local function prepareFolder()
    if type(isfolder) == "function" and type(makefolder) == "function" then
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
        return true
    end
    return false
end

local function cleanName(name)
    name = tostring(name or "")
    name = name:gsub("[^%w_%- ]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("%s+", "_")
    return name:sub(1, 40)
end

local function configPath(name)
    return CONFIG_FOLDER .. "/" .. name .. ".json"
end

local function encodeRecords(source)
    local output = {}
    for i, item in ipairs(source) do
        output[i] = {
            t = item.t,
            cf = {item.cf:GetComponents()},
            velocity = {item.velocity.X, item.velocity.Y, item.velocity.Z},
            state = item.state,
            walkSpeed = item.walkSpeed
        }
    end
    return output
end

local function decodeRecords(source)
    local output = {}
    local unpackValues = table.unpack or unpack
    for _, item in ipairs(source or {}) do
        if type(item) == "table" and type(item.cf) == "table" and #item.cf >= 12 then
            output[#output + 1] = {
                t = tonumber(item.t) or 0,
                cf = CFrame.new(unpackValues(item.cf)),
                velocity = Vector3.new(
                    tonumber(item.velocity and item.velocity[1]) or 0,
                    tonumber(item.velocity and item.velocity[2]) or 0,
                    tonumber(item.velocity and item.velocity[3]) or 0
                ),
                state = item.state,
                walkSpeed = tonumber(item.walkSpeed) or 16
            }
        end
    end
    return output
end

local function getConfigNames()
    local names = {}
    if not hasFileApi() then
        return names
    end
    prepareFolder()
    local ok, files = pcall(listfiles, CONFIG_FOLDER)
    if not ok or type(files) ~= "table" then
        return names
    end
    for _, path in ipairs(files) do
        local name = tostring(path):match("([^/\\]+)%.json$")
        if name then
            names[#names + 1] = name
        end
    end
    table.sort(names)
    return names
end

-- GUI
local playerGui = player:WaitForChild("PlayerGui")
local guiParent = playerGui

-- Beberapa executor Android menyediakan gethui() untuk GUI executor.
if type(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok and hui then
        guiParent = hui
    end
end

local oldGui = guiParent:FindFirstChild("WalkRecordReplay")
if oldGui then
    oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WalkRecordReplay"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = originalSize
main.Position = UDim2.new(0.5, -150, 0.5, -235)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -132, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "RECORD & REPLAY"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local function makeButton(parent, text, position, size, color)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color or Color3.fromRGB(55, 95, 145)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = true
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    return button
end

local minimizeButton = makeButton(header, "—", UDim2.new(1, -120, 0, 6), UDim2.fromOffset(32, 26), Color3.fromRGB(80, 80, 95))
local maximizeButton = makeButton(header, "□", UDim2.new(1, -82, 0, 6), UDim2.fromOffset(32, 26), Color3.fromRGB(80, 80, 95))
local closeButton = makeButton(header, "X", UDim2.new(1, -44, 0, 6), UDim2.fromOffset(32, 26), Color3.fromRGB(150, 55, 55))

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Content"
scroll.Position = UDim2.fromOffset(8, 44)
scroll.Size = UDim2.new(1, -16, 1, -52)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = main

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 7)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = scroll

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingBottom = UDim.new(0, 8)
contentPadding.PaddingLeft = UDim.new(0, 2)
contentPadding.PaddingRight = UDim.new(0, 2)
contentPadding.Parent = scroll

local function makeWideButton(text, color)
    local button = makeButton(scroll, text, UDim2.new(), UDim2.new(1, 0, 0, 34), color)
    button.LayoutOrder = #scroll:GetChildren()
    return button
end

local recordButton = makeWideButton("RECORD", Color3.fromRGB(40, 130, 75))
local stopRecordButton = makeWideButton("STOP RECORD", Color3.fromRGB(145, 75, 55))
local playButton = makeWideButton("PLAY", Color3.fromRGB(45, 105, 160))
local stopPlayButton = makeWideButton("STOP REPLAY", Color3.fromRGB(145, 75, 55))
local loopButton = makeWideButton("AUTO LOOP: ON", Color3.fromRGB(75, 95, 145))
local jumpButton = makeWideButton("INFINITY JUMP: OFF", Color3.fromRGB(75, 95, 145))

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 24)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Kecepatan replay: 1.00x"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 13
speedLabel.Font = Enum.Font.Gotham
speedLabel.LayoutOrder = 7
speedLabel.Parent = scroll

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(1, 0, 0, 28)
speedSlider.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
speedSlider.BorderSizePixel = 0
speedSlider.Text = "Tekan untuk ubah kecepatan (0.25x - 3x)"
speedSlider.TextColor3 = Color3.new(1, 1, 1)
speedSlider.TextSize = 11
speedSlider.Font = Enum.Font.Gotham
speedSlider.LayoutOrder = 8
speedSlider.Parent = scroll
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 6)

local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(1, 0, 0, 24)
configTitle.BackgroundTransparency = 1
configTitle.Text = "KONFIGURASI"
configTitle.TextColor3 = Color3.fromRGB(220, 220, 235)
configTitle.TextSize = 13
configTitle.Font = Enum.Font.GothamBold
configTitle.TextXAlignment = Enum.TextXAlignment.Left
configTitle.LayoutOrder = 9
configTitle.Parent = scroll

local configName = Instance.new("TextBox")
configName.Size = UDim2.new(1, 0, 0, 34)
configName.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
configName.BorderSizePixel = 0
configName.PlaceholderText = "Nama konfigurasi..."
configName.Text = ""
configName.TextColor3 = Color3.new(1, 1, 1)
configName.PlaceholderColor3 = Color3.fromRGB(160, 160, 170)
configName.TextSize = 13
configName.Font = Enum.Font.Gotham
configName.ClearTextOnFocus = false
configName.LayoutOrder = 10
configName.Parent = scroll
Instance.new("UICorner", configName).CornerRadius = UDim.new(0, 6)

local saveButton = makeWideButton("SIMPAN KONFIGURASI", Color3.fromRGB(40, 120, 85))
saveButton.LayoutOrder = 11
local loadButton = makeWideButton("MUAT KONFIGURASI TERPILIH", Color3.fromRGB(45, 105, 160))
loadButton.LayoutOrder = 12
local deleteButton = makeWideButton("HAPUS KONFIGURASI TERPILIH", Color3.fromRGB(145, 65, 65))
deleteButton.LayoutOrder = 13

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, 0, 0, 23)
listTitle.BackgroundTransparency = 1
listTitle.Text = "DAFTAR KONFIGURASI (ketuk untuk memilih)"
listTitle.TextColor3 = Color3.fromRGB(220, 220, 235)
listTitle.TextSize = 12
listTitle.Font = Enum.Font.GothamBold
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.LayoutOrder = 14
listTitle.Parent = scroll

local configList = Instance.new("Frame")
configList.Size = UDim2.new(1, 0, 0, 8)
configList.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
configList.BorderSizePixel = 0
configList.LayoutOrder = 15
configList.Parent = scroll
Instance.new("UICorner", configList).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = configList

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 32)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Siap"
statusLabel.TextColor3 = Color3.fromRGB(190, 220, 190)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.LayoutOrder = 16
statusLabel.Parent = scroll

local function refreshConfigList()
    for _, child in ipairs(configList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local names = getConfigNames()
    for index, name in ipairs(names) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -8, 0, 29)
        button.Position = UDim2.fromOffset(4, 0)
        button.BackgroundColor3 = (selectedConfig == name)
            and Color3.fromRGB(65, 100, 145)
            or Color3.fromRGB(48, 48, 60)
        button.BorderSizePixel = 0
        button.Text = name
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 12
        button.Font = Enum.Font.Gotham
        button.LayoutOrder = index
        button.Parent = configList
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
        button.MouseButton1Click:Connect(function()
            selectedConfig = name
            configName.Text = name
            refreshConfigList()
            setStatus("Dipilih: " .. name)
        end)
    end

    task.defer(function()
        configList.Size = UDim2.new(1, 0, 0, math.max(8, listLayout.AbsoluteContentSize.Y + 8))
    end)
end

local function stopRecording()
    recording = false
    setStatus("Perekaman berhenti (" .. #records .. " titik)")
end

local function stopPlayback()
    playing = false
    setStatus("Replay dihentikan")
end

recordButton.MouseButton1Click:Connect(function()
    local root = getRoot()
    if not root then
        setStatus("Karakter belum siap")
        return
    end
    records = {}
    recording = true
    playing = false
    playbackStart = tick()
    setStatus("Merekam...")
end)

stopRecordButton.MouseButton1Click:Connect(stopRecording)

playButton.MouseButton1Click:Connect(function()
    if #records < 2 then
        setStatus("Belum ada rekaman yang cukup")
        return
    end
    recording = false
    playing = true
    playbackIndex = 1
    playbackStart = tick()
    setStatus("Memutar rekaman...")
end)

stopPlayButton.MouseButton1Click:Connect(stopPlayback)

loopButton.MouseButton1Click:Connect(function()
    autoLoop = not autoLoop
    loopButton.Text = "AUTO LOOP: " .. (autoLoop and "ON" or "OFF")
end)

jumpButton.MouseButton1Click:Connect(function()
    infinityJump = not infinityJump
    jumpButton.Text = "INFINITY JUMP: " .. (infinityJump and "ON" or "OFF")
end)

speedSlider.MouseButton1Click:Connect(function()
    speedMultiplier = speedMultiplier + 0.25
    if speedMultiplier > 3 then
        speedMultiplier = 0.25
    end
    speedLabel.Text = string.format("Kecepatan replay: %.2fx", speedMultiplier)
end)

saveButton.MouseButton1Click:Connect(function()
    if not hasFileApi() then
        setStatus("API file executor tidak tersedia")
        return
    end
    local name = cleanName(configName.Text)
    if name == "" then
        setStatus("Masukkan nama konfigurasi")
        return
    end
    if #records == 0 then
        setStatus("Belum ada rekaman untuk disimpan")
        return
    end
    local ok, err = pcall(function()
        prepareFolder()
        local data = {
            version = 1,
            speedMultiplier = speedMultiplier,
            autoLoop = autoLoop,
            infinityJump = infinityJump,
            records = encodeRecords(records)
        }
        writefile(configPath(name), HttpService:JSONEncode(data))
    end)
    if ok then
        selectedConfig = name
        refreshConfigList()
        setStatus("Konfigurasi disimpan: " .. name)
    else
        setStatus("Gagal menyimpan: " .. tostring(err))
    end
end)

loadButton.MouseButton1Click:Connect(function()
    if not hasFileApi() then
        setStatus("API file executor tidak tersedia")
        return
    end
    local name = selectedConfig or cleanName(configName.Text)
    if name == "" then
        setStatus("Pilih konfigurasi terlebih dahulu")
        return
    end
    local path = configPath(name)
    if not isfile(path) then
        setStatus("File konfigurasi tidak ditemukan")
        return
    end
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(result) ~= "table" then
        setStatus("Gagal membaca konfigurasi")
        return
    end
    records = decodeRecords(result.records)
    speedMultiplier = math.clamp(tonumber(result.speedMultiplier) or 1, 0.25, 3)
    autoLoop = result.autoLoop ~= false
    infinityJump = result.infinityJump == true
    loopButton.Text = "AUTO LOOP: " .. (autoLoop and "ON" or "OFF")
    jumpButton.Text = "INFINITY JUMP: " .. (infinityJump and "ON" or "OFF")
    speedLabel.Text = string.format("Kecepatan replay: %.2fx", speedMultiplier)
    selectedConfig = name
    refreshConfigList()
    setStatus("Dimuat: " .. name .. " (" .. #records .. " titik)")
end)

deleteButton.MouseButton1Click:Connect(function()
    if type(delfile) ~= "function" or type(isfile) ~= "function" then
        setStatus("Fitur hapus file tidak tersedia")
        return
    end
    local name = selectedConfig or cleanName(configName.Text)
    if name == "" then
        setStatus("Pilih konfigurasi yang ingin dihapus")
        return
    end
    local path = configPath(name)
    if not isfile(path) then
        setStatus("File tidak ditemukan")
        return
    end
    local ok, err = pcall(delfile, path)
    if ok then
        selectedConfig = nil
        configName.Text = ""
        refreshConfigList()
        setStatus("Dihapus: " .. name)
    else
        setStatus("Gagal menghapus: " .. tostring(err))
    end
end)

-- Geser jendela melalui bagian header.
do
    local dragging = false
    local dragInput, dragStart, startPosition

    header.InputBegan:Connect(function(input)
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

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

local function updateResponsiveSize()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local width = math.clamp(viewport.X * 0.42, 280, 390)
    local height = math.clamp(viewport.Y * 0.82, 360, 620)
    main.Size = UDim2.fromOffset(width, height)
    main.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
end

minimizeButton.MouseButton1Click:Connect(function()
    if minimized then
        scroll.Visible = true
        main.Size = originalSize
        minimized = false
    else
        originalSize = main.Size
        scroll.Visible = false
        main.Size = UDim2.fromOffset(220, 38)
        minimized = true
    end
end)

maximizeButton.MouseButton1Click:Connect(function()
    if maximized then
        main.Size = originalSize
        main.Position = UDim2.new(0.5, -originalSize.X.Offset / 2, 0.5, -originalSize.Y.Offset / 2)
        maximized = false
        maximizeButton.Text = "□"
    else
        if not minimized then
            originalSize = main.Size
        else
            scroll.Visible = true
            minimized = false
        end
        updateResponsiveSize()
        maximized = true
        maximizeButton.Text = "❐"
    end
end)

closeButton.MouseButton1Click:Connect(function()
    recording = false
    playing = false
    screenGui:Destroy()
end)

UserInputService.JumpRequest:Connect(function()
    if infinityJump then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local root = getRoot()
    local humanoid = getHumanoid()

    if recording and root and humanoid then
        records[#records + 1] = {
            t = tick() - playbackStart,
            cf = root.CFrame,
            velocity = root.AssemblyLinearVelocity,
            state = humanoid:GetState().Value,
            walkSpeed = humanoid.WalkSpeed
        }
    end

    if playing and root and humanoid and #records > 1 then
        local elapsed = (tick() - playbackStart) * speedMultiplier
        while playbackIndex < #records and records[playbackIndex + 1].t <= elapsed do
            playbackIndex = playbackIndex + 1
        end

        if playbackIndex >= #records then
            if autoLoop then
                playbackIndex = 1
                playbackStart = tick()
            else
                stopPlayback()
            end
        else
            local current = records[playbackIndex]
            local nextRecord = records[playbackIndex + 1]
            local duration = math.max(nextRecord.t - current.t, 0.001)
            local alpha = math.clamp((elapsed - current.t) / duration, 0, 1)
            root.CFrame = current.cf:Lerp(nextRecord.cf, alpha)
            root.AssemblyLinearVelocity = current.velocity:Lerp(nextRecord.velocity, alpha)
            humanoid.WalkSpeed = current.walkSpeed
        end
    end
end)

player.CharacterAdded:Connect(function()
    playing = false
    recording = false
    setStatus("Karakter respawn - replay dihentikan")
end)

refreshConfigList()
setStatus(hasFileApi() and "Siap" or "Siap (penyimpanan config perlu API executor)")
