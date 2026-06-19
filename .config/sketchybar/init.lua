-- init.lua - SketchyBar entry point using SbarLua (LuaJIT)
-- Pattern from pyrorhythm/dotconfig: auto-install SbarLua + rift.lua bindings
-- if not present, then batch all setup with begin/end_config.

os.execute("[ ! -d $HOME/.local/share/sketchybar_lua/ ] && (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)")

local HOME = os.getenv("HOME")
package.path = (package.path or "")
    .. ";" .. HOME .. "/.config/sketchybar/?.lua"
    .. ";" .. HOME .. "/.config/sketchybar/?/init.lua"
    .. ";" .. HOME .. "/.config/sketchybar/lua/?.lua"
    .. ";" .. HOME .. "/.config/sketchybar/lua/?/init.lua"
package.cpath = package.cpath
    .. ";" .. HOME .. "/.local/share/sketchybar_lua/?.so"

Sbar = require("sketchybar")
Sbar.set_bar_name("sketchybar")

Sbar.begin_config()
Sbar.hotload(true)

require("helpers.utils")  -- assigns globals: IS_SYSTEM_SLEEPING, POPUP_TOGGLE, etc.
colors = require("colors")
require("bar")
require("default")
require("items")

Sbar.end_config()
Sbar.event_loop()