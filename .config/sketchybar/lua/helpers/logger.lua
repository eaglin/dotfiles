local M = {}

local LEVELS = { trace = 0, debug = 1, info = 2, warn = 3, error = 4 }
local CURRENT = LEVELS.info

local function fmt(scope, fn, msg)
    if type(msg) == "table" then
        local parts = {}
        for k, v in pairs(msg) do
            table.insert(parts, tostring(k) .. "=" .. tostring(v))
        end
        return string.format("[%s][%s] %s | %s", os.date("%H:%M:%S"), scope, fn, table.concat(parts, ", "))
    end
    return string.format("[%s][%s] %s | %s", os.date("%H:%M:%S"), scope, fn, tostring(msg))
end

local function log(level, scope, fn, msg)
    if LEVELS[level] < CURRENT then return end
    io.write(fmt(scope, fn, msg) .. "\n")
    io.flush()
end

M.trace = function(s, f, m) log("trace", s, f, m) end
M.debug = function(s, f, m) log("debug", s, f, m) end
M.info  = function(s, f, m) log("info",  s, f, m) end
M.warn  = function(s, f, m) log("warn",  s, f, m) end
M.error = function(s, f, m) log("error", s, f, m) end

return M