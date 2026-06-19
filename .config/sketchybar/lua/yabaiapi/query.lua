return function(Y)
    Y.query = {}

    function Y.query.spaces(cb)   Y.cli("query --spaces",   cb) end
    function Y.query.windows(cb)  Y.cli("query --windows",  cb) end
    function Y.query.displays(cb) Y.cli("query --displays", cb) end

    function Y.query.is_real_window(w)
        if not w then return false end
        if w["is-minimized"] then return false end
        if w["subrole"] and w["subrole"] ~= "AXStandardWindow" then return false end
        if not w.space or w.space < 1 then return false end
        return true
    end

    function Y.query.real_windows(cb)
        Y.query.windows(function(wins, err)
            if not wins then return cb(nil, err) end
            local out = {}
            for _, w in ipairs(wins) do
                if Y.query.is_real_window(w) then
                    table.insert(out, { space = w.space, app = w.app, id = w.id })
                end
            end
            table.sort(out, function(a, b)
                if a.space ~= b.space then return a.space < b.space end
                return a.id < b.id
            end)
            cb(out)
        end)
    end

    function Y.query.layout(cb)
        Y.query.spaces(function(spaces, serr)
            if not spaces then return cb(nil, serr) end
            Y.query.real_windows(function(wins, werr)
                if not wins then return cb(nil, werr) end
                local layout = {}
                for _, s in ipairs(spaces) do
                    layout[s.index] = { has_focus = s["has-focus"] == true, apps = {} }
                end
                for _, w in ipairs(wins) do
                    local slot = layout[w.space]
                    if slot then table.insert(slot.apps, w.app) end
                end
                cb(layout)
            end)
        end)
    end
end