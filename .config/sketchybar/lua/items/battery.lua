-- lua/items/battery.lua - right item, charge % icon + label

local colors = require("colors")
local icons  = require("icons")

local ICONS = {
    [100] = icons.BATTERY_100,
    [75]  = icons.BATTERY_75,
    [50]  = icons.BATTERY_50,
    [25]  = icons.BATTERY_25,
    [0]   = icons.BATTERY_0,
}

local function pick_icon(pct, charging)
    if charging then return icons.BATTERY_CHARGING end
    if pct >= 90 then return ICONS[100] end
    if pct >= 60 then return ICONS[75] end
    if pct >= 35 then return ICONS[50] end
    if pct >= 15 then return ICONS[25] end
    return ICONS[0]
end

local function paint()
    Sbar.exec("pmset -g batt", function(result)
        if type(result) ~= "string" then return end
        local pct = tonumber(result:match("(%d+)%%")) or 0
        local charging = result:find("AC Power") ~= nil
        Sbar.set("battery", {
            icon = { string = pick_icon(pct, charging), color = colors.TEXT },
            label = {
                string = (charging and "⚡ " or "") .. pct .. "%",
                color  = colors.TEXT,
            },
        })
    end)
end

Sbar.add("item", "battery", {
    position = "right",
    label = { font = "JetBrainsMono Nerd Font:Bold:13.0" },
})

local watcher = Sbar.add("item", "battery.watcher", { drawing = false })
watcher:subscribe({ "power_source_change", "system_woke", "forced" }, function(_) paint() end)
Sbar.delay(0.5, paint)