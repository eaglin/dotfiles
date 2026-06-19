-- lua/items/volume.lua - right item, volume icon + percentage

local colors = require("colors")

local function paint()
    Sbar.exec("osascript -e 'output volume of (get volume settings)'", function(result)
        local vol = tonumber(result) or 0
        local icon_color = vol == 0 and colors.MUTED or colors.PINE
        local icon_glyph = (vol == 0) and "󰖁" or (vol < 33) and "󰕿" or (vol < 66) and "󰖀" or "󰕾"
        Sbar.set("volume", { icon = { string = icon_glyph } })
        Sbar.set("volume", { icon = { color = icon_color } })
        Sbar.set("volume", { label = { string = vol .. "%" } })
        Sbar.set("volume", { label = { color = colors.TEXT } })
    end)
end

local item = Sbar.add("item", "volume", {
    position = "right",
    icon = {
        font  = "JetBrainsMono Nerd Font:Bold:14.0",
        color = colors.PINE,
    },
    label = {
        font  = "JetBrainsMono Nerd Font:Bold:13.0",
        color = colors.TEXT,
    },
})

local watcher = Sbar.add("item", "volume.watcher", { drawing = false })
watcher:subscribe({ "volume_change", "system_woke", "forced" }, function(env)
    local vol = tonumber(env.INFO)
    if vol then
        local icon_color = vol == 0 and colors.MUTED or colors.PINE
        local icon_glyph = (vol == 0) and "󰖁" or (vol < 33) and "󰕿" or (vol < 66) and "󰖀" or "󰕾"
        item:set({ icon = { string = icon_glyph } })
        item:set({ icon = { color = icon_color } })
        item:set({ label = { string = vol .. "%" } })
        item:set({ label = { color = colors.TEXT } })
    end
end)
Sbar.delay(0.5, paint)