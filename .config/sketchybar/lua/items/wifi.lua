-- lua/items/wifi.lua - right item, icon + SSID label
-- Subscribes to wifi_change (sketchybar native event) and ip_address popup on click.

local colors = require("colors")
local icons  = require("icons")

local function paint()
    Sbar.exec("networksetup -getairportnetwork en0 | awk -F': ' '{print $2}'", function(result)
        if type(result) ~= "string" then return end
        local current = (result:gsub("%s+$", ""))
        local offline = (current == "" or current:find("not associated"))
        local icon_glyph = offline and icons.WIFI_OFFLINE or icons.WIFI_CONNECTED
        local icon_color = offline and colors.MUTED or colors.PINE
        local label_text = offline and "Offline" or current
        Sbar.set("wifi", { icon = { string = icon_glyph } })
        Sbar.set("wifi", { icon = { color = icon_color } })
        Sbar.set("wifi", { label = { string = label_text } })
        Sbar.set("wifi", { label = { color = colors.TEXT } })
        Sbar.set("wifi.ssid", { label = { string = label_text } })
    end)
end

local wifi_item = Sbar.add("item", "wifi", {
    position = "right",
    icon = {
        font = "JetBrainsMono Nerd Font:Bold:14.0",
        color = colors.PINE,
    },
    label = {
        font = "JetBrainsMono Nerd Font:Bold:13.0",
        color = colors.TEXT,
    },
})

wifi_item:subscribe("mouse.clicked", function()
    POPUP_TOGGLE("wifi")
end)

Sbar.add("item", "wifi.ssid", {
    position = "popup.wifi",
    drawing = false,
    icon = { drawing = false },
    label = { font = "JetBrainsMono Nerd Font:Bold:13.0" },
})

Sbar.add("item", "wifi.ip", {
    position = "popup.wifi",
    drawing = false,
    icon = { string = icons.ETHERNET, color = colors.PINE },
    label = { font = "JetBrainsMono Nerd Font:Bold:13.0" },
})

local watcher = Sbar.add("item", "wifi.watcher", { drawing = false })
watcher:subscribe({ "wifi_change", "system_woke", "forced" }, function(_) paint() end)

Sbar.delay(0.5, paint)