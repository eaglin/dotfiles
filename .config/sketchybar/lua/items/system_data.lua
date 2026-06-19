-- lua/items/system_data.lua - cpu/ram/disk inline

local colors = require("colors")
local icons  = require("icons")

local function cpu_pct()
    local handle = io.popen("ps -A -o %cpu | awk 'NR>1 {sum+=$1} END {printf \"%d\", sum}'")
    if not handle then return 0 end
    local out = handle:read("*a") or "0"
    handle:close()
    return tonumber(out:gsub("%s+$", "")) or 0
end

local function mem_pct()
    local handle = io.popen(
        "vm_stat | awk '/free/ {free=$3} /active/ {active=$2} /inactive/ {inactive=$2} /wired/ {wired=$4} "
        .. "END {printf \"%d\", (active+inactive+wired) * 100 / (active+inactive+wired+free)}'"
    )
    if not handle then return 0 end
    local out = handle:read("*a") or "0"
    handle:close()
    return tonumber(out:gsub("%s+$", "")) or 0
end

local function disk_pct()
    local handle = io.popen("df -h / | awk 'NR==2 {sub(\"%\",\"\",$5); print $5}'")
    if not handle then return 0 end
    local out = handle:read("*a") or "0"
    handle:close()
    return tonumber(out:gsub("%s+$", "")) or 0
end

local function paint()
    local cpu = cpu_pct()
    local mem = mem_pct()
    local disk = disk_pct()
    -- Debug: stash values into a global so we can --query them
    _G.__DEBUG_SYS_DATA = string.format("cpu=%s mem=%s disk=%s", cpu, mem, disk)
    Sbar.set("sys.cpu", { icon = { string = icons.CPU, color = colors.PINE } })
    Sbar.set("sys.cpu", { label = { string = cpu .. "%", color = colors.TEXT } })
    Sbar.set("sys.ram", { icon = { string = icons.MEMORY, color = colors.FOAM } })
    Sbar.set("sys.ram", { label = { string = mem .. "%", color = colors.TEXT } })
    Sbar.set("sys.disk", { icon = { string = icons.DISK, color = colors.GOLD } })
    Sbar.set("sys.disk", { label = { string = disk .. "%", color = colors.TEXT } })
end

local function make(id, icon_color)
    return Sbar.add("item", id, {
        position = "right",
        icon = {
            font  = "JetBrainsMono Nerd Font:Bold:14.0",
            color = icon_color,
            padding_right = 2,
        },
        label = {
            font  = "JetBrainsMono Nerd Font:Bold:13.0",
            color = colors.TEXT,
        },
    })
end

make("sys.cpu",  colors.PINE)
make("sys.ram",  colors.FOAM)
make("sys.disk", colors.GOLD)

-- Debug item: minimal
local debug_item = Sbar.add("item", "debug.sys", {
    position = "right",
})
debug_item:set({ label = { string = "INITIAL" } })

local function loop()
    paint()
    Sbar.set("debug.sys", { label = { string = "STATIC TEST 123" } })
    Sbar.delay(60, loop)
end
Sbar.delay(0.5, loop)