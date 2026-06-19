local function ev(name) return "yabai_" .. name end

local E = {
    application_launched       = ev("application_launched"),
    application_terminated     = ev("application_terminated"),
    application_front_switched = ev("application_front_switched"),
    application_activated      = ev("application_activated"),
    application_deactivated    = ev("application_deactivated"),
    application_visible        = ev("application_visible"),
    application_hidden         = ev("application_hidden"),
    window_created             = ev("window_created"),
    window_destroyed           = ev("window_destroyed"),
    window_focused             = ev("window_focused"),
    window_moved               = ev("window_moved"),
    window_resized             = ev("window_resized"),
    window_minimized           = ev("window_minimized"),
    window_deminimized         = ev("window_deminimized"),
    window_title_changed       = ev("window_title_changed"),
    space_created              = ev("space_created"),
    space_destroyed            = ev("space_destroyed"),
    space_changed              = ev("space_changed"),
    display_added              = ev("display_added"),
    display_removed            = ev("display_removed"),
    display_moved              = ev("display_moved"),
    display_resized            = ev("display_resized"),
    display_changed            = ev("display_changed"),
    mission_control_enter      = ev("mission_control_enter"),
    mission_control_exit       = ev("mission_control_exit"),
    dock_did_change_pref       = ev("dock_did_change_pref"),
    dock_did_restart           = ev("dock_did_restart"),
    menu_bar_hidden_changed    = ev("menu_bar_hidden_changed"),
}

E.all = {}
for _, v in pairs(E) do
    if type(v) == "string" then table.insert(E.all, v) end
end
table.sort(E.all)

E.for_layout_refresh = {
    E.application_launched,
    E.application_terminated,
    E.application_visible,
    E.application_hidden,
    E.window_created,
    E.window_destroyed,
    E.window_moved,
    E.window_minimized,
    E.window_deminimized,
    E.space_created,
    E.space_destroyed,
}

E.for_focus = {
    E.window_focused,
    E.application_front_switched,
    E.application_activated,
}

E.for_display = {
    E.display_added,
    E.display_removed,
    E.display_moved,
    E.display_resized,
    E.display_changed,
}

return E