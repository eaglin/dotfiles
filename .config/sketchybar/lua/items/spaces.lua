-- lua/items/spaces.lua - workspace indicators (left)
--
-- Pattern from pyrorhythm/dotconfig: ONE invisible watcher item receives
-- all yabai events. When ANY relevant event fires, a single async refresh
-- is queued. Avoids the 9-callbacks-per-event trap of subscribing each
-- space item individually.
--
-- Flow:
--   1. event arrives → `refresh()` called once
--   2. `Yabai.query.layout(cb)` chains two async `Sbar.exec` calls (spaces,
--      then windows). Neither blocks the event_loop.
--   3. callback receives the parsed layout table (sketchybar parses stdout
--      JSON automatically) and repaints only changed items.

local colors   = require("colors")
local Yabai    = require("yabaiapi")
local icons    = require("icons")

Yabai.attach(Sbar)
Yabai.register_events()

local MAX_WS = 9

local slots = {}

local function name_num(i)    return "space." .. i end
local function name_brk(i)    return "space.bracket." .. i end

local function make_num(i)
    local item = Sbar.add("space", name_num(i), {
        associated_space = i,
        icon = { drawing = false },
        label = tostring(i),
        label = {
            font            = "JetBrainsMono Nerd Font:Bold:14.0",
            color           = colors.OVERLAY0,
            highlight_color = colors.IRIS,
            padding_right   = 6,
            padding_left    = 6,
            y_offset        = 1,
        },
        padding_left  = 6,
        padding_right = 6,
        background = {
            drawing          = "on",
            color            = colors.HIGHLIGHT_MED,
            corner_radius    = 14,
            height           = 18,
            border_width     = 0,
            border_color     = colors.SURFACE,
        },
    })

    item:set({ click_script = "yabai -m space --focus " .. i })
    return item
end

local function paint_space(i, entry)
    local slot = slots[i]
    if not slot or not entry then return end

    if entry.has_focus then
        slot.num:set({
            background = { drawing = "on", color = colors.IRIS },
            label      = { color = colors.BASE },
        })
    elseif #entry.apps == 0 then
        slot.num:set({
            background = { drawing = "on", color = colors.HIGHLIGHT_MED },
            label      = { color = colors.OVERLAY0 },
        })
    else
        slot.num:set({
            background = {
                drawing      = "on",
                color        = colors.HIGHLIGHT_MED,
                border_color = colors.OVERLAY0,
                border_width = 0,
            },
            label = { color = colors.IRIS },
        })
    end
end

local function refresh()
    Yabai.query.layout(function(layout, err)
        if err then
            io.write("[spaces] " .. tostring(err) .. "\n")
            return
        end
        if not layout then return end

        for i = 1, MAX_WS do
            paint_space(i, layout[i])
        end
    end)
end

-- Build all space items up front
for i = 1, MAX_WS do
    slots[i] = { num = make_num(i) }
end

-- Single invisible watcher subscribed to all layout-affecting events.
-- Sketchybar fires ONE callback per event arrival regardless of how many
-- events we listed — not one per event per item.
local watcher = Sbar.add("item", "yabai.watcher", {
    drawing       = false,
    padding_left  = 0,
    padding_right = 0,
})

local layout_events = { unpack(Yabai.events.for_layout_refresh) }
table.insert(layout_events, "space_change")
table.insert(layout_events, "yabai_space_change")
table.insert(layout_events, "system_woke")
table.insert(layout_events, "forced")

watcher:subscribe(layout_events, function(_) refresh() end)

-- Initial paint deferred slightly so yabai's first query has time to return.
Sbar.delay(0.2, refresh)