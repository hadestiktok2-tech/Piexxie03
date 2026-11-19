-- Piexxie03HubV5 UI-only patch
-- Insert this block inside Util.LoadLibrary(url), after the source download
-- validation succeeds and immediately BEFORE: local chunk, compileErr = loadstring(source)
-- This changes only the UI library's theme/branding identifiers.

local piexxieTheme = [[
Themes.Piexxie = Palette({
    Backdrop = "101018",
    BackdropAlt = "171720",
    Topbar = "101018",
    Sidebar = "14141C",
    SidebarAlt = "1A1A24",
    SidebarText = "F5F5F7",
    SidebarMuted = "92929F",
    TabActive = "FF1E3C",
    TabActiveText = "FFFFFF",
    Panel = "111118",
    PanelHeader = "191922",
    Element = "1C1C26",
    Hover = "282832",
    Outline = "08080D",
    Shadow = "050508",
    Text = "F5F5F7",
    SubText = "B6B6C2",
    Muted = "777783",
    Track = "33333E",
    Accent = "FF1E3C",
    AccentDark = "C91630",
    Grass = "FF465F",
    GrassDark = "C91630",
    Brick = "292933",
    BrickDark = "15151D",
    Decor = { "Stars", "✦", "FF1E3C" },
    Particle = { "✦", false, "FF465F" },
})
table.insert(Themes.Order, 1, "Piexxie")
]]

local inserted = source:gsub("local State = {", piexxieTheme .. "\nlocal State = {", 1)
if inserted == source then
    warn("[Piexxie03HubV5] Theme insertion point not found; original UI source kept.")
else
    source = inserted
    source = source:gsub('ThemeName = "Overworld"', 'ThemeName = "Piexxie"', 1)
    source = source:gsub('Text = "M",', 'Text = "☠",', 1)
    source = source:gsub('GuiAttribute = "MarioHubUI"', 'GuiAttribute = "Piexxie03HubV5"', 1)
    source = source:gsub('Root = "mariohub"', 'Root = "piexxiehub"', 1)
end
