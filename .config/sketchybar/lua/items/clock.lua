-- lua/items/clock.lua - right item, label=HH:MM:SS, refresh every 10s

local colors = require("colors")

local function paint()
    Sbar.exec("date '+%H:%M:%S'", function(result)
        if type(result) ~= "string" then return end
        local trimmed = (result:gsub("[\r\n%s]+", ""))
        Sbar.set("clock", {
            label = { string = trimmed, color = colors.TEXT },
        })
    end)
end

Sbar.add("item", "clock", {
    position = "right",
    icon = { drawing = false },
    label = {
        font          = "JetBrainsMono Nerd Font:Bold:13.0",
        color         = colors.TEXT,
        padding_right = 10,
    },
    padding_left = 4,
})

local function loop()
    paint()
    Sbar.delay(10, loop)
end
Sbar.delay(0.5, loop)