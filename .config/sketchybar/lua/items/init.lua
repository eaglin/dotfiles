require("items.spaces")
require("items.yabai")
require("items.clock")
require("items.battery")
require("items.wifi")
require("items.volume")
require("items.system_data")

-- Bracket for status icons
Sbar.add("bracket", "status", { "wifi", "volume", "battery" }, {
    background = {
        drawing      = "on",
        color        = colors.OVERLAY,
        corner_radius = 6,
        height       = 24,
    },
})