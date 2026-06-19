-- lua/items/yabai.lua - center item showing current layout (bsp/stack/float)

local colors = require("colors")

local LAYOUT_ICONS = {
    bsp   = "󰝘",
    stack = "󰌡",
    float = "󰈓",
}

local LAYOUT_NEXT = {
    bsp   = "stack",
    stack = "float",
    float = "bsp",
}

local function cycle_layout()
    Sbar.exec("yabai -m query --spaces --space | jq -r '.type'", function(result)
        if type(result) ~= "string" then return end
        local current = result
        local next_layout = LAYOUT_NEXT[current] or "bsp"
        Sbar.exec("yabai -m space --layout " .. next_layout)
    end)
end

local function refresh()
    Sbar.exec("yabai -m query --spaces --space", function(space)
        if type(space) ~= "table" then return end
        local t = space.type or "bsp"
        local icon = LAYOUT_ICONS[t] or LAYOUT_ICONS.bsp
        Sbar.set("yabai", { icon = { string = icon } })
        Sbar.set("yabai", { icon = { color = colors.TEXT } })
    end)
end

local item = Sbar.add("item", "yabai", {
    position      = "center",
    icon = {
        font          = "JetBrainsMono Nerd Font:Bold:18.0",
        color         = colors.TEXT,
        padding_left  = 10,
        padding_right = 10,
    },
    label = { drawing = false },
})

item:set({ icon = LAYOUT_ICONS.bsp })
item:set({ click_script = "sketchybar --trigger yabai_layout_change" })

-- Local event (triggered by click_script above); yabai also emits space_change
-- when layout switches because focus changes.
local watcher = Sbar.add("item", "yabai.layout_watcher", {
    drawing = false,
})
watcher:subscribe({
    "yabai_layout_change",
    "space_change",
    "system_woke",
}, function(_) refresh() end)

Sbar.delay(0.3, refresh)