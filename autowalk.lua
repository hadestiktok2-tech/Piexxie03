--[[
    Piexxie03Hub  | Telegram @piexxie03
    Made with Wyvern Studio
    Functions: 9  |  Tabs: 4
    Open / close: RightShift

    Roblox Studio: put this in a LocalScript inside
    StarterPlayer > StarterPlayerScripts and press Play.
]]

local Library = (function()
-- WYVERN HUB LIBRARY v1
local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local LP = Players.LocalPlayer
-- the Wyvern Studio simulator provides its own typeof; in Roblox this is the normal one
local typeof = typeof
pcall(function() local env = getfenv and getfenv(1); if env and type(rawget(env, "__typeof")) == "function" then typeof = rawget(env, "__typeof") end end)
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

local LANG = {
	en = { MenuSize = "Menu size", Search = "Search...", Settings = "Settings", ToggleKey = "Toggle key", Destroy = "Destroy hub", DestroyDesc = "Closes the hub and turns off every function", Loaded = "Loaded! Toggle key: ", Error = "Error: ", LoopError = "Loop error: ", Select = "Select...", Type = "Type...", Reset = "Reset saved settings", ResetDesc = "Next start uses the default values again", ResetDone = "Saved settings cleared", Update = "A new version is out – run the script again to get it." },
	bs = { MenuSize = "Veličina menija", Search = "Pretraga...", Settings = "Postavke", ToggleKey = "Taster za otvaranje", Destroy = "Ugasi hub", DestroyDesc = "Zatvara hub i gasi sve funkcije", Loaded = "Učitano! Taster: ", Error = "Greška: ", LoopError = "Greška u petlji: ", Select = "Izaberi...", Type = "Upiši...", Reset = "Obriši spremljene postavke", ResetDesc = "Sljedeće pokretanje koristi početne vrijednosti", ResetDone = "Spremljene postavke obrisane", Update = "Izašla je nova verzija – pokreni skriptu ponovo da je dobiješ." },
	tl = { MenuSize = "Laki ng menu", Search = "Maghanap...", Settings = "Mga Setting", ToggleKey = "Key para buksan", Destroy = "Isara ang hub", DestroyDesc = "Isinasara ang hub at pinapatay ang lahat ng function", Loaded = "Na-load na! Key: ", Error = "Error: ", LoopError = "Error sa loop: ", Select = "Pumili...", Type = "Mag-type..." },
	fi = { MenuSize = "Valikon koko", Search = "Haku...", Settings = "Asetukset", ToggleKey = "Avausnäppäin", Destroy = "Sulje hub", DestroyDesc = "Sulkee hubin ja sammuttaa kaikki toiminnot", Loaded = "Ladattu! Näppäin: ", Error = "Virhe: ", LoopError = "Silmukkavirhe: ", Select = "Valitse...", Type = "Kirjoita..." },
	es = { MenuSize = "Tamaño del menú", Search = "Buscar...", Settings = "Ajustes", ToggleKey = "Tecla para abrir", Destroy = "Cerrar hub", DestroyDesc = "Cierra el hub y apaga todas las funciones", Loaded = "¡Cargado! Tecla: ", Error = "Error: ", LoopError = "Error en bucle: ", Select = "Elegir...", Type = "Escribe..." },
	pt = { MenuSize = "Tamanho do menu", Search = "Pesquisar...", Settings = "Configurações", ToggleKey = "Tecla para abrir", Destroy = "Fechar hub", DestroyDesc = "Fecha o hub e desliga todas as funções", Loaded = "Carregado! Tecla: ", Error = "Erro: ", LoopError = "Erro no loop: ", Select = "Escolher...", Type = "Digite..." },
}

local function imageUrl(id)
	id = tostring(id or "")
	if tonumber(id) then return "rbxassetid://" .. id end
	return id
end
local function setImage(label, id)
	label.Image = imageUrl(id)
	if tonumber(id) then
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync({ label }, function(_, status)
					if status ~= Enum.AssetFetchStatus.Success then
						label.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
					end
				end)
			end)
		end)
	end
end
Library.setImage = setImage

local function hex(h, fallback)
	if typeof(h) == "Color3" then return h end
	local ok, c = pcall(function() return Color3.fromHex(h) end)
	if ok and c then return c end
	return fallback or Color3.new(1, 1, 1)
end

local BOLD = { Gotham = "GothamBold", SourceSans = "SourceSansBold", Roboto = "RobotoCondensed", Nunito = "Nunito", Ubuntu = "Ubuntu" }
local function font(name, bold)
	local n = name or "Gotham"
	if bold and BOLD[n] then n = BOLD[n] end
	local ok, f = pcall(function() return Enum.Font[n] end)
	if ok and f then return f end
	return bold and Enum.Font.GothamBold or Enum.Font.Gotham
end

local function tween(o, t, props, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function make(class, props, children)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then o[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = o end
	if props and props.Parent then o.Parent = props.Parent end
	return o
end

local function corner(r) return make("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function pad(l, r, t, b)
	return make("UIPadding", { PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r or l), PaddingTop = UDim.new(0, t or l), PaddingBottom = UDim.new(0, b or t or l) })
end

local function guiParent()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and cg then
		local test = pcall(function() local f = Instance.new("Folder"); f.Parent = cg; f:Destroy() end)
		if test then return cg end
	end
	return LP:WaitForChild("PlayerGui")
end

local STYLES = nil -- @@STYLES@@

function Library.new(cfg)
	local self = setmetatable({}, Library)
	cfg = cfg or {}
	self.Config = cfg
	self.Flags = {}
	self.Alive = true
	self.Visible = true
	self.Conns = {}
	self.Pages = {}
	self.TabButtons = {}
	self.Elements = {}
	self.AccentObjs = {}
	self.Setters = {}
	self.UserConns = {}
	self.RenderBinds = {}
	self.Restores = {}
	self.Cards = {}
	-- running this script again closes the previous hub first, so nothing is left running twice
	local G = _G
	pcall(function() if getgenv then G = getgenv() end end)
	self.G = G
	pcall(function()
		local old = rawget(G, "__WyvernHub")
		if old and old ~= self and old.Destroy then old:Destroy(true) end
	end)
	pcall(function() rawset(G, "__WyvernHub", self) end)
	-- hosted on wyvernstudio.app: remember id and version to tell players about updates
	pcall(function()
		local hs = rawget(G, "__WyvernScript")
		if type(hs) == "table" then self.Hosted = hs; rawset(G, "__WyvernScript", nil) end
	end)
	-- menu size the player chose in the game (remembered between runs when the executor allows files)
	local u = tonumber(rawget(G, "__WyvernMenuSize"))
	if not u then pcall(function() if isfile and readfile and isfile("WyvernHub_size.txt") then u = tonumber(readfile("WyvernHub_size.txt")) end end) end
	self.UserScale = math.clamp(u or 1, 0.5, 1.6)
	self.S = setmetatable(LANG[cfg.Language or "en"] or {}, { __index = LANG.en })

	local th = cfg.Theme or {}
	self.T = {
		Accent = hex(th.Accent, Color3.fromRGB(230, 30, 50)),
		Accent2 = hex(th.Accent2, Color3.fromRGB(140, 0, 20)),
		Background = hex(th.Background, Color3.fromRGB(12, 12, 14)),
		Surface = hex(th.Surface, Color3.fromRGB(22, 22, 26)),
		Surface2 = hex(th.Surface2, Color3.fromRGB(32, 32, 38)),
		Text = hex(th.Text, Color3.fromRGB(245, 245, 245)),
		SubText = hex(th.SubText, Color3.fromRGB(150, 150, 160)),
		Stroke = hex(th.Stroke, Color3.fromRGB(50, 50, 58)),
	}
	self.R = tonumber(cfg.Corner) or 10
	self.F = font(cfg.Font, false)
	self.FB = font(cfg.Font, true)
	self.TF = self.FB
	-- Premium design (only in Premium scripts)
	if STYLES and type(cfg.LayoutSpec) == "table" then
		local ok, h = pcall(STYLES.make, self, cfg.LayoutSpec)
		if ok then self.Sty = h else warn("[WyvernHub] design: " .. tostring(h)) end
	end
	self:_build()
	return self
end

function Library:_conn(sig, fn)
	local c = sig:Connect(fn)
	table.insert(self.Conns, c)
	return c
end

function Library:_icon(parent, name, size, col, props)
	local d = self.Config.IconData and self.Config.IconData[name]
	if not d then return nil end
	local im = make("ImageLabel", { Parent = parent, BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Image = "rbxassetid://" .. tostring(d[1]), ImageRectSize = Vector2.new(48, 48), ImageRectOffset = Vector2.new(d[2], d[3]), ImageColor3 = col or self.T.Text, ScaleType = Enum.ScaleType.Fit })
	for k, v in pairs(props or {}) do im[k] = v end
	return im
end

function Library:_glow(parent, radius)
	-- soft glow that follows the exact shape of its parent (same size, same corner)
	if self.Config.IconGlow == false then return end
	for i, t in ipairs({ 0.45, 0.7, 0.86 }) do
		local g = make("Frame", { Name = "IconGlow", Parent = parent, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = radius }) })
		self:_accent(make("UIStroke", { Parent = g, Thickness = i * 2, Transparency = t, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }), "Color")
	end
end

function Library:_letter(n)
	local cfg = self.Config
	local l = tostring(cfg.IconLetter or "")
	if l == "" then l = "W" end
	return string.upper(string.sub(l, 1, n or 2))
end

function Library:_brand(parent, size, textSize)
	local cfg = self.Config
	local mode = cfg.IconMode or "Letter"
	if mode == "None" then return nil end
	local radius = UDim.new(0, math.min(self.R, math.floor(size * 0.28)))
	-- Wordmark replaces the single-letter badge with a compact text logo.
	local wordmark = mode == "Wordmark"
	local holder = make("Frame", { Name = "Brand", Parent = parent, Size = UDim2.fromOffset(wordmark and 98 or size, size), BackgroundTransparency = 1, BorderSizePixel = 0 })
	if wordmark then
		local label = make("TextLabel", { Name = "Wordmark", Parent = holder, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBlack, Text = "piexxieHUB", TextSize = size >= 60 and 22 or 15, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextStrokeTransparency = 0.8 })
		make("UIGradient", { Parent = label, Rotation = 0, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, self.T.Text), ColorSequenceKeypoint.new(0.55, self.T.Accent), ColorSequenceKeypoint.new(1, self.T.Accent2) }) })
		return holder
	end
	-- holder keeps the glow outside the clipped icon box, so nothing is cut off
	self:_glow(holder, radius)
	local box = make("Frame", { Name = "Box", Parent = holder, Size = UDim2.fromScale(1, 1), BackgroundColor3 = self.T.Surface2, BorderSizePixel = 0, ClipsDescendants = true }, { make("UICorner", { CornerRadius = radius }) })
	self:_accent(make("UIStroke", { Parent = box, Thickness = 1.5, Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }), "Color")
	if mode == "Icon" and self:_symbol(box, math.floor(size * 0.62)) then
		-- a ready-made icon
	elseif mode == "Image" and cfg.Icon and tostring(cfg.Icon) ~= "" then
		local im = make("ImageLabel", { Parent = box, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop }, { make("UICorner", { CornerRadius = radius }) })
		setImage(im, cfg.Icon)
	else
		local l = make("TextLabel", { Parent = box, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBlack, Text = self:_letter(2), TextSize = textSize or 18, TextColor3 = Color3.new(1, 1, 1) })
		make("UIGradient", { Parent = l, Rotation = 90, Color = ColorSequence.new(self.T.Text, self.T.Accent) })
	end
	return holder
end

-- the ready-made icon chosen for the hub (IconMode "Icon"), centered in its parent
function Library:_symbol(parent, size)
	local im = self:_icon(parent, tostring(self.Config.IconName or ""), size, Color3.new(1, 1, 1), { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	if not im then return nil end
	make("UIGradient", { Parent = im, Rotation = 90, Color = ColorSequence.new(self.T.Text, self.T.Accent) })
	return im
end

-- remembered values of toggles, sliders, dropdowns ... (when the executor can write files)
function Library:_loadSaved()
	self.Saved = {}
	if self.Config.SaveSettings == false then return end
	local name = string.gsub(tostring(self.Config.Title or "Hub"), "[^%w%-_ ]", "")
	if name == "" then name = "Hub" end
	self.SaveFile = "WyvernHub/" .. name .. ".json"
	pcall(function()
		if isfile and readfile and isfile(self.SaveFile) then
			local d = HttpService:JSONDecode(readfile(self.SaveFile))
			if type(d) == "table" then self.Saved = d end
		end
	end)
end

function Library:_save()
	if not self.Alive or self.Config.SaveSettings == false or not self.SaveFile or self.SavePending then return end
	self.SavePending = true
	task.delay(1, function()
		self.SavePending = false
		if not self.Alive then return end
		pcall(function()
			if not writefile then return end
			if makefolder and isfolder and not isfolder("WyvernHub") then makefolder("WyvernHub") end
			local out = {}
			for k, v in pairs(self.Flags) do local ty = type(v); if ty == "boolean" or ty == "number" or ty == "string" then out[k] = v end end
			writefile(self.SaveFile, HttpService:JSONEncode(out))
		end)
	end)
end

function Library:_click()
	if self.ClickSnd then pcall(function() self.ClickSnd:Play() end) end
end

function Library:_accent(obj, prop)
	table.insert(self.AccentObjs, { obj, prop })
	obj[prop] = self.T.Accent
	return obj
end

function Library:_safe(name, fn, ...)
	if type(fn) ~= "function" then return end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(fn, table.unpack(args, 1, args.n))
		if not ok then
			warn("[" .. tostring(self.Config.Title) .. "] " .. name .. ": " .. tostring(err))
			if self.Alive then self:Notify(self.S.Error .. name, tostring(err), 5) end
		end
	end)
end

-- special designs: animated background, particles and decorations
local FX = {
	Water = { p = "ring", move = "up", size = { 4, 11 }, speed = { 16, 38 }, sway = 6, anim = "wave" },
	Lava = { p = "blob", move = "up", size = { 6, 16 }, speed = { 6, 14 }, sway = 3, anim = "pulse", bottom = true },
	Fire = { p = "square", move = "up", size = { 2, 5 }, speed = { 40, 85 }, sway = 10, anim = "flicker", bottom = true, fade = true },
	Winter = { p = "text", chars = { "❄", "❅", "❆", "•" }, move = "down", size = { 8, 16 }, speed = { 14, 34 }, sway = 12, anim = "none", snow = true, over = true },
	Galaxy = { p = "dot", move = "twinkle", size = { 1, 3 }, anim = "spin" },
	Neon = { p = "dot", move = "up", size = { 1, 2 }, speed = { 8, 18 }, sway = 2, anim = "pulse", scan = true },
	Matrix = { p = "text", chars = { "0", "1", "Z", "7", "X", "$", "#", "%" }, move = "down", size = { 10, 14 }, speed = { 50, 110 }, sway = 0, anim = "none", mono = true },
	Sakura = { p = "petal", move = "diag", size = { 5, 9 }, speed = { 14, 28 }, sway = 18, anim = "wave", over = true },
	Storm = { p = "rain", move = "rain", size = { 1, 1 }, speed = { 160, 240 }, sway = 0, anim = "none", flash = true },
	Gold = { p = "text", chars = { "✦", "✧", "·" }, move = "twinkle", size = { 8, 14 }, anim = "sweep" },
	Halloween = { p = "text", chars = { "🦇" }, move = "float", size = { 14, 20 }, speed = { 10, 22 }, sway = 14, anim = "pulse", over = true },
}

function Library:_special(main)
	local cfg = self.Config
	local st = FX[tostring(cfg.Special or "")]
	if not st then return end
	local fx = type(cfg.Fx) == "table" and cfg.Fx or {}
	local T, R = self.T, self.R
	local c1 = hex(fx.Color1, T.Accent)
	local c2 = hex(fx.Color2, T.Accent2)
	local amount = math.clamp(tonumber(fx.Amount) or 50, 0, 100)
	local speed = math.clamp(tonumber(fx.Speed) or 100, 10, 300) / 100
	self.FxOn = true
	local layer = make("Frame", { Name = "Special", Parent = main, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true }, { corner(R) })
	local bg = make("Frame", { Parent = layer, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, BorderSizePixel = 0 }, { corner(R) })
	local grad = make("UIGradient", { Parent = bg, Rotation = 90,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(0.5, T.Background), ColorSequenceKeypoint.new(1, c2) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(0.5, 0.88), NumberSequenceKeypoint.new(1, 0.6) }) })
	local fxo = { layer = layer, bg = bg, grad = grad, parts = {} }
	-- snow, petals and bats drift over the whole menu (they never block clicks)
	local host = layer
	if st.over then
		host = make("Frame", { Name = "SpecialOver", Parent = main, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, Active = false, ZIndex = 40 }, { corner(R) })
		fxo.over = host
	end
	self.Fx = fxo
	if st.bottom then
		fxo.bottom = make("Frame", { Parent = layer, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 0.45), BackgroundColor3 = c1, BorderSizePixel = 0 })
		make("UIGradient", { Parent = fxo.bottom, Rotation = -90, Color = ColorSequence.new(c1, c2), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) }) })
	end
	if st.anim == "sweep" then
		fxo.shine = make("Frame", { Parent = layer, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 })
		fxo.shineG = make("UIGradient", { Parent = fxo.shine, Rotation = 25, Color = ColorSequence.new(c1, c2),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.45, 1), NumberSequenceKeypoint.new(0.5, 0.6), NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 1) }) })
	end
	if st.scan then fxo.scan = make("Frame", { Parent = layer, Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = c1, BackgroundTransparency = 0.4, BorderSizePixel = 0 }) end
	if st.flash then fxo.flash = make("Frame", { Parent = layer, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(220, 230, 255), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }) end
	-- animated border in the design's colors
	if fx.Animated ~= false and self.MainStroke then
		self.MainStroke.Color = Color3.new(1, 1, 1)
		for i, a in ipairs(self.AccentObjs) do if a[1] == self.MainStroke then table.remove(self.AccentObjs, i) break end end
		fxo.border = make("UIGradient", { Parent = self.MainStroke, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(0.5, c2), ColorSequenceKeypoint.new(1, c1) }) })
	end
	-- particles
	local n = (fx.Particles ~= false) and math.floor(4 + amount * 0.3) or 0
	if st.move == "twinkle" then n = math.floor(n * 1.4) end
	local function place(p, initial)
		p.x = math.random()
		if st.move == "up" then p.y = initial and math.random() or 1.05
		elseif st.move == "down" or st.move == "diag" or st.move == "rain" then p.y = initial and math.random() or -0.05
		else p.y = math.random() end
		local sp = st.speed or { 0, 0 }
		p.v = sp[1] + math.random() * (sp[2] - sp[1])
		p.ph = math.random() * 6.28
		p.dir = math.random() < 0.5 and -1 or 1
	end
	for i = 1, n do
		local s = st.size[1] + math.random() * (st.size[2] - st.size[1])
		local col = (i % 2 == 0) and c2 or c1
		local o
		if st.p == "text" then
			o = make("TextLabel", { Parent = host, BackgroundTransparency = 1, Size = UDim2.fromOffset(s + 4, s + 4), Text = st.chars[(i % #st.chars) + 1], Font = st.mono and Enum.Font.Code or Enum.Font.GothamBold, TextSize = s, TextColor3 = st.snow and Color3.new(1, 1, 1) or col, TextTransparency = 0.15 })
		elseif st.p == "ring" then
			o = make("Frame", { Parent = host, BackgroundTransparency = 1, Size = UDim2.fromOffset(s, s), BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }), make("UIStroke", { Color = col, Thickness = 1.2, Transparency = 0.25 }) })
		elseif st.p == "rain" then
			o = make("Frame", { Parent = host, BackgroundColor3 = c1, BackgroundTransparency = 0.45, Size = UDim2.fromOffset(1, 8 + math.random() * 8), Rotation = 12, BorderSizePixel = 0 })
		elseif st.p == "petal" then
			o = make("Frame", { Parent = host, BackgroundColor3 = col, BackgroundTransparency = 0.15, Size = UDim2.fromOffset(s, s * 0.6), Rotation = math.random(0, 360), BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(0.5, 0) }) })
		else
			o = make("Frame", { Parent = host, BackgroundColor3 = st.p == "dot" and Color3.new(1, 1, 1) or col, BackgroundTransparency = st.p == "blob" and 0.35 or 0.1, Size = UDim2.fromOffset(s, s), BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(st.p == "square" and 0 or 1, 0) }) })
		end
		o.AnchorPoint = Vector2.new(0.5, 0.5)
		o.ZIndex = st.over and 40 or 1
		if st.over and o:IsA("GuiObject") then o.Active = false end
		local p = { o = o, s = s }
		place(p, true)
		table.insert(fxo.parts, p)
	end
	local tt = 0
	self:_conn(RunService.Heartbeat, function(dt)
		if not self.Alive or not self.Visible then return end
		dt = math.min(tonumber(dt) or 0.016, 0.1) * speed
		tt += dt
		local w, h = math.max(layer.AbsoluteSize.X, 1), math.max(layer.AbsoluteSize.Y, 1)
		for _, p in ipairs(fxo.parts) do
			local sx = 0
			if st.move == "up" then
				p.y -= p.v * dt / h
				if p.y < -0.05 then place(p) end
				sx = math.sin(tt * 1.6 + p.ph) * (st.sway or 0)
				if st.fade then p.o.BackgroundTransparency = 0.1 + 0.9 * math.clamp(1 - p.y, 0, 1) end
			elseif st.move == "down" or st.move == "diag" or st.move == "rain" then
				p.y += p.v * dt / h
				if st.move == "diag" then p.x += p.v * 0.35 * dt / w; p.o.Rotation += 40 * dt * p.dir end
				if st.move == "rain" then p.x += p.v * 0.2 * dt / w end
				if p.x > 1.05 then p.x -= 1.1 end
				if p.y > 1.05 then place(p) end
				sx = math.sin(tt * 1.2 + p.ph) * (st.sway or 0)
			elseif st.move == "twinkle" then
				local a = 0.15 + 0.8 * (0.5 + 0.5 * math.sin(tt * 2.2 + p.ph))
				if p.o:IsA("TextLabel") then p.o.TextTransparency = a else p.o.BackgroundTransparency = a end
			elseif st.move == "float" then
				p.x += p.v * p.dir * dt / w
				if p.x > 1.08 then p.x = -0.06 elseif p.x < -0.08 then p.x = 1.06 end
				sx = 0
				p.o.Position = UDim2.new(p.x, 0, p.y + math.sin(tt * 1.4 + p.ph) * 0.03, 0)
			end
			if st.move ~= "float" then p.o.Position = UDim2.new(p.x, sx, p.y, 0) end
		end
		if st.anim == "wave" then grad.Offset = Vector2.new(0, math.sin(tt * 0.8) * 0.15)
		elseif st.anim == "spin" then grad.Rotation = (tt * 10) % 360
		elseif st.anim == "pulse" then bg.BackgroundTransparency = 0.15 + 0.15 * math.sin(tt * 1.5)
		elseif st.anim == "flicker" and fxo.bottom then fxo.bottom.BackgroundTransparency = 0.05 + 0.25 * math.abs(math.sin(tt * 7) * math.sin(tt * 3.1)) end
		if st.bottom and st.anim ~= "flicker" then fxo.bottom.BackgroundTransparency = 0.1 + 0.2 * math.sin(tt * 1.1) end
		if fxo.shineG then fxo.shineG.Offset = Vector2.new((tt * 0.35) % 2 - 1, 0) end
		if fxo.scan then fxo.scan.Position = UDim2.new(0, 0, (tt * 0.22) % 1, 0) end
		if fxo.flash and math.random() < dt * 0.25 then
			fxo.flash.BackgroundTransparency = 0.55
			tween(fxo.flash, 0.35, { BackgroundTransparency = 1 })
		end
		if fxo.border then fxo.border.Rotation = (tt * 60) % 360 end
	end)
end

function Library:_build()
	local cfg, T, R = self.Config, self.T, self.R
	local gui = make("ScreenGui", { Name = "WyvernHub_" .. tostring(math.random(1000, 9999)), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 999 })
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	gui.Parent = guiParent()
	self.Gui = gui

	-- keep the hub below Roblox's own top bar (menu / chat buttons)
	local inset = 0
	pcall(function() inset = tonumber(game:GetService("GuiService"):GetGuiInset().Y) or 0 end)
	if type(inset) ~= "number" then inset = 0 end
	self.Inset = inset
	local sx = (cfg.Size and tonumber(cfg.Size.X)) or 580
	local sy = (cfg.Size and tonumber(cfg.Size.Y)) or 400
	local main = make("Frame", {
		Name = "Main", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, math.floor(inset / 2)),
		Size = UDim2.fromOffset(sx, sy), BackgroundColor3 = T.Background, BackgroundTransparency = tonumber(cfg.Transparency) or 0,
		BorderSizePixel = 0, ClipsDescendants = false,
	}, { corner(R) })
	self.Main = main
	local scale = make("UIScale", { Parent = main })
	self.Scale = scale
	self.DesignW, self.DesignH = sx, sy
	self.BaseScale = 1
	if workspace.CurrentCamera then self:_conn(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() self:_layout() end) end

	local stroke = make("UIStroke", { Parent = main, Thickness = 1.5, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	self:_accent(stroke, "Color")
	self.MainStroke = stroke
	if cfg.Glow ~= false then
		for i = 1, 3 do
			local g = make("Frame", { Parent = main, Size = UDim2.new(1, i * 6, 1, i * 6), Position = UDim2.fromOffset(-i * 3, -i * 3), BackgroundTransparency = 1, ZIndex = 0 }, { corner(R + i * 3) })
			local gs = make("UIStroke", { Parent = g, Thickness = 3, Transparency = 0.55 + i * 0.13 })
			self:_accent(gs, "Color")
		end
	end

	local Sty = self.Sty
	if Sty then Sty.main(self, main) else self:_special(main) end
	local panelT = self.FxOn and math.max(tonumber(cfg.Transparency) or 0, 0.18) or (tonumber(cfg.Transparency) or 0)
	self.CardT = self.FxOn and 0.22 or 0
	if Sty then panelT = Sty.panelT; self.CardT = Sty.cardT end

	-- header
	local header = make("Frame", { Parent = main, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = T.Surface, BackgroundTransparency = panelT, BorderSizePixel = 0, ZIndex = 2 }, { corner(R) })
	make("Frame", { Parent = header, Size = UDim2.new(1, 0, 0, R), Position = UDim2.new(0, 0, 1, -R), BackgroundColor3 = T.Surface, BackgroundTransparency = panelT, BorderSizePixel = 0, ZIndex = 2 })
	local line = make("Frame", { Parent = header, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, ZIndex = 3, BackgroundColor3 = Color3.new(1, 1, 1) })
	local lineGrad = make("UIGradient", { Parent = line })
	self.LineGrad = lineGrad
	local brand = self:_brand(header, 34, 17)
	local tx = 16
	if brand then brand.Position = UDim2.fromOffset(10, 8); brand.ZIndex = 3; for _, d in ipairs(brand:GetDescendants()) do if d:IsA("GuiObject") then d.ZIndex = 3 end end; tx = (cfg.IconMode == "Wordmark") and 118 or 56 end
	local title = make("TextLabel", { Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(tx, 7), Size = UDim2.new(1, -120 - tx, 0, 22), Font = self.TF, Text = cfg.Title or "Wyvern Hub", TextSize = 19, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 })
	local titleGrad = make("UIGradient", { Parent = title })
	self.TitleGrad = titleGrad
	local subL = make("TextLabel", { Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(tx, 28), Size = UDim2.new(1, -120 - tx, 0, 16), Font = self.F, Text = cfg.Subtitle or "", TextSize = 12, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 })
	self:_paintGradients()
	if Sty then Sty.header(self, header, title, subL, brand) end

	local function hbtn(txt, x, icon)
		if Sty then
			local sb = Sty.hbtn(self, header, x, icon)
			if sb then return sb end
		end
		local b = make("TextButton", { Parent = header, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = T.Surface2, Text = txt, Font = self.FB, TextSize = 16, TextColor3 = T.Text, AutoButtonColor = false, ZIndex = 4 }, { corner(math.min(R, 8)) })
		if self:_icon(b, icon, 16, T.Text, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 5 }) then b.Text = "" end
		b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = T.Accent }) end)
		b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = T.Surface2 }) end)
		return b
	end
	local closeB = hbtn("×", -10, "x")
	local minB = hbtn("–", -46, "minus")
	closeB.MouseButton1Click:Connect(function() self:Destroy() end)
	minB.MouseButton1Click:Connect(function() self:SetVisible(false) end)

	-- drag
	do
		local dragging, start, startPos
		self:_conn(header.InputBegan, function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, start, startPos = true, i.Position, main.Position
				i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		self:_conn(UIS.InputChanged, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = (i.Position - start) / math.max(scale.Scale, 0.01)
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X * scale.Scale, startPos.Y.Scale, startPos.Y.Offset + d.Y * scale.Scale)
			end
		end)
	end

	-- body ("Made with Wyvern Studio" takes a thin line at the bottom)
	local brandH = true and 16 or 0
	local top = cfg.TabStyle == "Top"
	local tabBar, content
	if top then
		tabBar = make("ScrollingFrame", { Parent = main, Position = UDim2.fromOffset(10, 58), Size = UDim2.new(1, -20, 0, 34), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, BorderSizePixel = 0 }, {
			make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		content = make("Frame", { Parent = main, Position = UDim2.fromOffset(10, cfg.SearchBar ~= false and 136 or 100), Size = UDim2.new(1, -20, 1, (cfg.SearchBar ~= false and -146 or -110) - brandH), BackgroundTransparency = 1 })
	else
		local side = make("Frame", { Parent = main, Position = UDim2.fromOffset(10, 60), Size = UDim2.new(0, 150, 1, -70 - brandH), BackgroundColor3 = T.Surface, BackgroundTransparency = math.min(1, panelT + 0.2), BorderSizePixel = 0 }, { corner(R) })
		tabBar = make("ScrollingFrame", { Parent = side, Position = UDim2.fromOffset(0, cfg.SearchBar ~= false and 44 or 6), Size = UDim2.new(1, 0, 1, cfg.SearchBar ~= false and -50 or -12), BackgroundTransparency = 1, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel = 0 }, {
			make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }),
			pad(6, 6, 2, 2),
		})
		self.Side = side
		if Sty then Sty.side(self, side) end
		content = make("Frame", { Parent = main, Position = UDim2.fromOffset(170, 60), Size = UDim2.new(1, -180, 1, -70 - brandH), BackgroundTransparency = 1 })
		self.SideW = 150
	end
	self.TabBar, self.Content, self.TopTabs = tabBar, content, top
	if true then
		make("TextLabel", { Parent = main, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 1, -24), Size = UDim2.new(1, -20, 0, 16), Font = self.F, Text = "Made with Wyvern Studio", TextSize = 11, TextColor3 = T.SubText, TextTransparency = 0.2, ZIndex = 3 })
	end

	if cfg.SearchBar ~= false then
		local holder = top and make("Frame", { Parent = main, Position = UDim2.fromOffset(10, 98), Size = UDim2.new(1, -20, 0, 30), BackgroundColor3 = T.Surface2, BorderSizePixel = 0 }, { corner(math.min(R, 8)) })
			or make("Frame", { Parent = self.Side, Position = UDim2.fromOffset(6, 8), Size = UDim2.new(1, -12, 0, 30), BackgroundColor3 = T.Surface2, BorderSizePixel = 0 }, { corner(math.min(R, 8)) })
		if not self:_icon(holder, "search", 14, T.SubText, { Position = UDim2.fromOffset(8, 8) }) then
			make("TextLabel", { Parent = holder, BackgroundTransparency = 1, Size = UDim2.fromOffset(26, 30), Text = "⌕", Font = self.FB, TextSize = 16, TextColor3 = T.SubText })
		end
		local sb = make("TextBox", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -32, 1, 0), Font = self.F, Text = "", PlaceholderText = self.S.Search, PlaceholderColor3 = T.SubText, TextColor3 = T.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false })
		self.SearchBox = sb
		sb:GetPropertyChangedSignal("Text"):Connect(function() self:_filter() end)
	end

	-- resize grip (bottom right): drag to make the whole menu bigger or smaller
	do
		local grip = make("TextButton", { Name = "Resize", Parent = main, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -3, 1, -3), Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 20 })
		local gi = self:_icon(grip, "move-diagonal-2", 14, T.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ImageTransparency = 0.35, ZIndex = 21 })
		if not gi then grip.Text = "◢"; grip.TextColor3 = T.SubText; grip.TextTransparency = 0.4; grip.TextSize = 14; grip.Font = Enum.Font.GothamBold end
		self.Grip = grip
		local dragging, start, startU, startPhys
		self:_conn(grip.InputBegan, function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging, start, startU = true, i.Position, self.UserScale
				startPhys = (main.Size.X.Offset + main.Size.Y.Offset) / 2 * self.BaseScale
			end
		end)
		self:_conn(UIS.InputChanged, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - start
				local grow = (d.X + d.Y) -- the corner moves half of the size change (menu grows around its centre)
				self:SetMenuSize(startU * math.max(startPhys + grow, 40) / math.max(startPhys, 1), true)
			end
		end)
		self:_conn(UIS.InputEnded, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				self:SetMenuSize(self.UserScale)
			end
		end)
	end
	self:_layout()

	-- notifications
	local np = tostring(cfg.NotifyPosition or "BottomRight")
	local nTop, nx = string.find(np, "Top") ~= nil, (np == "BottomLeft" and 0) or (np == "TopCenter" and 0.5) or 1
	self.NotifFrom = (nx == 0 and -320) or (nx == 0.5 and 0) or 320
	self.NotifHolder = make("Frame", { Parent = gui, AnchorPoint = Vector2.new(nx, nTop and 0 or 1), Position = UDim2.new(nx, (nx == 1 and -16) or (nx == 0 and 16) or 0, nTop and 0 or 1, nTop and (inset + 12) or -16), Size = UDim2.fromOffset(290, 500), BackgroundTransparency = 1 }, {
		make("UIListLayout", { VerticalAlignment = nTop and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	-- click sound
	local snd = tostring(cfg.ClickSound or "None")
	local sid = (snd == "Click" and "rbxasset://sounds/clickfast.wav") or (snd == "Ping" and "rbxasset://sounds/electronicpingshort.wav") or (snd == "Custom" and imageUrl(cfg.SoundId)) or nil
	if sid and sid ~= "" then
		pcall(function()
			self.ClickSnd = make("Sound", { Name = "WyvernClick", SoundId = sid, Volume = math.clamp(tonumber(cfg.SoundVolume) or 50, 0, 100) / 100, Parent = game:GetService("SoundService") })
		end)
	end

	-- toggle key
	self.ToggleKey = cfg.ToggleKey or "RightShift"
	self:_conn(UIS.InputBegan, function(i, gp)
		if gp then return end
		if i.KeyCode.Name == self.ToggleKey then self:SetVisible(not self.Visible) end
	end)

	-- mobile button
	if cfg.MobileButton ~= false then
		local mr = cfg.ButtonShape == "Round" and UDim.new(1, 0) or UDim.new(0, 12)
		local mb = make("TextButton", { Name = "OpenButton", Parent = gui, Position = UDim2.new(0, 20, 0.35, 0), Size = UDim2.fromOffset(44, 44), BackgroundColor3 = T.Background, Text = "", AutoButtonColor = false, ClipsDescendants = false, ZIndex = 50 }, { make("UICorner", { CornerRadius = mr }) })
		self:_glow(mb, mr)
		self:_accent(make("UIStroke", { Parent = mb, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }), "Color")
		local skull = make("TextLabel", { Name = "SkullLogo", Parent = mb, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBlack, Text = "☠", TextSize = 29, TextColor3 = T.Text, ZIndex = 51 })
		make("UIGradient", { Parent = skull, Rotation = 90, Color = ColorSequence.new(T.Text, T.Accent) })
		for _, d in ipairs(mb:GetDescendants()) do if d:IsA("GuiObject") and d.Name == "IconGlow" then d.ZIndex = 49 end end
		self.OpenButton = mb
		local moved, st, sp = false, nil, nil
		mb.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then moved, st, sp = false, i.Position, mb.Position end
		end)
		mb.InputChanged:Connect(function(i)
			if st and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
				local d = i.Position - st
				if d.Magnitude > 6 then moved = true end
				if moved then mb.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y) end
			end
		end)
		mb.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
				if not moved and st then self:SetVisible(not self.Visible) end
				st = nil
			end
		end)
	end

	-- watermark
	if cfg.Watermark then
		local wm = make("TextLabel", { Parent = gui, Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(10, 28), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Background, BackgroundTransparency = 0.1, Font = self.FB, TextSize = 13, TextColor3 = T.Text, Text = "" }, { corner(6), pad(10, 10, 0, 0) })
		self:_accent(make("UIStroke", { Parent = wm, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }), "Color")
		local frames, last = 0, os.clock()
		self:_conn(RunService.RenderStepped, function()
			frames += 1
			local now = os.clock()
			if now - last >= 0.5 then
				wm.Text = (cfg.Title or "Hub") .. "  •  " .. math.floor(frames / (now - last)) .. " FPS  •  " .. os.date("%H:%M")
				frames, last = 0, now
			end
		end)
	end

	-- rainbow
	if cfg.Rainbow then
		self:_conn(RunService.Heartbeat, function()
			local c = Color3.fromHSV((os.clock() * 0.12) % 1, 0.85, 1)
			self.T.Accent = c
			self.T.Accent2 = Color3.fromHSV((os.clock() * 0.12 + 0.15) % 1, 0.9, 0.8)
			for _, a in ipairs(self.AccentObjs) do
				if a[1].Parent then a[1][a[2]] = c end
			end
			self:_paintGradients()
		end)
	end

	if cfg.Blur then
		self.BlurFx = make("BlurEffect", { Parent = Lighting, Size = 0 })
	end
end

function Library:_paintGradients()
	local seq = ColorSequence.new({ ColorSequenceKeypoint.new(0, self.T.Accent), ColorSequenceKeypoint.new(1, self.Config.Gradient == false and self.T.Accent or self.T.Accent2) })
	if self.LineGrad then self.LineGrad.Color = seq end
	if self.TitleGrad then
		self.TitleGrad.Color = self.Config.Gradient == false and ColorSequence.new(self.T.Text) or ColorSequence.new({ ColorSequenceKeypoint.new(0, self.T.Text), ColorSequenceKeypoint.new(1, self.T.Accent) })
	end
end

local MIN_SCALE = 0.62 -- below this the text is too small to read
local MIN_W, MIN_H = 360, 250 -- smallest menu (in design pixels)

function Library:_layout()
	if not self.Main then return end
	local vx, vy = 1280, 720
	pcall(function()
		local vp = workspace.CurrentCamera.ViewportSize
		if tonumber(vp.X) and tonumber(vp.Y) and vp.X > 0 then vx, vy = vp.X, vp.Y end
	end)
	local ax, ay = math.max(vx - 24, 200), math.max(vy - (self.Inset or 0) - 24, 150)
	local W, H = self.DesignW or 580, self.DesignH or 400
	local fit = math.min(ax / W, ay / H)
	local e = math.max((self.UserScale or 1) * math.min(fit, 1), MIN_SCALE)
	-- when the screen is too small for this size, the menu gets narrower / lower instead of unreadable
	local w, h = W, H
	if w * e > ax then w = math.max(MIN_W, ax / e) end
	if h * e > ay then h = math.max(MIN_H, ay / e) end
	e = math.min(e, ax / w, ay / h)
	w, h = math.floor(w), math.floor(h)
	self.Main.Size = UDim2.fromOffset(w, h)
	self.W, self.H = w, h
	if self.Side then
		local sw = w < 500 and 120 or 150
		self.SideW = sw
		self.Side.Size = UDim2.new(0, sw, 1, -70)
		self.Content.Position = UDim2.fromOffset(sw + 20, 60)
		self.Content.Size = UDim2.new(1, -(sw + 30), 1, -70)
	end
	self.BaseScale = e
	if self.Visible and self.Scale then self.Scale.Scale = e end
	for _, c in ipairs(self.Cards) do self:_fitCard(c) end
end

function Library:SetMenuSize(u, live)
	u = math.clamp(tonumber(u) or 1, 0.5, 1.6)
	self.UserScale = u
	self:_layout()
	local s = self.Setters and self.Setters[self.S.MenuSize]
	if s then s(math.floor(u * 100 + 0.5), false) end
	pcall(function() rawset(self.G, "__WyvernMenuSize", u) end)
	if not live then
		self._saveToken = (self._saveToken or 0) + 1
		local my = self._saveToken
		task.delay(0.6, function()
			if my ~= self._saveToken then return end
			pcall(function() if writefile then writefile("WyvernHub_size.txt", tostring(self.UserScale)) end end)
		end)
	end
end

function Library:SetVisible(v)
	if not self.Alive then return end
	self.Visible = v
	if self.OpenButton then self.OpenButton.Visible = not v end
	local main, anim = self.Main, self.Config.Animation or "Pop"
	if v then
		main.Visible = true
		if anim == "Slide" then
			local p = main.Position
			main.Position = p + UDim2.fromOffset(0, 40)
			self.Scale.Scale = self.BaseScale
			tween(main, 0.35, { Position = p }, Enum.EasingStyle.Back)
		elseif anim == "Fade" then
			self.Scale.Scale = self.BaseScale
			self:_cover(true)
		else
			self.Scale.Scale = self.BaseScale * 0.85
			tween(self.Scale, 0.35, { Scale = self.BaseScale }, Enum.EasingStyle.Back)
		end
		if self.BlurFx then tween(self.BlurFx, 0.3, { Size = 14 }) end
	else
		if self.BlurFx then tween(self.BlurFx, 0.3, { Size = 0 }) end
		local tw = tween(self.Scale, 0.2, { Scale = self.BaseScale * 0.85 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tw.Completed:Connect(function() if not self.Visible and self.Main then self.Main.Visible = false end end)
	end
end

function Library:_cover(fadeOut)
	local cv = make("Frame", { Parent = self.Main, Size = UDim2.fromScale(1, 1), BackgroundColor3 = self.T.Background, BackgroundTransparency = fadeOut and 0 or 1, ZIndex = 50, BorderSizePixel = 0 }, { corner(self.R) })
	local tw = tween(cv, 0.45, { BackgroundTransparency = fadeOut and 1 or 0 })
	tw.Completed:Connect(function() cv:Destroy() end)
end

function Library:Notify(title, text, dur)
	if not self.Alive then return end
	dur = dur or 3.5
	local T, R = self.T, math.min(self.R, 10)
	local card = make("Frame", { Parent = self.NotifHolder, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
	local from = self.NotifFrom or 320
	local inner = make("Frame", { Parent = card, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(from, from == 0 and -40 or 0), BackgroundColor3 = T.Surface, BorderSizePixel = 0 }, { corner(R), pad(14, 12, 10, 12) })
	self:_accent(make("UIStroke", { Parent = inner, Thickness = 1, Transparency = 0.3 }), "Color")
	if self.Sty then self.Sty.notify(self, inner) end
	local bar = make("Frame", { Parent = inner, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 10), BorderSizePixel = 0 })
	self:_accent(bar, "BackgroundColor3")
	make("UIListLayout", { Parent = inner, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder })
	local tl = make("TextLabel", { Parent = inner, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = self.FB, Text = tostring(title or ""), TextSize = 14, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left })
	local bi = self:_icon(tl, "bell", 14, T.Accent, { Position = UDim2.fromOffset(-20, 2) })
	if bi then pad(20, 0, 0, 0).Parent = tl; table.insert(self.AccentObjs, { bi, "ImageColor3" }) end
	make("TextLabel", { Parent = inner, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = self.F, Text = tostring(text or ""), TextSize = 13, TextWrapped = true, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left })
	bar.Parent = card
	bar.Position = UDim2.new(0, 0, 1, -2)
	tween(inner, 0.4, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
	tween(bar, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	task.delay(dur, function()
		if not card.Parent then return end
		local tw = tween(inner, 0.3, { Position = UDim2.fromOffset(from, from == 0 and -40 or 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tw.Completed:Connect(function() card:Destroy() end)
	end)
end

function Library:_tab(name)
	if self.Pages[name] then return self.Pages[name] end
	local T, R = self.T, self.R
	local order = 0
	for _ in pairs(self.Pages) do order += 1 end
	local page = make("ScrollingFrame", { Parent = self.Content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false }, {
		make("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }),
		pad(2, 8, 2, 8),
	})
	local btn, icon
	local iconName = self.Config.TabIcons and self.Config.TabIcons[name]
	if self.TopTabs then
		btn = make("TextButton", { Parent = self.TabBar, LayoutOrder = order, Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Surface, Text = name, Font = self.FB, TextSize = 13, TextColor3 = T.SubText, AutoButtonColor = false }, { corner(math.min(R, 8)) })
		icon = iconName and self:_icon(btn, iconName, 15, T.SubText, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -22, 0.5, 0) })
		pad(icon and 36 or 14, 14, 0, 0).Parent = btn
	else
		btn = make("TextButton", { Parent = self.TabBar, LayoutOrder = order, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = T.Surface2, BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, { corner(math.min(R, 8)) })
		icon = iconName and self:_icon(btn, iconName, 16, T.SubText, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0) })
		make("TextLabel", { Name = "L", Parent = btn, BackgroundTransparency = 1, Position = UDim2.fromOffset(icon and 38 or 16, 0), Size = UDim2.new(1, icon and -44 or -22, 1, 0), Text = name, Font = self.FB, TextSize = 13, TextScaled = true, TextWrapped = true, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left }, { make("UITextSizeConstraint", { MaxTextSize = 13, MinTextSize = 10 }) })
		local ind = make("Frame", { Name = "I", Parent = btn, Position = UDim2.new(0, 4, 0.5, -8), Size = UDim2.fromOffset(3, 16), BorderSizePixel = 0, BackgroundTransparency = 1 }, { corner(2) })
		self:_accent(ind, "BackgroundColor3")
	end
	local entry = { Page = page, Button = btn, Order = order, Icon = icon }
	self.Pages[name] = entry
	if self.Sty then self.Sty.tab(self, entry, name) end
	btn.MouseButton1Click:Connect(function() self:_click(); self:SelectTab(name) end)
	if not self.Current then self:SelectTab(name) end
	return entry
end

function Library:SelectTab(name)
	local T = self.T
	for n, e in pairs(self.Pages) do
		local on = n == name
		e.Page.Visible = on
		if self.Sty and self.Sty.select(self, e, on) then
			-- drawn by the design
		elseif self.TopTabs then
			tween(e.Button, 0.2, { BackgroundColor3 = on and T.Accent or T.Surface, TextColor3 = on and Color3.new(1, 1, 1) or T.SubText })
			if e.Icon then tween(e.Icon, 0.2, { ImageColor3 = on and Color3.new(1, 1, 1) or T.SubText }) end
		else
			local base = e.Icon and 38 or 14
			tween(e.Button, 0.2, { BackgroundTransparency = on and 0 or 1 })
			tween(e.Button.L, 0.2, { TextColor3 = on and T.Text or T.SubText, Position = UDim2.fromOffset(on and base + 4 or base, 0) })
			tween(e.Button.I, 0.2, { BackgroundTransparency = on and 0 or 1 })
			if e.Icon then tween(e.Icon, 0.2, { ImageColor3 = on and T.Accent or T.SubText, Position = UDim2.new(0, on and 16 or 14, 0.5, 0) }) end
		end
	end
	if self.Pages[name] then
		local p = self.Pages[name].Page
		p.Position = UDim2.fromOffset(0, 12)
		tween(p, 0.3, { Position = UDim2.fromOffset(0, 0) })
	end
	self.Current = name
	self:_filter()
end

function Library:_filter()
	local q = self.SearchBox and string.lower(self.SearchBox.Text) or ""
	for _, el in ipairs(self.Elements) do
		if el.Tab == self.Current then
			el.Frame.Visible = q == "" or string.find(string.lower(el.Name), q, 1, true) ~= nil
		end
	end
end

local function textHeight(text, size, fnt, width)
	local h
	pcall(function()
		local v = TextService:GetTextSize(text, size, fnt, Vector2.new(width, 10000))
		h = tonumber(v.Y)
	end)
	if not h or h <= 0 then
		-- fallback estimate (about 0.55 x font size per character)
		local per = math.max(1, math.floor(width / (size * 0.55)))
		h = math.ceil(math.max(#text, 1) / per) * math.ceil(size * 1.2)
	end
	return math.ceil(h)
end

-- Cards grow to fit their text: long names wrap to a new line instead of being cut off.
function Library:_card(page, name, desc, opts)
	opts = opts or {}
	local T, R = self.T, self.R
	local hasDesc = desc and desc ~= ""
	local f = make("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, hasDesc and 52 or 40), BackgroundColor3 = T.Surface, BackgroundTransparency = self.CardT or 0, BorderSizePixel = 0, ClipsDescendants = true }, { corner(math.min(R, 10)) })
	local st = make("UIStroke", { Parent = f, Color = T.Stroke, Thickness = 1, Transparency = 0.3 })
	if self.Sty then self.Sty.card(self, f, st) end
	local stC, stT = st.Color, st.Transparency
	f.MouseEnter:Connect(function() tween(st, 0.2, { Color = T.Accent, Transparency = 0.4 }) end)
	f.MouseLeave:Connect(function() tween(st, 0.2, { Color = stC, Transparency = stT }) end)
	local title = make("TextLabel", { Name = "Title", Parent = f, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 11), Size = UDim2.new(1, -(14 + (opts.reserve or 70)), 0, 18), Font = self.FB, Text = name, TextSize = 14, TextWrapped = true, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center })
	local d
	if hasDesc then
		d = make("TextLabel", { Name = "Desc", Parent = f, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -(14 + (opts.descReserve or opts.reserve or 70)), 0, 15), Font = self.F, Text = desc, TextSize = 12, TextWrapped = true, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })
	end
	local c = { Frame = f, Title = title, Desc = d, Name = name, DescText = desc, Reserve = opts.reserve or 70, DescReserve = opts.descReserve or opts.reserve or 70, Bottom = opts.bottom or 0, OnFit = opts.onFit,
		-- a wide control (text box, dropdown, key) moves under the text when the menu is narrow
		Stack = opts.stack, OnStack = opts.onStack }
	table.insert(self.Cards, c)
	self:_fitCard(c)
	return f, c
end

function Library:_fitCard(c)
	local cw
	if self.TopTabs then cw = (self.W or 580) - 20 else cw = (self.W or 580) - (self.SideW or 150) - 30 end
	cw = cw - 10 -- page padding
	-- narrow menu: put the control under the text instead of squeezing the text into a thin column
	local stacked = c.Stack ~= nil and (cw - 14 - c.Reserve) < 150
	local reserve = stacked and 14 or c.Reserve
	local descReserve = stacked and 14 or c.DescReserve
	local tw = math.max(cw - 14 - reserve, 60)
	-- very narrow: slightly smaller letters, so words stay whole
	local ts = tw < 110 and 13 or 14
	c.Title.TextSize = ts
	local th = textHeight(c.Name, ts, self.FB, tw)
	c.Title.Size = UDim2.new(1, -(14 + reserve), 0, th)
	local y = 11 + th
	if c.Desc then
		local dw = math.max(cw - 14 - descReserve, 60)
		local ds = dw < 110 and 11 or 12
		c.Desc.TextSize = ds
		local dh = textHeight(c.DescText, ds, self.F, dw)
		c.Desc.Position = UDim2.fromOffset(14, y + 3)
		c.Desc.Size = UDim2.new(1, -(14 + descReserve), 0, dh)
		y = y + 3 + dh
	end
	local sy
	if stacked then
		sy = y + 8
		y = sy + c.Stack
	end
	local h = math.max(y + 11 + c.Bottom, c.Desc and 52 or 40)
	if th <= 18 and not c.Desc and not stacked then
		-- single line, no description: keep the title centred like before
		c.Title.Position = UDim2.fromOffset(14, 0)
		c.Title.Size = UDim2.new(1, -(14 + reserve), 0, h - c.Bottom)
	else
		c.Title.Position = UDim2.fromOffset(14, 11)
	end
	c.Height = h
	c.Stacked, c.StackY = stacked, sy
	if c.OnStack then c.OnStack(stacked, sy) end
	if c.OnFit then c.OnFit(h, c) else c.Frame.Size = UDim2.new(1, 0, 0, h) end
end

function Library:_ripple(parent, x, y)
	local r = make("Frame", { Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x - parent.AbsolutePosition.X, y - parent.AbsolutePosition.Y), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = self.T.Accent, BackgroundTransparency = 0.6, ZIndex = parent.ZIndex + 1 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local s = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.2
	local tw = tween(r, 0.55, { Size = UDim2.fromOffset(s, s), BackgroundTransparency = 1 })
	tw.Completed:Connect(function() r:Destroy() end)
end

local function keyName(k)
	if typeof(k) == "EnumItem" then return k.Name end
	return tostring(k or "None")
end

function Library:_element(e)
	local T, R = self.T, self.R
	local tabName = e.Tab or "Main"
	local page = self:_tab(tabName).Page
	local name = e.Name or e.Type
	local f
	if e.Type == "Section" then
		f = make("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1 })
		local l = make("TextLabel", { Parent = f, BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 6), Size = UDim2.new(1, -8, 0, 18), Font = self.FB, Text = string.upper(name), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
		self:_accent(l, "TextColor3")
		if self.Sty then self.Sty.section(self, f, l, name) end
	elseif e.Type == "Label" then
		f = make("Frame", { Parent = page, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Surface, BackgroundTransparency = 0.4, BorderSizePixel = 0 }, { corner(math.min(R, 10)), pad(14, 14, 10, 10) })
		make("TextLabel", { Parent = f, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = self.F, Text = name, TextSize = 13, TextWrapped = true, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Left })
	elseif e.Type == "Button" then
		f = self:_card(page, name, e.Desc, { reserve = 44 })
		local icon = make("TextLabel", { Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Text = "›", Font = self.FB, TextSize = 22 })
		self:_accent(icon, "TextColor3")
		local b = make("TextButton", { Parent = f, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 3 })
		b.MouseButton1Down:Connect(function(x, y) self:_ripple(f, x, y) end)
		b.MouseButton1Click:Connect(function()
			self:_click()
			tween(icon, 0.1, { Position = UDim2.new(1, -8, 0.5, 0) }).Completed:Connect(function() tween(icon, 0.2, { Position = UDim2.new(1, -14, 0.5, 0) }) end)
			self:_safe(name, e.Callback)
		end)
	elseif e.Type == "Toggle" then
		f = self:_card(page, name, e.Desc, { reserve = 70 })
		local sw = make("Frame", { Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundColor3 = T.Surface2, BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local swStroke = make("UIStroke", { Parent = sw, Color = T.Stroke, Thickness = 1 })
		local knob = make("Frame", { Parent = sw, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = T.SubText, BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local state, token = false, 0
		local look = self.Sty and self.Sty.toggle(self, sw, knob, swStroke)
		if look then look(false) end
		local function set(v, silent)
			state = v and true or false
			self.Flags[name] = state
			self:_save()
			if look then look(state) else
				tween(sw, 0.25, { BackgroundColor3 = state and T.Accent or T.Surface2 })
				tween(swStroke, 0.25, { Color = state and T.Accent or T.Stroke })
				tween(knob, 0.3, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = state and Color3.new(1, 1, 1) or T.SubText }, Enum.EasingStyle.Back)
			end
			if silent then return end
			token += 1
			local my = token
			if state then
				self:_safe(name, e.On)
				if type(e.Loop) == "function" then
					task.spawn(function()
						while self.Alive and state and token == my do
							local ok, err = pcall(e.Loop)
							if not ok then
								warn("[Loop] " .. name .. ": " .. tostring(err))
								self:Notify(self.S.LoopError .. name, tostring(err), 4)
								set(false)
								break
							end
							task.wait(tonumber(e.Interval) or 0.1)
						end
					end)
				end
			else
				self:_safe(name, e.Off)
			end
		end
		self.Setters[name] = set
		local b = make("TextButton", { Parent = f, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 3 })
		b.MouseButton1Click:Connect(function() self:_click(); set(not state) end)
		self.Flags[name] = false
		local sv = self.Saved and self.Saved[name]
		if sv == nil then sv = e.Default end
		if sv then task.defer(set, true) end
	elseif e.Type == "Slider" then
		local hasDesc = e.Desc and e.Desc ~= ""
		f = self:_card(page, name, e.Desc, { reserve = 84, descReserve = 14, bottom = 20 })
		local mn, mx = tonumber(e.Min) or 0, tonumber(e.Max) or 100
		if mx <= mn then mx = mn + 1 end
		local dec = tonumber(e.Decimals) or 0
		local valL = make("TextLabel", { Parent = f, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, hasDesc and 8 or 8), Size = UDim2.fromOffset(70, 20), BackgroundTransparency = 1, Font = self.FB, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right })
		self:_accent(valL, "TextColor3")
		local track = make("Frame", { Parent = f, Position = UDim2.new(0, 14, 1, -16), Size = UDim2.new(1, -28, 0, 6), BackgroundColor3 = T.Surface2, BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local fill = make("Frame", { Parent = track, Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		self:_accent(fill, "BackgroundColor3")
		local dot = make("Frame", { Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local look = self.Sty and self.Sty.slider(self, track, fill, dot)
		local value
		local function set(v, fire)
			local m = 10 ^ dec
			v = math.clamp(math.floor(v * m + 0.5) / m, mn, mx)
			if v == value then return end
			value = v
			self.Flags[name] = v
			valL.Text = tostring(v)
			if fire ~= false then self:_save() end
			tween(fill, 0.08, { Size = UDim2.fromScale((v - mn) / (mx - mn), 1) }, Enum.EasingStyle.Linear)
			if look then look((v - mn) / (mx - mn)) end
			if fire ~= false then self:_safe(name, e.Callback, v) end
		end
		self.Setters[name] = set
		local startV = tonumber(e.Default) or mn
		local saved = not e.Internal and self.Saved and tonumber(self.Saved[name])
		set(startV, false)
		if saved and saved ~= startV then task.defer(set, saved) end
		if not e.Internal then
			-- when the hub is closed, put the value back to where it started (e.g. WalkSpeed 16)
			table.insert(self.Restores, function() if value ~= startV then self:_safe(name, e.Callback, startV) end end)
		end
		local dragging = false
		local function upd(x)
			local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			set(mn + (mx - mn) * rel)
		end
		local hit = make("TextButton", { Parent = f, Position = UDim2.new(0, 8, 1, -28), Size = UDim2.new(1, -16, 0, 28), BackgroundTransparency = 1, Text = "", ZIndex = 3 })
		hit.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				tween(dot, 0.15, { Size = UDim2.fromOffset(18, 18) })
				upd(i.Position.X)
			end
		end)
		self:_conn(UIS.InputChanged, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
		end)
		self:_conn(UIS.InputEnded, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				tween(dot, 0.15, { Size = UDim2.fromOffset(14, 14) })
			end
		end)
	elseif e.Type == "Keybind" then
		local kb
		local card
		f, card = self:_card(page, name, e.Desc, { reserve = 100, stack = 26, onStack = function(st, y)
			if not kb then return end
			if st then kb.AnchorPoint = Vector2.new(0, 0); kb.Position = UDim2.fromOffset(14, y)
			else kb.AnchorPoint = Vector2.new(1, 0.5); kb.Position = UDim2.new(1, -12, 0.5, 0) end
		end })
		local key = (self.Saved and type(self.Saved[name]) == "string" and self.Saved[name]) or e.Key or "E"
		if key ~= e.Key and e.OnChange and key ~= "None" then e.OnChange(key) end
		kb = make("TextButton", { Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Surface2, Font = self.FB, TextSize = 12, TextColor3 = T.Text, Text = key, AutoButtonColor = false, ZIndex = 3 }, { corner(6), pad(10, 10, 0, 0) })
		self:_accent(make("UIStroke", { Parent = kb, Thickness = 1, Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }), "Color")
		self:_fitCard(card)
		local waiting = false
		self.Flags[name] = key
		kb.MouseButton1Click:Connect(function() waiting = true; kb.Text = "..." end)
		self:_conn(UIS.InputBegan, function(i, gp)
			if waiting then
				if i.UserInputType == Enum.UserInputType.Keyboard then
					waiting = false
					if i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Backspace then key = "None" else key = i.KeyCode.Name end
					kb.Text = key
					self.Flags[name] = key
					self:_save()
					if e.OnChange then e.OnChange(key) end
				end
				return
			end
			if gp or key == "None" then return end
			if i.KeyCode.Name == key then
				tween(kb, 0.1, { BackgroundColor3 = T.Accent }).Completed:Connect(function() tween(kb, 0.3, { BackgroundColor3 = T.Surface2 }) end)
				self:_safe(name, e.Callback)
			end
		end)
	elseif e.Type == "Textbox" then
		local tb
		local card
		f, card = self:_card(page, name, e.Desc, { reserve = 186, stack = 28, onStack = function(st, y)
			if not tb then return end
			if st then tb.AnchorPoint = Vector2.new(0, 0); tb.Position = UDim2.fromOffset(14, y); tb.Size = UDim2.new(1, -28, 0, 28)
			else tb.AnchorPoint = Vector2.new(1, 0.5); tb.Position = UDim2.new(1, -12, 0.5, 0); tb.Size = UDim2.fromOffset(160, 26) end
		end })
		tb = make("TextBox", { Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(160, 26), BackgroundColor3 = T.Surface2, Font = self.F, TextSize = 12, TextColor3 = T.Text, PlaceholderText = e.Placeholder or self.S.Type, PlaceholderColor3 = T.SubText, Text = tostring(e.Default or ""), ClearTextOnFocus = false, ZIndex = 3 }, { corner(6), pad(8, 8, 0, 0) })
		local st = make("UIStroke", { Parent = tb, Color = T.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
		self:_fitCard(card)
		if self.Saved and type(self.Saved[name]) == "string" then tb.Text = self.Saved[name]; self.Flags[name] = tb.Text end
		tb.Focused:Connect(function() tween(st, 0.2, { Color = T.Accent }) end)
		tb.FocusLost:Connect(function(enter)
			tween(st, 0.2, { Color = T.Stroke })
			self.Flags[name] = tb.Text
			self:_save()
			if enter or e.FireOnLeave then self:_safe(name, e.Callback, tb.Text) end
		end)
	elseif e.Type == "Dropdown" then
		local opts = e.Options or {}
		local baseH, cur, arrow, list, hb = 40, nil, nil, nil, nil
		local open = false
		local sY -- set when the menu is narrow: the choice sits under the name
		local function apply(h, c)
			baseH = h
			if cur then
				if sY then
					cur.AnchorPoint = Vector2.new(0, 0); cur.Position = UDim2.fromOffset(14, sY); cur.Size = UDim2.new(1, -50, 0, 26); cur.TextXAlignment = Enum.TextXAlignment.Left
					arrow.Position = UDim2.new(1, -12, 0, sY); arrow.Size = UDim2.fromOffset(18, 26)
				else
					cur.AnchorPoint = Vector2.new(1, 0); cur.Position = UDim2.new(1, -34, 0, 0); cur.Size = UDim2.fromOffset(140, h); cur.TextXAlignment = Enum.TextXAlignment.Right
					arrow.Position = UDim2.new(1, -12, 0, 0); arrow.Size = UDim2.fromOffset(18, h)
				end
				list.Position = UDim2.fromOffset(8, h)
				hb.Size = UDim2.new(1, 0, 0, h)
			end
			local fr = (c and c.Frame) or f
			if fr then fr.Size = UDim2.new(1, 0, 0, h + (open and (#opts * 30 + 8) or 0)) end
		end
		local card
		f, card = self:_card(page, name, e.Desc, { reserve = 170, onFit = apply, stack = 26, onStack = function(st, y) sY = st and y or nil end })
		cur = make("TextLabel", { Parent = f, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -34, 0, 0), Size = UDim2.fromOffset(140, baseH), BackgroundTransparency = 1, Font = self.F, TextSize = 12, TextColor3 = T.SubText, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Text = "" })
		arrow = make("TextLabel", { Parent = f, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(18, baseH), BackgroundTransparency = 1, Font = self.FB, TextSize = 14, Text = "▾" })
		self:_accent(arrow, "TextColor3")
		list = make("Frame", { Parent = f, Position = UDim2.fromOffset(8, baseH), Size = UDim2.new(1, -16, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, { make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }), pad(0, 0, 0, 8) })
		local btns = {}
		local function set(o, fire)
			cur.Text = tostring(o)
			self.Flags[name] = o
			if fire ~= false then self:_save() end
			for k, b in pairs(btns) do tween(b, 0.15, { BackgroundColor3 = k == o and T.Accent or T.Surface2 }) end
			if fire ~= false then self:_safe(name, e.Callback, o) end
		end
		self.Setters[name] = set
		local function toggle()
			open = not open
			local h = baseH + (open and (#opts * 30 + 8) or 0)
			tween(f, 0.3, { Size = UDim2.new(1, 0, 0, h) })
			tween(arrow, 0.3, { Rotation = open and 180 or 0 })
		end
		for idx, o in ipairs(opts) do
			local b = make("TextButton", { Parent = list, LayoutOrder = idx, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = T.Surface2, Font = self.F, TextSize = 12, TextColor3 = T.Text, Text = tostring(o), AutoButtonColor = false }, { corner(6) })
			btns[o] = b
			b.MouseButton1Click:Connect(function() self:_click(); set(o); toggle() end)
		end
		hb = make("TextButton", { Parent = f, Size = UDim2.new(1, 0, 0, baseH), BackgroundTransparency = 1, Text = "", ZIndex = 3 })
		hb.MouseButton1Click:Connect(toggle)
		self:_fitCard(card)
		local sv = self.Saved and self.Saved[name]
		if sv ~= nil and table.find(opts, sv) then task.defer(set, sv)
		elseif e.Default and e.Default ~= "" then set(e.Default, false) else cur.Text = self.S.Select end
	else
		return
	end
	table.insert(self.Elements, { Name = name, Tab = tabName, Frame = f })
	f.LayoutOrder = #self.Elements
end

function Library:ApplyTheme(theme)
	if type(theme) ~= "table" then return end
	local old = {}
	for k, v in pairs(self.T) do old[k] = v end
	local nextT = {}
	for k, v in pairs(old) do nextT[k] = hex(theme[k], v) end
	self.T = nextT
	for _, obj in ipairs(self.Gui:GetDescendants()) do
		for _, prop in ipairs({"BackgroundColor3", "TextColor3", "ImageColor3", "Color"}) do
			pcall(function()
				local value = obj[prop]
				if typeof(value) == "Color3" then
					for key, before in pairs(old) do if value == before then obj[prop] = nextT[key]; break end end
				end
			end)
		end
		if obj:IsA("UIGradient") then pcall(function()
			local points = {}
			for _, kp in ipairs(obj.Color.Keypoints) do
				local c = kp.Value
				for key, before in pairs(old) do if c == before then c = nextT[key]; break end end
				table.insert(points, ColorSequenceKeypoint.new(kp.Time, c))
			end
			obj.Color = ColorSequence.new(points)
		end) end
	end
	for _, a in ipairs(self.AccentObjs) do pcall(function() if a[1].Parent then a[1][a[2]] = nextT.Accent end end) end
	self.Config.Theme = theme
	self:_paintGradients()
end

function Library:Build(elements, tabsOrder)
	self:_loadSaved()
	for _, t in ipairs(tabsOrder or {}) do self:_tab(t) end
	for _, e in ipairs(elements or {}) do
		local ok, err = pcall(function() self:_element(e) end)
		if not ok then warn("[WyvernHub] element " .. tostring(e.Name) .. ": " .. tostring(err)) end
	end
	if self.Config.SettingsTab ~= false then
		local st = (self.Config.SettingsTabName and self.Config.SettingsTabName ~= "") and self.Config.SettingsTabName or self.S.Settings
		if self.Config.TabIcons and not self.Config.TabIcons[st] then self.Config.TabIcons[st] = "settings" end
		self:_element({ Type = "Section", Name = "Hub", Tab = st })
		self:_element({ Type = "Slider", Name = self.S.MenuSize, Desc = "", Tab = st, Min = 50, Max = 160, Default = math.floor(self.UserScale * 100 + 0.5), Internal = true, Callback = function(v) self:SetMenuSize(v / 100) end })
		local themePresets = {
			Crimson = { Accent="#ff1e3c", Accent2="#7a0012", Background="#101018", Surface="#20202a", Surface2="#292936", Text="#f5f5f7", SubText="#9a9aa6", Stroke="#2e2e36" },
			Purple = { Accent="#a855f7", Accent2="#581c87", Background="#100b18", Surface="#21152d", Surface2="#30203f", Text="#faf5ff", SubText="#c4b5d4", Stroke="#49345a" },
			Ocean = { Accent="#22d3ee", Accent2="#075985", Background="#07141c", Surface="#102630", Surface2="#183744", Text="#ecfeff", SubText="#9dbbc4", Stroke="#28505d" },
			Emerald = { Accent="#34d399", Accent2="#047857", Background="#081711", Surface="#10251b", Surface2="#193528", Text="#ecfdf5", SubText="#a7c8b7", Stroke="#2c5540" },
			Gold = { Accent="#fbbf24", Accent2="#92400e", Background="#171208", Surface="#29200f", Surface2="#392d16", Text="#fffbeb", SubText="#c9b98e", Stroke="#594522" },
		}
		self:_element({ Type = "Dropdown", Name = "Theme Color", Desc = "Pilih warna tema hub", Tab = st, Options = {"Crimson", "Purple", "Ocean", "Emerald", "Gold"}, Default = "Crimson", Callback = function(v) if themePresets[v] then self:ApplyTheme(themePresets[v]) end end })
		self:_element({ Type = "Keybind", Name = self.S.ToggleKey, Tab = st, Key = self.ToggleKey, Callback = function() end, OnChange = function(k) if k ~= "None" then self.ToggleKey = k end end })
		if self.Config.SaveSettings ~= false then
			self:_element({ Type = "Button", Name = self.S.Reset, Desc = self.S.ResetDesc, Tab = st, Callback = function()
				pcall(function() if delfile and self.SaveFile and isfile and isfile(self.SaveFile) then delfile(self.SaveFile) end end)
				self.SaveFile = nil
				self:Notify(self.Config.Title or "Hub", self.S.ResetDone, 3)
			end })
		end
		self:_element({ Type = "Button", Name = self.S.Destroy, Desc = self.S.DestroyDesc, Tab = st, Callback = function() self:Destroy() end })
	end
	local first = (tabsOrder and tabsOrder[1])
	if first and self.Pages[first] then self:SelectTab(first) end
	self:_intro()
	self:_watchUpdates()
end

-- hosted scripts: every few minutes ask whether a newer version was published
function Library:_watchUpdates()
	local hs = self.Hosted
	if type(hs) ~= "table" or type(hs.Url) ~= "string" then return end
	task.spawn(function()
		while self.Alive do
			task.wait(180)
			if not self.Alive then break end
			local ok, v = pcall(function() return game:HttpGet(hs.Url .. "/v") end)
			v = ok and tonumber(v) or nil
			if v and v > (tonumber(hs.Ver) or 0) then
				self:Notify(self.Config.Title or "Hub", self.S.Update, 10)
				break
			end
		end
	end)
end

function Library:_intro()
	local cfg = self.Config
	self.Main.Visible = false
	local function show()
		self.Visible = false
		self:SetVisible(true)
		if cfg.LoadNotify ~= false then
			self:Notify(cfg.Title or "Hub", (cfg.LoadText and cfg.LoadText ~= "") and cfg.LoadText or (self.S.Loaded .. self.ToggleKey), 4)
		end
		if true then
			task.delay(1, function() if self.Alive then self:Notify("Wyvern Studio", "This hub was made with Wyvern Studio.", 4) end end)
		end
	end
	if cfg.Intro == false then show() return end
	local T = self.T
	local ov = make("Frame", { Parent = self.Gui, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 100 })
	local ib = self:_brand(ov, 84, 38)
	if ib then
		ib.AnchorPoint = Vector2.new(0.5, 0.5)
		ib.Position = UDim2.fromScale(0.5, 0.33)
		ib.ZIndex = 101
		for _, d in ipairs(ib:GetDescendants()) do if d:IsA("GuiObject") then d.ZIndex = 102 end end
		local sc = make("UIScale", { Parent = ib, Scale = 0 })
		tween(sc, 0.6, { Scale = 1 }, Enum.EasingStyle.Back)
		task.delay(1.4, function() tween(sc, 0.35, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In) end)
	end
	local t = make("TextLabel", { Parent = ov, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.47), Size = UDim2.fromOffset(600, 60), BackgroundTransparency = 1, Font = self.TF, Text = cfg.IntroText ~= "" and cfg.IntroText or cfg.Title or "Hub", TextSize = 44, TextColor3 = Color3.new(1, 1, 1), TextTransparency = 1, ZIndex = 101 })
	make("UIGradient", { Parent = t, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, T.Text), ColorSequenceKeypoint.new(1, T.Accent) }) })
	local barBg = make("Frame", { Parent = ov, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.54), Size = UDim2.fromOffset(220, 3), BackgroundColor3 = T.Surface2, BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 101 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local bar = make("Frame", { Parent = barBg, Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 102 }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	tween(ov, 0.4, { BackgroundTransparency = 0.35 })
	tween(t, 0.6, { TextTransparency = 0, Position = UDim2.fromScale(0.5, 0.45) })
	tween(barBg, 0.4, { BackgroundTransparency = 0 })
	tween(bar, 1.3, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Quad)
	task.delay(1.5, function()
		tween(t, 0.35, { TextTransparency = 1 })
		tween(barBg, 0.35, { BackgroundTransparency = 1 })
		tween(bar, 0.35, { BackgroundTransparency = 1 })
		tween(ov, 0.45, { BackgroundTransparency = 1 }).Completed:Connect(function() ov:Destroy() end)
		show()
	end)
end

function Library:Set(name, value)
	local s = self.Setters[name]
	if s then s(value) end
end

-- Helper objects that functions create and must not stay in the game after closing
local HELPERS = { BodyVelocity = true, BodyGyro = true, BodyPosition = true, BodyForce = true, BodyThrust = true, BodyAngularVelocity = true, LinearVelocity = true, AngularVelocity = true, AlignPosition = true, AlignOrientation = true, VectorForce = true, Highlight = true, SelectionBox = true, BoxHandleAdornment = true, BillboardGui = true }
local function sweep(t, seen)
	if type(t) ~= "table" or seen[t] then return end
	seen[t] = true
	for k, v in pairs(t) do
		local ty = typeof(v)
		if ty == "RBXScriptConnection" then
			pcall(function() v:Disconnect() end)
			t[k] = nil
		elseif ty == "thread" then
			pcall(task.cancel, v)
			t[k] = nil
		elseif ty == "Instance" then
			local ok, cls = pcall(function() return v.ClassName end)
			if ok and HELPERS[cls] then pcall(function() v:Destroy() end); t[k] = nil end
		elseif ty == "table" then
			sweep(v, seen)
		end
	end
end

-- Wraps a service so that every connection made through it is closed with the hub.
function Library:Track(svc)
	local hub, cache, proxy = self, {}, nil
	local function track(c) table.insert(hub.UserConns, c) return c end
	proxy = setmetatable({}, {
		__index = function(_, k)
			local v = svc[k]
			if typeof(v) == "RBXScriptSignal" then
				if not cache[k] then
					cache[k] = {
						Connect = function(_, fn) return track(v:Connect(fn)) end,
						Once = function(_, fn) return track(v:Once(fn)) end,
						ConnectParallel = function(_, fn) return track(v:ConnectParallel(fn)) end,
						Wait = function(_) return v:Wait() end,
					}
				end
				return cache[k]
			elseif type(v) == "function" then
				if k == "BindToRenderStep" then
					return function(_, name, ...) table.insert(hub.RenderBinds, name) return v(svc, name, ...) end
				end
				return function(me, ...) if me == proxy then return v(svc, ...) end return v(me, ...) end
			end
			return v
		end,
		__newindex = function(_, k, v) svc[k] = v end,
		__tostring = function() return tostring(svc) end,
	})
	return proxy
end

-- Closes the hub completely: every function is switched off and nothing keeps running.
function Library:Destroy(instant)
	if not self.Alive then return end
	self.Alive = false
	-- 1. every toggle that is on runs its "off" code
	for n, v in pairs(self.Flags) do if v == true and self.Setters[n] then pcall(self.Setters[n], false) end end
	-- 2. sliders go back to their start value (WalkSpeed, gravity, FOV ...)
	for _, r in ipairs(self.Restores) do pcall(r) end
	-- 3. stop everything the functions connected
	local function cleanup()
		for _, c in ipairs(self.UserConns) do pcall(function() c:Disconnect() end) end
		table.clear(self.UserConns)
		for _, n in ipairs(self.RenderBinds) do pcall(function() RunService:UnbindFromRenderStep(n) end) end
		if self.Store then sweep(self.Store, {}) end
	end
	cleanup()
	task.delay(0.5, cleanup) -- again, after "off" code that waited for something
	for _, c in ipairs(self.Conns) do pcall(function() c:Disconnect() end) end
	if self.BlurFx then self.BlurFx:Destroy() end
	if self.ClickSnd then pcall(function() self.ClickSnd:Destroy() end) end
	pcall(function() if rawget(self.G, "__WyvernHub") == self then rawset(self.G, "__WyvernHub", nil) end end)
	if self.Gui then
		if instant then
			self.Gui:Destroy()
		else
			local tw = tween(self.Scale, 0.25, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			tw.Completed:Connect(function() if self.Gui then self.Gui:Destroy() end end)
		end
	end
	if self.OnDestroy then pcall(self.OnDestroy) end
end

return Library

end)()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local Store = {}
local selectedTeleportUserId = nil
local teleportRequestBusy = false

-- ===== SETTINGS & DESIGN =====
local Config = {
	Animation = "Pop",
	Blur = false,
	Brand = true,
	ButtonShape = "Square",
	ClickSound = "None",
	Corner = 10,
	Font = "Gotham",
	Fx = {
		Amount = 50,
		Animated = true,
		Color1 = "",
		Color2 = "",
		Particles = true,
		Speed = 100,
	},
	Glow = true,
	Gradient = true,
	Icon = "",
	IconData = {
		bell = { 16898612819, 820, 257 },
		eye = { 16898613353, 771, 563 },
		minus = { 16898613613, 771, 196 },
		["move-diagonal-2"] = { 16898613613, 967, 49 },
		["person-standing"] = { 16898613699, 563, 771 },
		search = { 16898613699, 918, 857 },
		settings = { 16898613777, 771, 257 },
		sparkles = { 16898613777, 918, 49 },
		wrench = { 16898613869, 820, 906 },
		x = { 16898613869, 869, 906 },
	},
	IconGlow = true,
	IconLetter = "P",
	IconMode = "Wordmark",
	IconName = "crown",
	Intro = false,
	IntroText = "",
	Language = "en",
	LoadNotify = true,
	LoadText = "",
	MobileButton = true,
	NotifyPosition = "BottomRight",
	Rainbow = false,
	SaveSettings = true,
	SearchBar = true,
	SettingsTab = true,
	SettingsTabName = "",
	Size = {
		X = 580,
		Y = 400,
	},
	SoundId = "",
	SoundVolume = 50,
	Special = "",
	Subtitle = "Telegram @piexxie03",
	TabIcons = {
		Fun = "sparkles",
		Movement = "person-standing",
		Utility = "wrench",
		Visual = "eye",
	},
	TabStyle = "Sidebar",
	Theme = {
		Accent = "#ff1e3c",
		Accent2 = "#7a0012",
		Background = "#101018",
		Stroke = "#2e2e36",
		SubText = "#9a9aa6",
		Surface = "#20202a",
		Surface2 = "#292936",
		Text = "#f5f5f7",
	},
	Title = "Piexxie03Hub ",
	ToggleKey = "RightShift",
	Transparency = 0.38,
	Watermark = false,
}

local Hub = Library.new(Config)
-- everything connected through these is switched off when the hub is closed
Hub.Store = Store
RunService = Hub:Track(RunService)
UIS = Hub:Track(UIS)
local Flags = Hub.Flags
local Elements = {}

-- Player aim-assist target helpers (for this experience).
local function getAimTargets()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local part = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and part and part:IsA("BasePart") then
                    table.insert(targets, { Part = part })
                end
            end
        end
    end
    return targets
end

local function getClosestAimTarget(maxPixels)
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    local bestPart, bestDistance = nil, maxPixels or 90

    for _, target in ipairs(getAimTargets()) do
        local screenPoint, onScreen = camera:WorldToViewportPoint(target.Part.Position)
        if onScreen and screenPoint.Z > 0 then
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                bestPart = target.Part
            end
        end
    end
    return bestPart
end

-- FOV visual only: no target selection or camera steering.
-- [1] WalkSpeed (Slider)
table.insert(Elements, {
	Type = "Slider", Name = "WalkSpeed", Tab = "Movement",
	Desc = "Run faster",
	Min = 16, Max = 250, Default = 16, Decimals = 0,
	Callback = function(value)
		local hum = getHum()
		if hum then
		    hum.WalkSpeed = value
		end
	end,
})

-- [2] Jump Power (Slider)
table.insert(Elements, {
	Type = "Slider", Name = "Jump Power", Tab = "Movement",
	Desc = "Jump higher",
	Min = 50, Max = 400, Default = 50, Decimals = 0,
	Callback = function(value)
		local hum = getHum()
		if hum then
		    hum.UseJumpPower = true
		    hum.JumpPower = value
		end
	end,
})

-- [2B] Gravity (Slider)
-- Local client-side gravity control; server-owned game physics may override this.
Store.defaultGravity = workspace.Gravity

table.insert(Elements, {
    Type = "Slider", Name = "Gravity", Tab = "Movement",
    Desc = "Adjust local workspace gravity (default is restored with Reset Gravity)",
    Min = 0, Max = 400, Default = math.floor(workspace.Gravity + 0.5), Decimals = 0,
    Callback = function(value)
        workspace.Gravity = value
    end,
})

table.insert(Elements, {
    Type = "Button", Name = "Reset Gravity", Tab = "Movement",
    Desc = "Restore the gravity value captured when the hub loaded",
    Callback = function()
        workspace.Gravity = Store.defaultGravity or 196.2
        Hub:Notify("Gravity", "Gravitasi dikembalikan ke nilai awal.", 3)
    end,
})

-- [2C] Fly Mode (Toggle)
-- For this experience in Roblox Studio. Keyboard: WASD to move, Space to rise,
-- LeftControl to descend. Mobile: use the movement joystick; Jump rises.
table.insert(Elements, {
    Type = "Toggle", Name = "Fly Mode", Tab = "Movement",
    Desc = "Terbang bebas: WASD/joystick untuk bergerak, Space untuk naik, Ctrl untuk turun",
    Default = false, Interval = 0.03,
    On = function()
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then
            Hub:Notify("Fly Mode", "Karakter belum siap. Coba aktifkan lagi.", 4)
            return
        end

        -- Bersihkan pengendali lama jika toggle diaktifkan ulang.
        if Store.flyConnection then Store.flyConnection:Disconnect(); Store.flyConnection = nil end
        if Store.flyVelocity then Store.flyVelocity:Destroy(); Store.flyVelocity = nil end
        if Store.flyGyro then Store.flyGyro:Destroy(); Store.flyGyro = nil end

        Store.flyHumanoid = humanoid
        Store.flyOldAutoRotate = humanoid.AutoRotate
        humanoid.AutoRotate = false

        local attachment = Instance.new("Attachment")
        attachment.Name = "PiexxieFlyAttachment"
        attachment.Parent = root
        Store.flyAttachment = attachment

        local velocity = Instance.new("LinearVelocity")
        velocity.Name = "PiexxieFlyVelocity"
        velocity.Attachment0 = attachment
        velocity.RelativeTo = Enum.ActuatorRelativeTo.World
        velocity.MaxForce = math.huge
        velocity.VectorVelocity = Vector3.zero
        velocity.Parent = root
        Store.flyVelocity = velocity

        local gyro = Instance.new("AlignOrientation")
        gyro.Name = "PiexxieFlyOrientation"
        gyro.Attachment0 = attachment
        gyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
        gyro.MaxTorque = math.huge
        gyro.Responsiveness = 18
        gyro.Parent = root
        Store.flyGyro = gyro

        Store.flySpeed = Store.flySpeed or 55
        Store.flyConnection = RunService.RenderStepped:Connect(function()
            if not root.Parent or not humanoid.Parent or humanoid.Health <= 0 then
                if Store.flyConnection then Store.flyConnection:Disconnect(); Store.flyConnection = nil end
                return
            end

            local camera = workspace.CurrentCamera
            if not camera then return end
            local move = humanoid.MoveDirection
            local horizontal = Vector3.new(move.X, 0, move.Z)
            local vertical = 0

            if UIS:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
                vertical = 1
            elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then
                vertical = -1
            end

            -- Kamera menentukan arah hadap; joystick tetap mengatur gerak mendatar.
            local direction = horizontal * (Store.flySpeed or 55) + Vector3.new(0, vertical * (Store.flySpeed or 55), 0)
            velocity.VectorVelocity = direction
            local look = camera.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            if flatLook.Magnitude > 0.001 then
                gyro.CFrame = CFrame.lookAt(root.Position, root.Position + flatLook.Unit)
            end
        end)
        Hub:Notify("Fly Mode", "Terbang aktif. WASD/joystick, Space naik, Ctrl turun.", 4)
    end,
    Off = function()
        if Store.flyConnection then Store.flyConnection:Disconnect(); Store.flyConnection = nil end
        if Store.flyVelocity then Store.flyVelocity:Destroy(); Store.flyVelocity = nil end
        if Store.flyGyro then Store.flyGyro:Destroy(); Store.flyGyro = nil end
        if Store.flyAttachment then Store.flyAttachment:Destroy(); Store.flyAttachment = nil end
        if Store.flyHumanoid and Store.flyHumanoid.Parent then
            Store.flyHumanoid.AutoRotate = Store.flyOldAutoRotate ~= false
        end
        Store.flyHumanoid = nil
        Hub:Notify("Fly Mode", "Mode terbang dimatikan.", 3)
    end,
})

-- [2D] Fly Speed (Slider)
table.insert(Elements, {
    Type = "Slider", Name = "Fly Speed", Tab = "Movement",
    Desc = "Mengatur kecepatan gerak saat Fly Mode aktif",
    Min = 10, Max = 120, Default = 55, Decimals = 0,
    Callback = function(value)
        Store.flySpeed = value
    end,
})

-- [3] Infinity Jump (Toggle)
table.insert(Elements, {
    Type = "Toggle", Name = "Infinity Jump", Tab = "Movement",
    Desc = "Jump again while airborne in your own experience",
    Default = false, Interval = 0.1,
    On = function()
        if Store.infinityJump then Store.infinityJump:Disconnect() end
        Store.infinityJump = UIS.JumpRequest:Connect(function()
            local hum = getHum()
            if hum and hum.Health > 0 and hum.FloorMaterial == Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end,
    Off = function()
        if Store.infinityJump then
            Store.infinityJump:Disconnect()
            Store.infinityJump = nil
        end
    end,
})

-- [4] Fullbright (Toggle)
table.insert(Elements, {
	Type = "Toggle", Name = "Fullbright", Tab = "Visual",
	Desc = "See everything clearly",
	Default = false, Interval = 0.1,
	On = function()
		local L = game:GetService("Lighting")
		Store.light = { L.Brightness, L.ClockTime, L.GlobalShadows, L.Ambient }
		L.Brightness = 2
		L.ClockTime = 14
		L.GlobalShadows = false
		L.Ambient = Color3.fromRGB(180, 180, 180)
	end,
	Off = function()
		local L = game:GetService("Lighting")
		local o = Store.light
		if o then
		    L.Brightness, L.ClockTime, L.GlobalShadows, L.Ambient = o[1], o[2], o[3], o[4]
		end
	end,
})

-- [5] ESP Wallhack (Toggle)
-- Debug/observer visual for your own Roblox experience.
table.insert(Elements, {
    Type = "Toggle", Name = "ESP Wallhack", Tab = "Visual",
    Desc = "Shows player outlines independently from name and distance",
    Default = false, Interval = 0.1,
    On = function()
        Store.espWallEnabled = true
        Store.espWallEntries = {}
        Store.espWallConnections = {}

        local function removeCharacter(character)
            local highlight = Store.espWallEntries and Store.espWallEntries[character]
            if highlight then
                highlight:Destroy()
                Store.espWallEntries[character] = nil
            end
        end

        local function addCharacter(player, character)
            if player == LocalPlayer or not character then return end
            task.spawn(function()
                local humanoid = character:WaitForChild("Humanoid", 10)
                if not humanoid or humanoid.Health <= 0 then return end
                if not Store.espWallEnabled or not Store.espWallEntries or Store.espWallEntries[character] then return end

                local highlight = Instance.new("Highlight")
                highlight.Name = "PiexxieWallESP"
                highlight.Adornee = character
                highlight.FillTransparency = 1
                highlight.OutlineColor = Color3.fromRGB(255, 45, 65)
                highlight.OutlineTransparency = 0.05
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character

                Store.espWallEntries[character] = highlight
            end)
        end

        local function watchPlayer(player)
            if player == LocalPlayer then return end
            if player.Character then addCharacter(player, player.Character) end
            table.insert(Store.espWallConnections, player.CharacterAdded:Connect(function(character)
                addCharacter(player, character)
            end))
            table.insert(Store.espWallConnections, player.CharacterRemoving:Connect(removeCharacter))
        end

        for _, player in ipairs(Players:GetPlayers()) do watchPlayer(player) end
        table.insert(Store.espWallConnections, Players.PlayerAdded:Connect(watchPlayer))
        table.insert(Store.espWallConnections, Players.PlayerRemoving:Connect(function(player)
            if player.Character then removeCharacter(player.Character) end
        end))
    end,
    Off = function()
        Store.espWallEnabled = false
        for _, connection in ipairs(Store.espWallConnections or {}) do
            connection:Disconnect()
        end
        Store.espWallConnections = {}
        for character, highlight in pairs(Store.espWallEntries or {}) do
            if highlight then highlight:Destroy() end
            Store.espWallEntries[character] = nil
        end
        Store.espWallEntries = {}
    end,
})

-- [6] ESP Nama & Jarak (Toggle)
-- This toggle is independent from ESP Wallhack.
table.insert(Elements, {
    Type = "Toggle", Name = "ESP Nama & Jarak", Tab = "Visual",
    Desc = "Shows player display name, username, and distance in studs",
    Default = false, Interval = 0.1,
    On = function()
        Store.espInfoEnabled = true
        Store.espInfoEntries = {}
        Store.espInfoConnections = {}

        local function removeCharacter(character)
            local gui = Store.espInfoEntries and Store.espInfoEntries[character]
            if gui then
                gui:Destroy()
                Store.espInfoEntries[character] = nil
            end
        end

        local function addCharacter(player, character)
            if player == LocalPlayer or not character then return end
            task.spawn(function()
                local root = character:WaitForChild("HumanoidRootPart", 10)
                local humanoid = character:WaitForChild("Humanoid", 10)
                if not root or not humanoid or humanoid.Health <= 0 then return end
                if not Store.espInfoEnabled or not Store.espInfoEntries or Store.espInfoEntries[character] then return end

                local billboard = Instance.new("BillboardGui")
                billboard.Name = "PiexxieNameDistanceESP"
                billboard.Adornee = root
                billboard.Size = UDim2.fromOffset(180, 42)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.LightInfluence = 0
                billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "PlayerName"
                nameLabel.Size = UDim2.new(1, 0, 0, 21)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextStrokeTransparency = 0
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.Parent = billboard

                local distanceLabel = Instance.new("TextLabel")
                distanceLabel.Name = "Distance"
                distanceLabel.Position = UDim2.fromOffset(0, 21)
                distanceLabel.Size = UDim2.new(1, 0, 0, 19)
                distanceLabel.BackgroundTransparency = 1
                distanceLabel.Text = "... studs"
                distanceLabel.TextColor3 = Color3.fromRGB(255, 220, 70)
                distanceLabel.TextStrokeTransparency = 0
                distanceLabel.TextScaled = true
                distanceLabel.Font = Enum.Font.Gotham
                distanceLabel.Parent = billboard

                Store.espInfoEntries[character] = { Gui = billboard, DistanceLabel = distanceLabel }
            end)
        end

        local function watchPlayer(player)
            if player == LocalPlayer then return end
            if player.Character then addCharacter(player, player.Character) end
            table.insert(Store.espInfoConnections, player.CharacterAdded:Connect(function(character)
                addCharacter(player, character)
            end))
            table.insert(Store.espInfoConnections, player.CharacterRemoving:Connect(removeCharacter))
        end

        for _, player in ipairs(Players:GetPlayers()) do watchPlayer(player) end
        table.insert(Store.espInfoConnections, Players.PlayerAdded:Connect(watchPlayer))
        table.insert(Store.espInfoConnections, Players.PlayerRemoving:Connect(function(player)
            if player.Character then removeCharacter(player.Character) end
        end))

        Store.espInfoUpdate = RunService.Heartbeat:Connect(function()
            local myCharacter = LocalPlayer.Character
            local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for character, entry in pairs(Store.espInfoEntries or {}) do
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if not root or not humanoid or humanoid.Health <= 0 then
                    removeCharacter(character)
                elseif entry.DistanceLabel then
                    local distance = (myRoot.Position - root.Position).Magnitude
                    entry.DistanceLabel.Text = tostring(math.floor(distance + 0.5)) .. " studs"
                end
            end
        end)
    end,
    Off = function()
        Store.espInfoEnabled = false
        if Store.espInfoUpdate then
            Store.espInfoUpdate:Disconnect()
            Store.espInfoUpdate = nil
        end
        for _, connection in ipairs(Store.espInfoConnections or {}) do
            connection:Disconnect()
        end
        Store.espInfoConnections = {}
        for character, entry in pairs(Store.espInfoEntries or {}) do
            if entry.Gui then entry.Gui:Destroy() end
            Store.espInfoEntries[character] = nil
        end
        Store.espInfoEntries = {}
    end,
})

-- [6] Aim Assist (Player) (Toggle)
-- PC: hold right mouse button; touch devices: active while this toggle is enabled.
-- Target selection is limited to the on-screen FOV radius.
table.insert(Elements, {
    Type = "Toggle", Name = "Aim Assist (Player)", Tab = "Visual",
    Desc = "Softly guides the camera toward the nearest player inside the FOV",
    Default = false, Interval = 0.03,
    Loop = function()
        if not UIS.TouchEnabled and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            return
        end

        local camera = workspace.CurrentCamera
        local targetPart = getClosestAimTarget(Store.aimRadius or 90)
        if camera and targetPart then
            local desired = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
            camera.CFrame = camera.CFrame:Lerp(desired, 0.12)
        end
    end,
})

-- [6] FOV Circle (Visual Only) (Toggle)
-- A centered red ring for display only. It does not select or track characters.
table.insert(Elements, {
    Type = "Toggle", Name = "FOV Circle", Tab = "Visual",
    Desc = "Shows or hides a centered red visual circle",
    Default = false,
    On = function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        if Store.fovGui then Store.fovGui:Destroy() end

        local screen = Instance.new("ScreenGui")
        screen.Name = "Piexxie03VisualFOV"
        screen.ResetOnSpawn = false
        screen.IgnoreGuiInset = true
        screen.Parent = playerGui
        Store.fovGui = screen

        local circle = Instance.new("Frame")
        circle.Name = "FOVCircle"
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.Position = UDim2.fromScale(0.5, 0.5)
        circle.Size = UDim2.fromOffset(Store.fovDiameter or 180, Store.fovDiameter or 180)
        circle.BackgroundTransparency = 1
        circle.Parent = screen

        local round = Instance.new("UICorner")
        round.CornerRadius = UDim.new(1, 0)
        round.Parent = circle

        local outline = Instance.new("UIStroke")
        outline.Color = Color3.fromRGB(255, 35, 35)
        outline.Thickness = 2
        outline.Transparency = 0
        outline.Parent = circle

        Store.fovCircle = circle
    end,
    Off = function()
        if Store.fovGui then
            Store.fovGui:Destroy()
            Store.fovGui = nil
            Store.fovCircle = nil
        end
    end,
})

-- [6B] FOV Size (Slider)
table.insert(Elements, {
    Type = "Slider", Name = "FOV Size", Tab = "Visual",
    Desc = "Changes the visual circle diameter",
    Min = 60, Max = 600, Default = 180, Decimals = 0,
    Callback = function(value)
        Store.fovDiameter = value
        Store.aimRadius = value * 0.5
        if Store.fovCircle and Store.fovCircle.Parent then
            Store.fovCircle.Size = UDim2.fromOffset(value, value)
        end
    end,
})

-- [7] Anti-AFK (Toggle)
table.insert(Elements, {
	Type = "Toggle", Name = "Anti-AFK", Tab = "Utility",
	Desc = "Stops the 20 minute idle kick",
	Default = false, Interval = 0.1,
	On = function()
		local VirtualUser = game:GetService("VirtualUser")
		Store.afk = LocalPlayer.Idled:Connect(function()
		    VirtualUser:CaptureController()
		    VirtualUser:ClickButton2(Vector2.new())
		end)
	end,
	Off = function()
		if Store.afk then
		    Store.afk:Disconnect()
		    Store.afk = nil
		end
	end,
})

-- [7B] Teleport to Player (best-effort client-side attempt)
local teleportOptions = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(teleportOptions, player.Name)
    end
end
if #teleportOptions == 0 then
    table.insert(teleportOptions, "No other players")
end

table.insert(Elements, {
    Type = "Dropdown",
    Name = "Select Player",
    Tab = "TELEPORT",
    Desc = "Choose a player currently in this server",
    Options = teleportOptions,
    Callback = function(playerName)
        local target = Players:FindFirstChild(playerName)
        selectedTeleportUserId = target and target.UserId or nil
    end,
})

table.insert(Elements, {
    Type = "Button",
    Name = "Teleport to Selected Player",
    Tab = "TELEPORT",
    Desc = "Attempts to move your character beside the selected player",
    Callback = function()
        if teleportRequestBusy then return end
        if not selectedTeleportUserId then
            Hub:Notify("Teleport", "Pilih pemain terlebih dahulu.", 3)
            return
        end

        local target = Players:GetPlayerByUserId(selectedTeleportUserId)
        if not target or target == LocalPlayer then
            Hub:Notify("Teleport", "Pemain tujuan sudah tidak ada di server.", 4)
            return
        end

        local targetCharacter = target.Character
        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
        local myCharacter = LocalPlayer.Character
        local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myCharacter and myCharacter:FindFirstChildOfClass("Humanoid")
        if not targetRoot or not myRoot or not myHumanoid or myHumanoid.Health <= 0 then
            Hub:Notify("Teleport", "Karakter kamu atau pemain tujuan belum siap.", 4)
            return
        end

        teleportRequestBusy = true
        local destination = targetRoot.CFrame * CFrame.new(0, 0, 4)
        local ok, err = pcall(function()
            myCharacter:PivotTo(destination)
        end)
        teleportRequestBusy = false

        if ok then
            Hub:Notify("Teleport", "Percobaan teleport selesai. Jika server mengatur ulang posisi, map tersebut membatasi perpindahan dari klien.", 5)
        else
            Hub:Notify("Teleport", "Gagal melakukan percobaan: " .. tostring(err), 5)
        end
    end,
})

-- [7C] Saved position checkpoints (client-side, current server session)
local savedCheckpoints = {}
local function saveCheckpoint(index)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        Hub:Notify("Checkpoint", "Karakter belum siap. Coba lagi.", 4)
        return
    end
    savedCheckpoints[index] = root.CFrame
    Hub:Notify("Checkpoint " .. tostring(index), "Lokasi berhasil disimpan.", 3)
end

local function teleportCheckpoint(index, quiet)
    local destination = savedCheckpoints[index]
    if not destination then
        if not quiet then Hub:Notify("Checkpoint " .. tostring(index), "Titik ini belum disimpan.", 3) end
        return false
    end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        if not quiet then Hub:Notify("Checkpoint", "Karakter belum siap untuk berpindah.", 4) end
        return false
    end
    local ok, err = pcall(function()
        character:PivotTo(destination)
    end)
    if ok then
        if not quiet then Hub:Notify("Checkpoint " .. tostring(index), "Percobaan teleport ke titik tersimpan selesai.", 4) end
        return true
    else
        if not quiet then Hub:Notify("Checkpoint", "Teleport gagal: " .. tostring(err), 4) end
        return false
    end
end

-- Auto Loop: visit every saved checkpoint in ascending order, then return to the first.
local autoLoopRunning = false
local autoLoopToken = 0
local autoLoopDelay = 5

local function getSavedCheckpointIndexes()
    local indexes = {}
    for index = 1, 25 do
        if savedCheckpoints[index] then
            table.insert(indexes, index)
        end
    end
    return indexes
end

local function stopAutoLoop(showMessage)
    autoLoopRunning = false
    autoLoopToken += 1
    if showMessage then
        Hub:Notify("Auto Loop", "Auto Loop dihentikan.", 3)
    end
end

table.insert(Elements, {
    Type = "Section", Name = "AUTO PLAY / AUTO LOOP", Tab = "TELEPORT",
})
table.insert(Elements, {
    Type = "Slider", Name = "Delay Auto Loop", Tab = "TELEPORT",
    Desc = "Jeda antar-checkpoint dalam detik",
    Min = 1, Max = 10, Default = 5, Decimals = 0,
    Callback = function(value)
        autoLoopDelay = math.clamp(math.floor(tonumber(value) or 5), 1, 10)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "START AUTO LOOP", Tab = "TELEPORT",
    Desc = "Ulangi checkpoint tersimpan dari nomor terkecil sampai terbesar",
    Callback = function()
        if autoLoopRunning then
            Hub:Notify("Auto Loop", "Auto Loop sudah berjalan.", 3)
            return
        end

        local indexes = getSavedCheckpointIndexes()
        if #indexes == 0 then
            Hub:Notify("Auto Loop", "Simpan minimal satu checkpoint terlebih dahulu.", 4)
            return
        end

        autoLoopRunning = true
        autoLoopToken += 1
        local myToken = autoLoopToken
        Hub:Notify("Auto Loop", "Dimulai. Setelah checkpoint terakhir, urutan kembali ke checkpoint pertama.", 4)

        task.spawn(function()
            local cursor = 1
            while Hub.Alive and autoLoopRunning and autoLoopToken == myToken do
                local currentIndexes = getSavedCheckpointIndexes()
                if #currentIndexes == 0 then
                    stopAutoLoop(false)
                    Hub:Notify("Auto Loop", "Tidak ada checkpoint tersimpan. Auto Loop dihentikan.", 4)
                    break
                end

                if cursor > #currentIndexes then cursor = 1 end
                local checkpointNumber = currentIndexes[cursor]
                local success = teleportCheckpoint(checkpointNumber, true)
                if not success then
                    stopAutoLoop(false)
                    Hub:Notify("Auto Loop", "Proses dihentikan karena teleport checkpoint gagal.", 4)
                    break
                end

                cursor += 1
                task.wait(autoLoopDelay)
            end
        end)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "STOP AUTO LOOP", Tab = "TELEPORT",
    Desc = "Hentikan Auto Loop kapan saja",
    Callback = function()
        if not autoLoopRunning then
            Hub:Notify("Auto Loop", "Auto Loop sedang tidak berjalan.", 3)
            return
        end
        stopAutoLoop(true)
    end,
})

-- [7C-AUTO] Detect checkpoint objects by their names and visible text.
-- Intended for testing in experiences you own or have permission to test.
local detectedCheckpoints = {}
local detectedSummit = nil
local detectLoopRunning = false
local detectLoopPaused = false
local detectLoopToken = 0
local Workspace = game:GetService("Workspace")

local function checkpointNumberFromText(value)
    local valueLower = string.lower(tostring(value or ""))
    local number = valueLower:match("checkpoint[%s_%-]*(%d+)")
        or valueLower:match("check[%s_%-]*point[%s_%-]*(%d+)")
        or valueLower:match("pos[%s_%-]+pemeriksaan[%s_%-]*(%d+)")
        or valueLower:match("pemeriksaan[%s_%-]*(%d+)")
        or valueLower:match("cp[%s_%-]*(%d+)")
        or valueLower:match("stage[%s_%-]*(%d+)")
        or valueLower:match("(%d+)[%s_%-]*checkpoint")
        or valueLower:match("(%d+)[%s_%-]*cp")
        or valueLower:match("(%d+)[%s_%-]*pemeriksaan")
    return tonumber(number)
end

local function getCheckpointPart(object)
    if not object then return nil end
    if object:IsA("BasePart") then return object end
    if object:IsA("Model") then
        return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
    end
    if object:IsA("BillboardGui") or object:IsA("SurfaceGui") then
        if object.Adornee and object.Adornee:IsA("BasePart") then
            return object.Adornee
        end
    end
    local current = object.Parent
    while current and current ~= Workspace do
        if current:IsA("BasePart") then return current end
        if current:IsA("Model") then
            local part = current.PrimaryPart or current:FindFirstChildWhichIsA("BasePart", true)
            if part then return part end
        end
        current = current.Parent
    end
    return nil
end

local function getObjectText(object)
    local pieces = { object.Name }
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        table.insert(pieces, object.Text)
    end
    if object:IsA("BillboardGui") or object:IsA("SurfaceGui") then
        for _, child in ipairs(object:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                table.insert(pieces, child.Text)
            end
        end
    end
    return table.concat(pieces, " ")
end

local function scanMapCheckpoints()
    local found = {}
    local summit = nil
    local scanned = 0
    for _, object in ipairs(Workspace:GetDescendants()) do
        scanned += 1
        local combinedText = getObjectText(object)
        local lowerText = string.lower(combinedText)
        local number = checkpointNumberFromText(combinedText)
        local isSummit = lowerText:find("summit", 1, true) or lowerText:find("finish", 1, true)
        if (number and number >= 1 and number <= 250 and not found[number]) or (isSummit and not summit) then
            local part = getCheckpointPart(object)
            if part then
                if number and number >= 1 and number <= 250 and not found[number] then
                    found[number] = { Part = part, Name = object.Name }
                elseif isSummit and not summit then
                    summit = { Part = part, Name = object.Name }
                end
            end
        end
    end
    detectedCheckpoints = found
    detectedSummit = summit
    local indexes = {}
    for index in pairs(found) do table.insert(indexes, index) end
    table.sort(indexes)
    return indexes, summit ~= nil, scanned
end

local function teleportToDetectedPart(part, quiet)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not part or not part.Parent or not character or not humanoid or humanoid.Health <= 0 then
        if not quiet then Hub:Notify("Auto Detect", "Checkpoint atau karakter tidak tersedia.", 4) end
        return false
    end
    local ok, err = pcall(function()
        character:PivotTo(part.CFrame * CFrame.new(0, 4, 0))
    end)
    if not ok and not quiet then
        Hub:Notify("Auto Detect", "Perpindahan gagal: " .. tostring(err), 4)
    end
    return ok
end

local function stopDetectLoop(showMessage)
    detectLoopRunning = false
    detectLoopPaused = false
    detectLoopToken += 1
    if showMessage then Hub:Notify("Auto Detect", "Auto Detect dihentikan.", 3) end
end

table.insert(Elements, {
    Type = "Section", Name = "AUTO DETECT CHECKPOINT", Tab = "TELEPORT",
})
table.insert(Elements, {
    Type = "Label", Name = "Cari Checkpoint, Pos Pemeriksaan, CP, Stage, dan Summit/Finish di Workspace.", Tab = "TELEPORT",
})
table.insert(Elements, {
    Type = "Button", Name = "SCAN CHECKPOINT MAP", Tab = "TELEPORT",
    Desc = "Pindai nama objek dan teks penanda checkpoint yang tersedia di map",
    Callback = function()
        local indexes, hasSummit, scanned = scanMapCheckpoints()
        local summary = {}
        for _, index in ipairs(indexes) do table.insert(summary, tostring(index)) end
        local detail = #indexes > 0 and table.concat(summary, ", ") or "Tidak ditemukan"
        Hub:Notify("Hasil Scan", "Checkpoint: " .. detail .. " | Summit: " .. (hasSummit and "ditemukan" or "tidak ditemukan") .. " | Objek diperiksa: " .. tostring(scanned), 7)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "START AUTO DETECT", Tab = "TELEPORT",
    Desc = "Pindai lalu coba menuju checkpoint terdeteksi secara berurutan sampai Summit atau checkpoint terakhir",
    Callback = function()
        if detectLoopRunning then
            Hub:Notify("Auto Detect", "Auto Detect sudah berjalan.", 3)
            return
        end
        local indexes, hasSummit = scanMapCheckpoints()
        -- Never jump straight to Summit when numbered checkpoints were not found.
        if #indexes == 0 then
            Hub:Notify("Auto Detect", hasSummit
                and "Hanya Summit/Finish yang terdeteksi. Checkpoint bernomor 1, 2, 3 belum ditemukan; proses dibatalkan agar tidak langsung lompat ke Summit."
                or "Belum menemukan checkpoint bernomor. Coba Scan setelah map selesai dimuat.", 7)
            return
        end
        -- Require a continuous sequence starting at checkpoint 1.
        for expected = 1, indexes[#indexes] do
            if not detectedCheckpoints[expected] then
                Hub:Notify("Auto Detect", "Urutan belum lengkap: checkpoint " .. tostring(expected) .. " tidak ditemukan. Summit tidak akan dituju.", 7)
                return
            end
        end
        detectLoopRunning = true
        detectLoopPaused = false
        detectLoopToken += 1
        local myToken = detectLoopToken
        Hub:Notify("Auto Detect", "Ditemukan " .. tostring(#indexes) .. " checkpoint. Memulai urutan otomatis.", 4)
        task.spawn(function()
            for _, index in ipairs(indexes) do
                if not Hub.Alive or not detectLoopRunning or detectLoopToken ~= myToken then break end
                while detectLoopPaused and detectLoopRunning and detectLoopToken == myToken do task.wait(0.1) end
                if not detectLoopRunning or detectLoopToken ~= myToken then break end
                local entry = detectedCheckpoints[index]
                if entry and not teleportToDetectedPart(entry.Part, true) then
                    stopDetectLoop(false)
                    Hub:Notify("Auto Detect", "Berhenti: checkpoint " .. tostring(index) .. " tidak bisa dijangkau.", 5)
                    return
                end
                task.wait(autoLoopDelay)
            end
            if detectLoopRunning and detectLoopToken == myToken and detectedSummit then
                while detectLoopPaused and detectLoopRunning and detectLoopToken == myToken do task.wait(0.1) end
                if detectLoopRunning and detectLoopToken == myToken then
                    teleportToDetectedPart(detectedSummit.Part, true)
                    task.wait(autoLoopDelay)
                end
            end
            if detectLoopRunning and detectLoopToken == myToken then
                stopDetectLoop(false)
                Hub:Notify("Auto Detect", "Urutan selesai. Jika posisi di-reset server, map membatasi perpindahan dari klien.", 5)
            end
        end)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "PAUSE AUTO DETECT", Tab = "TELEPORT",
    Desc = "Jeda urutan pendeteksian otomatis",
    Callback = function()
        if not detectLoopRunning then Hub:Notify("Auto Detect", "Auto Detect belum berjalan.", 3) return end
        detectLoopPaused = true
        Hub:Notify("Auto Detect", "Dijeda.", 3)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "RESUME AUTO DETECT", Tab = "TELEPORT",
    Desc = "Lanjutkan urutan pendeteksian otomatis",
    Callback = function()
        if not detectLoopRunning then Hub:Notify("Auto Detect", "Auto Detect belum berjalan.", 3) return end
        if not detectLoopPaused then Hub:Notify("Auto Detect", "Tidak sedang dijeda.", 3) return end
        detectLoopPaused = false
        Hub:Notify("Auto Detect", "Dilanjutkan.", 3)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "STOP AUTO DETECT", Tab = "TELEPORT",
    Desc = "Hentikan urutan pendeteksian otomatis",
    Callback = function()
        if not detectLoopRunning then Hub:Notify("Auto Detect", "Auto Detect sedang tidak berjalan.", 3) return end
        stopDetectLoop(true)
    end,
})

table.insert(Elements, {
    Type = "Section", Name = "Saved Checkpoints", Tab = "TELEPORT",
})
table.insert(Elements, {
    Type = "Label", Name = "Simpan posisi saat ini, lalu teleport kembali kapan saja selama masih di server yang sama.", Tab = "TELEPORT",
})
for checkpointIndex = 1, 25 do
    local index = checkpointIndex
    table.insert(Elements, {
        Type = "Button", Name = "Save Checkpoint " .. tostring(index), Tab = "TELEPORT",
        Desc = "Simpan posisi karakter saat ini sebagai titik " .. tostring(index),
        Callback = function() saveCheckpoint(index) end,
    })
    table.insert(Elements, {
        Type = "Button", Name = "Teleport to Checkpoint " .. tostring(index), Tab = "TELEPORT",
        Desc = "Kembali ke posisi tersimpan pada titik " .. tostring(index),
        Callback = function() teleportCheckpoint(index) end,
    })
end

-- [7B-Info] Player information for the currently selected player
-- Uses the same player selection as the teleport dropdown.
table.insert(Elements, {
    Type = "Button",
    Name = "Show Player Info",
    Tab = "Utility",
    Desc = "Shows the selected player's public in-session information",
    Callback = function()
        if not selectedTeleportUserId then
            Hub:Notify("Player Info", "Pilih pemain terlebih dahulu pada Select Player.", 4)
            return
        end

        local target
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == selectedTeleportUserId then
                target = player
                break
            end
        end
        if not target then
            Hub:Notify("Player Info", "Pemain tersebut sudah tidak ada di server.", 4)
            return
        end

        local character = target.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local health = humanoid and string.format("%.0f/%.0f", humanoid.Health, humanoid.MaxHealth) or "Tidak tersedia"
        local position = root and string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z) or "Tidak tersedia"
        local teamName = target.Team and target.Team.Name or "Tidak ada"
        local infoText = string.format(
            "Nama: %s\nUsername: @%s\nUser ID: %d\nUmur akun: %d hari\nTim: %s\nHealth: %s\nPosisi: %s",
            target.DisplayName, target.Name, target.UserId, target.AccountAge, teamName, health, position
        )
        Hub:Notify("Player Info", infoText, 8)
    end,
})

-- [7C] Private Server (requires matching server-side handler in ServerScriptService)
local privateServerCode = ""
local privateServerBusy = false

table.insert(Elements, {
    Type = "Textbox", Name = "Private Server Code", Tab = "Utility",
    Desc = "Masukkan kode akses server pribadi yang diberikan pemilik game",
    Placeholder = "Kode akses private server", FireOnLeave = true,
    Callback = function(value)
        privateServerCode = tostring(value or ""):gsub("%s+", "")
    end,
})

table.insert(Elements, {
    Type = "Button", Name = "Join Private Server", Tab = "Utility",
    Desc = "Meminta server game memindahkanmu ke private server",
    Callback = function()
        if privateServerBusy then return end
        local code = tostring(privateServerCode or ""):gsub("%s+", "")
        if code == "" then
            Hub:Notify("Private Server", "Masukkan kode akses terlebih dahulu.", 4)
            return
        end

        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("PiexxiePrivateServerRequest")
        if not remote or not remote:IsA("RemoteFunction") then
            Hub:Notify("Private Server", "Fitur ini belum diaktifkan oleh server game. Pasang handler server yang disertakan.", 6)
            return
        end

        privateServerBusy = true
        local ok, success, message = pcall(function()
            return remote:InvokeServer(code)
        end)
        privateServerBusy = false

        if not ok then
            Hub:Notify("Private Server", "Permintaan gagal: " .. tostring(success), 5)
        elseif not success then
            Hub:Notify("Private Server", tostring(message or "Kode ditolak oleh server."), 5)
        else
            Hub:Notify("Private Server", tostring(message or "Permintaan diterima."), 4)
        end
    end,
})


-- [7B-Avatar] Local visual copy of a player's current in-session appearance.
-- This intentionally avoids Humanoid:ApplyDescription(), which is server-only.
local selectedAvatarUserId = nil
local avatarOptions = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(avatarOptions, player.Name)
    end
end
if #avatarOptions == 0 then
    table.insert(avatarOptions, "No other players")
end

table.insert(Elements, {
    Type = "Section", Name = "Copy Avatar", Tab = "Utility",
})
table.insert(Elements, {
    Type = "Dropdown",
    Name = "Select Avatar Player",
    Tab = "Utility",
    Desc = "Pilih pemain yang avatarnya ingin kamu gunakan",
    Options = avatarOptions,
    Callback = function(playerName)
        local target = Players:FindFirstChild(playerName)
        selectedAvatarUserId = target and target.UserId or nil
    end,
})

table.insert(Elements, {
    Type = "Button",
    Name = "Apply Selected Avatar",
    Tab = "Utility",
    Desc = "Salin pakaian, warna tubuh, wajah, dan aksesori secara lokal",
    Callback = function()
        if not selectedAvatarUserId then
            Hub:Notify("Copy Avatar", "Pilih pemain terlebih dahulu.", 4)
            return
        end

        local target
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == selectedAvatarUserId then
                target = player
                break
            end
        end
        if not target then
            Hub:Notify("Copy Avatar", "Pemain tersebut sudah keluar dari server.", 4)
            return
        end

        local sourceCharacter = target.Character
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if not sourceCharacter or not character then
            Hub:Notify("Copy Avatar", "Karakter pemain belum siap. Coba lagi.", 4)
            return
        end
        local sourceHumanoid = sourceCharacter:FindFirstChildOfClass("Humanoid")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local sourceHead = sourceCharacter:FindFirstChild("Head")
        local head = character:FindFirstChild("Head")
        if not sourceHumanoid or not humanoid then
            Hub:Notify("Copy Avatar", "Humanoid belum siap. Coba lagi.", 4)
            return
        end

        local copied, failed = 0, 0
        local replaceClasses = {
            Shirt = true, Pants = true, ShirtGraphic = true,
            BodyColors = true, CharacterMesh = true,
        }
        local scaleNames = {
            "BodyDepthScale", "BodyHeightScale", "BodyWidthScale",
            "HeadScale", "BodyTypeScale", "BodyProportionScale",
        }

        -- Remove old local accessories and wearable appearance objects.
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") or replaceClasses[child.ClassName] then
                pcall(function() child:Destroy() end)
            end
        end

        -- Copy clothing, body colors, and classic character meshes.
        for _, child in ipairs(sourceCharacter:GetChildren()) do
            if replaceClasses[child.ClassName] then
                local ok = pcall(function()
                    local clone = child:Clone()
                    clone.Parent = character
                end)
                if ok then copied = copied + 1 else failed = failed + 1 end
            end
        end

        -- Copy body scale values when both rigs expose them.
        for _, scaleName in ipairs(scaleNames) do
            local sourceScale = sourceHumanoid:FindFirstChild(scaleName)
            local localScale = humanoid:FindFirstChild(scaleName)
            if sourceScale and localScale and sourceScale:IsA("NumberValue") and localScale:IsA("NumberValue") then
                pcall(function() localScale.Value = sourceScale.Value end)
            end
        end

        -- Replace the face decal without replacing the local head/rig.
        if sourceHead and head then
            for _, item in ipairs(head:GetChildren()) do
                if item:IsA("Decal") and item.Name == "face" then
                    pcall(function() item:Destroy() end)
                end
            end
            for _, item in ipairs(sourceHead:GetChildren()) do
                if item:IsA("Decal") and item.Name == "face" then
                    local ok = pcall(function()
                        local clone = item:Clone()
                        clone.Parent = head
                    end)
                    if ok then copied = copied + 1 else failed = failed + 1 end
                end
            end
        end

        -- Add accessories through the local Humanoid so attachments are rebuilt
        -- against this character rather than retaining welds to the source player.
        for _, accessory in ipairs(sourceCharacter:GetChildren()) do
            if accessory:IsA("Accessory") then
                local ok = pcall(function()
                    humanoid:AddAccessory(accessory:Clone())
                end)
                if ok then copied = copied + 1 else failed = failed + 1 end
            end
        end

        if copied > 0 then
            Hub:Notify("Copy Avatar", "Tampilan lokal disalin. Beberapa bentuk tubuh atau pakaian berlapis mungkin tidak sama persis.", 5)
        else
            Hub:Notify("Copy Avatar", "Tidak ada bagian avatar yang berhasil disalin. Pastikan karakter target sudah selesai dimuat.", 5)
        end
    end,
})

-- [8] By @piexxie03 (Label)
table.insert(Elements, {
	Type = "Label", Name = "By @piexxie03", Tab = "Fun",
})

Store.fovDiameter = Store.fovDiameter or 180
Store.aimRadius = Store.fovDiameter * 0.5



-- [AUTO WALK CONFIG ROUTE] Rute direkam sebagai koordinat sederhana agar bisa ikut tersimpan di config.
local autoWalkRoute = {}
local autoWalkRecording = false
local autoWalkPlaying = false
local autoWalkPaused = false
local autoWalkToken = 0
local autoWalkSampleDistance = 2.5

local function autoWalkGetCharacter()
    local character = LocalPlayer.Character
    if not character then return nil, nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return nil, nil end
    return humanoid, root
end

local function autoWalkStopPlayback()
    autoWalkPlaying = false
    autoWalkPaused = false
    autoWalkToken += 1
    local humanoid = autoWalkGetCharacter()
    if humanoid then pcall(function() humanoid:Move(Vector3.zero, false) end) end
end

table.insert(Elements, { Type = "Section", Name = "AUTO WALK RECORDER", Tab = "AUTO WALK" })
table.insert(Elements, {
    Type = "Label", Name = "Rekam perjalanan secara manual. Rute akan ikut tersimpan saat menekan SAVE CONFIG dan dipulihkan melalui LOAD CONFIG.", Tab = "AUTO WALK",
})
table.insert(Elements, {
    Type = "Button", Name = "START RECORDING", Tab = "AUTO WALK",
    Desc = "Rekam perjalanan dari posisi sekarang",
    Callback = function()
        if autoWalkRecording then
            Hub:Notify("AUTO WALK", "Perekaman sedang berjalan.", 3)
            return
        end
        if autoWalkPlaying then autoWalkStopPlayback() end
        local humanoid, root = autoWalkGetCharacter()
        if not humanoid or not root then
            Hub:Notify("AUTO WALK", "Karakter belum siap.", 3)
            return
        end
        autoWalkRoute = { { X = root.Position.X, Y = root.Position.Y, Z = root.Position.Z } }
        autoWalkRecording = true
        Hub:Notify("AUTO WALK", "Perekaman dimulai. Berjalanlah mengikuti rute.", 4)
        task.spawn(function()
            local lastPosition = root.Position
            while Hub.Alive and autoWalkRecording do
                task.wait(0.35)
                local _, currentRoot = autoWalkGetCharacter()
                if not currentRoot then
                    autoWalkRecording = false
                    Hub:Notify("AUTO WALK", "Perekaman berhenti karena karakter tidak tersedia.", 4)
                    break
                end
                local position = currentRoot.Position
                if (position - lastPosition).Magnitude >= autoWalkSampleDistance then
                    table.insert(autoWalkRoute, { X = position.X, Y = position.Y, Z = position.Z })
                    lastPosition = position
                end
            end
        end)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "STOP RECORDING", Tab = "AUTO WALK",
    Callback = function()
        if not autoWalkRecording then
            Hub:Notify("AUTO WALK", "Tidak ada perekaman aktif.", 3)
            return
        end
        autoWalkRecording = false
        local _, root = autoWalkGetCharacter()
        if root then
            local p = root.Position
            table.insert(autoWalkRoute, { X = p.X, Y = p.Y, Z = p.Z })
        end
        Hub:Notify("AUTO WALK", "Rute direkam: " .. tostring(#autoWalkRoute) .. " titik. Tekan SAVE CONFIG agar tersimpan permanen.", 5)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "PLAY ROUTE", Tab = "AUTO WALK",
    Desc = "Ikuti rute yang direkam atau dimuat dari config",
    Callback = function()
        if autoWalkRecording then
            Hub:Notify("AUTO WALK", "Hentikan perekaman dahulu.", 3)
            return
        end
        if autoWalkPlaying then
            Hub:Notify("AUTO WALK", "Rute sedang diputar.", 3)
            return
        end
        if #autoWalkRoute < 2 then
            Hub:Notify("AUTO WALK", "Belum ada rute. Rekam atau LOAD CONFIG dahulu.", 4)
            return
        end
        local humanoid, root = autoWalkGetCharacter()
        if not humanoid or not root then
            Hub:Notify("AUTO WALK", "Karakter belum siap.", 3)
            return
        end
        autoWalkPlaying = true
        autoWalkPaused = false
        autoWalkToken += 1
        local token = autoWalkToken
        Hub:Notify("AUTO WALK", "Memutar rute " .. tostring(#autoWalkRoute) .. " titik.", 4)
        task.spawn(function()
            for index = 2, #autoWalkRoute do
                while Hub.Alive and autoWalkPlaying and autoWalkToken == token and autoWalkPaused do task.wait(0.1) end
                if not Hub.Alive or not autoWalkPlaying or autoWalkToken ~= token then break end
                local currentHumanoid, currentRoot = autoWalkGetCharacter()
                if not currentHumanoid or not currentRoot then
                    autoWalkStopPlayback()
                    Hub:Notify("AUTO WALK", "Karakter tidak tersedia; rute dihentikan.", 4)
                    return
                end
                local point = autoWalkRoute[index]
                local destination = Vector3.new(point.X, point.Y, point.Z)
                currentHumanoid:MoveTo(destination)
                local started = os.clock()
                while Hub.Alive and autoWalkPlaying and autoWalkToken == token do
                    if autoWalkPaused then
                        currentHumanoid:Move(Vector3.zero, false)
                        while Hub.Alive and autoWalkPlaying and autoWalkToken == token and autoWalkPaused do task.wait(0.1) end
                        if not autoWalkPlaying or autoWalkToken ~= token then break end
                        currentHumanoid, currentRoot = autoWalkGetCharacter()
                        if not currentHumanoid or not currentRoot then break end
                        currentHumanoid:MoveTo(destination)
                        started = os.clock()
                    end
                    if (currentRoot.Position - destination).Magnitude <= 3 then break end
                    if os.clock() - started > 15 then
                        autoWalkStopPlayback()
                        Hub:Notify("AUTO WALK", "Titik " .. tostring(index) .. " tidak tercapai; rute dihentikan.", 4)
                        return
                    end
                    task.wait(0.12)
                    currentHumanoid, currentRoot = autoWalkGetCharacter()
                    if not currentHumanoid or not currentRoot then break end
                end
            end
            if autoWalkPlaying and autoWalkToken == token then
                autoWalkPlaying = false
                autoWalkPaused = false
                Hub:Notify("AUTO WALK", "Rute selesai.", 4)
            end
        end)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "PAUSE / RESUME", Tab = "AUTO WALK",
    Callback = function()
        if not autoWalkPlaying then
            Hub:Notify("AUTO WALK", "Tidak ada rute yang diputar.", 3)
            return
        end
        autoWalkPaused = not autoWalkPaused
        Hub:Notify("AUTO WALK", autoWalkPaused and "Rute dijeda." or "Rute dilanjutkan.", 3)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "STOP PLAYBACK", Tab = "AUTO WALK",
    Callback = function()
        if not autoWalkPlaying then
            Hub:Notify("AUTO WALK", "Tidak ada pemutaran aktif.", 3)
            return
        end
        autoWalkStopPlayback()
        Hub:Notify("AUTO WALK", "Pemutaran dihentikan.", 3)
    end,
})
table.insert(Elements, {
    Type = "Button", Name = "CLEAR ROUTE", Tab = "AUTO WALK",
    Callback = function()
        if autoWalkRecording or autoWalkPlaying then
            Hub:Notify("AUTO WALK", "Hentikan rekaman/pemutaran dahulu.", 3)
            return
        end
        autoWalkRoute = {}
        Hub:Notify("AUTO WALK", "Rute di memori dihapus. Simpan config untuk memperbarui file config.", 4)
    end,
})


-- [FULL CONFIG] Explicitly save/load every supported hub setting and all 25 checkpoints.
-- Requires executor file APIs: writefile, readfile, and (optionally) makefolder/isfile/isfolder.
local FULL_CONFIG_FOLDER = "Piexxie03Hub/Configs"
local selectedFullConfigName = "Map1"

local function getFullConfigPath()
    local rawName = tostring(selectedFullConfigName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if rawName == "" then return nil, "Isi nama config terlebih dahulu." end
    -- Keep filenames portable and prevent path traversal or nested folders.
    local safeName = rawName:gsub("[^%w_%- ]", ""):gsub("%s+", "_"):sub(1, 32)
    if safeName == "" then return nil, "Nama config tidak valid." end
    return FULL_CONFIG_FOLDER .. "/" .. safeName .. ".json", safeName
end

local function colorToHex(color)
    if typeof(color) ~= "Color3" then return nil end
    local r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255)
    local g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255)
    local b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
    return string.format("#%02x%02x%02x", r, g, b)
end

local function fullConfigAvailable()
    return type(writefile) == "function" and type(readfile) == "function"
end

local function saveFullConfig()
    if not fullConfigAvailable() then
        Hub:Notify("SAVE CONFIG", "Executor ini tidak mendukung penyimpanan file (writefile/readfile).", 5)
        return
    end

    local configPath, safeName = getFullConfigPath()
    if not configPath then
        Hub:Notify("SAVE CONFIG", safeName, 4)
        return
    end

    local data = {
        Version = 1,
        ConfigName = safeName,
        Flags = {},
        Checkpoints = {},
        AutoWalkRoute = autoWalkRoute,
        AutoLoopDelay = autoLoopDelay,
        Theme = {},
        MenuScale = Hub.UserScale or 1,
        ToggleKey = Hub.ToggleKey or Config.ToggleKey or "RightShift",
    }

    -- Capture every serializable toggle, slider, dropdown, textbox, and keybind value.
    for name, value in pairs(Hub.Flags or {}) do
        local valueType = type(value)
        if valueType == "boolean" or valueType == "number" or valueType == "string" then
            data.Flags[name] = value
        end
    end

    -- Store complete CFrame components, not Roblox userdata.
    for index = 1, 25 do
        local cf = savedCheckpoints[index]
        if typeof(cf) == "CFrame" then
            data.Checkpoints[tostring(index)] = { cf:GetComponents() }
        end
    end

    for key, value in pairs(Hub.T or {}) do
        local hex = colorToHex(value)
        if hex then data.Theme[key] = hex end
    end

    local ok, err = pcall(function()
        if type(makefolder) == "function" then
            local rootExists, configFolderExists = false, false
            if type(isfolder) == "function" then
                pcall(function() rootExists = isfolder("Piexxie03Hub") end)
                pcall(function() configFolderExists = isfolder(FULL_CONFIG_FOLDER) end)
            end
            if not rootExists then pcall(makefolder, "Piexxie03Hub") end
            if not configFolderExists then pcall(makefolder, FULL_CONFIG_FOLDER) end
        end
        writefile(configPath, HttpService:JSONEncode(data))
    end)

    if ok then
        Hub:Notify("SAVE CONFIG", "Config '" .. safeName .. "' tersimpan. Config map lain tidak tertimpa.", 4)
    else
        Hub:Notify("SAVE CONFIG", "Gagal menyimpan: " .. tostring(err), 5)
    end
end

local function loadFullConfig()
    if not fullConfigAvailable() then
        Hub:Notify("LOAD CONFIG", "Executor ini tidak mendukung pembacaan file (readfile).", 5)
        return
    end

    local configPath, safeName = getFullConfigPath()
    if not configPath then
        Hub:Notify("LOAD CONFIG", safeName, 4)
        return
    end

    local raw
    local readOK, readErr = pcall(function()
        if type(isfile) == "function" and not isfile(configPath) then
            error("Config '" .. safeName .. "' belum ada. Isi nama yang benar atau simpan dahulu.")
        end
        raw = readfile(configPath)
    end)
    if not readOK then
        Hub:Notify("LOAD CONFIG", tostring(readErr), 5)
        return
    end

    local decoded
    local decodeOK, decodeErr = pcall(function()
        decoded = HttpService:JSONDecode(raw)
        assert(type(decoded) == "table", "Format config tidak valid.")
    end)
    if not decodeOK then
        Hub:Notify("LOAD CONFIG", "Config tidak dapat dibaca: " .. tostring(decodeErr), 5)
        return
    end

    local restored = 0
    if tonumber(decoded.MenuScale) then
        pcall(function() Hub:SetMenuSize(tonumber(decoded.MenuScale), true) end)
        restored += 1
    end

    if type(decoded.ToggleKey) == "string" and decoded.ToggleKey ~= "" then
        Hub.ToggleKey = decoded.ToggleKey
        Config.ToggleKey = decoded.ToggleKey
        restored += 1
    end

    if type(decoded.Flags) == "table" then
        for name, value in pairs(decoded.Flags) do
            local setter = Hub.Setters and Hub.Setters[name]
            if setter then
                local ok = pcall(function()
                    -- Calling the normal setter restores the value and applies its feature callback.
                    setter(value)
                end)
                if ok then restored += 1 end
            end
        end
    end

    if tonumber(decoded.AutoLoopDelay) then
        autoLoopDelay = math.clamp(math.floor(tonumber(decoded.AutoLoopDelay)), 1, 10)
        local delaySetter = Hub.Setters and Hub.Setters["Delay Auto Loop"]
        if delaySetter then pcall(function() delaySetter(autoLoopDelay) end) end
        restored += 1
    end

    -- Apply the exact saved palette last so a saved preset dropdown cannot overwrite it.
    if type(decoded.Theme) == "table" then
        pcall(function() Hub:ApplyTheme(decoded.Theme) end)
        restored += 1
    end

    if type(decoded.AutoWalkRoute) == "table" then
        local restoredRoute = {}
        for _, point in ipairs(decoded.AutoWalkRoute) do
            if type(point) == "table" and tonumber(point.X) and tonumber(point.Y) and tonumber(point.Z) then
                table.insert(restoredRoute, {
                    X = tonumber(point.X),
                    Y = tonumber(point.Y),
                    Z = tonumber(point.Z),
                })
            end
        end
        if #restoredRoute >= 2 then
            autoWalkRoute = restoredRoute
            restored += 1
        end
    end

    if type(decoded.Checkpoints) == "table" then
        for index = 1, 25 do
            local components = decoded.Checkpoints[tostring(index)]
            if type(components) == "table" and #components == 12 then
                local valid = true
                for _, component in ipairs(components) do
                    if type(component) ~= "number" then valid = false break end
                end
                if valid then
                    local ok, cf = pcall(function() return CFrame.new(table.unpack(components)) end)
                    if ok and typeof(cf) == "CFrame" then
                        savedCheckpoints[index] = cf
                        restored += 1
                    end
                end
            end
        end
    end

    Hub:Notify("LOAD CONFIG", "Config '" .. safeName .. "' dimuat. Pengaturan, checkpoint, dan rute valid dipulihkan: " .. tostring(restored) .. ".", 5)
end

local function listFullConfigs()
    if type(listfiles) ~= "function" then
        Hub:Notify("DAFTAR CONFIG", "Executor tidak mendukung listfiles. Isi nama config secara manual.", 5)
        return
    end

    local ok, files = pcall(function() return listfiles(FULL_CONFIG_FOLDER) end)
    if not ok or type(files) ~= "table" then
        Hub:Notify("DAFTAR CONFIG", "Folder config belum ada atau belum bisa dibaca. Simpan config terlebih dahulu.", 4)
        return
    end

    local names = {}
    for _, path in ipairs(files) do
        local name = tostring(path):match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    table.sort(names)

    if #names == 0 then
        Hub:Notify("DAFTAR CONFIG", "Belum ada config tersimpan.", 4)
    else
        Hub:Notify("DAFTAR CONFIG", table.concat(names, "  |  "), 8)
    end
end

local function resetFullConfig()
    local configPath, safeName = getFullConfigPath()
    if not configPath then
        Hub:Notify("RESET CONFIG", safeName, 4)
        return
    end
    if type(delfile) ~= "function" then
        Hub:Notify("RESET CONFIG", "Executor tidak menyediakan delfile. Hapus file " .. configPath .. " secara manual.", 5)
        return
    end
    local ok, err = pcall(function()
        if type(isfile) ~= "function" or isfile(configPath) then
            delfile(configPath)
        end
    end)
    if ok then
        Hub:Notify("RESET CONFIG", "Config '" .. safeName .. "' dihapus. Config map lain tetap aman.", 4)
    else
        Hub:Notify("RESET CONFIG", "Gagal menghapus config: " .. tostring(err), 5)
    end
end

table.insert(Elements, {
    Type = "Section", Name = "FULL HUB CONFIG", Tab = "Utility",
})
table.insert(Elements, {
    Type = "Label", Name = "Simpan banyak config per map. Save dengan nama yang sama menimpa config tersebut; Load memulihkan pengaturan, checkpoint, dan rute Auto Walk.", Tab = "Utility",
})
table.insert(Elements, {
    Type = "Textbox", Name = "Nama Config", Tab = "Utility",
    Desc = "Masukkan nama map/preset, contoh: Map1, Brookhaven, atau Obby",
    Placeholder = "Nama config...", Default = "Map1", FireOnLeave = true,
    Callback = function(value) selectedFullConfigName = tostring(value or "") end,
})
table.insert(Elements, {
    Type = "Button", Name = "SAVE CONFIG", Tab = "Utility",
    Desc = "Simpan pengaturan, checkpoint, dan rute Auto Walk dengan nama yang diisi",
    Callback = saveFullConfig,
})
table.insert(Elements, {
    Type = "Button", Name = "LOAD CONFIG", Tab = "Utility",
    Desc = "Muat pengaturan, checkpoint, dan rute sesuai nama pada kolom Nama Config",
    Callback = loadFullConfig,
})
table.insert(Elements, {
    Type = "Button", Name = "LIST SAVED CONFIGS", Tab = "Utility",
    Desc = "Tampilkan nama semua config yang tersimpan di executor",
    Callback = listFullConfigs,
})
table.insert(Elements, {
    Type = "Button", Name = "RESET CONFIG", Tab = "Utility",
    Desc = "Hapus hanya config dengan nama yang sedang diisi",
    Callback = resetFullConfig,
})


Hub:Build(Elements, { "Movement", "Visual", "TELEPORT", "AUTO WALK", "Utility", "Fun" })
return Hub