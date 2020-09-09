-- 컨트롤

_initiated_session_ = false

local Gui = require('modules.gui')
local Gui_Event = require('modules.gui_event')
local Load = require('modules.load')
local Injector = require('modules.injector')

script.on_event(defines.events.on_gui_click, Gui_Event.on_gui_click)
script.on_event(defines.events.on_gui_value_changed, Gui_Event.on_gui_value_changed)
script.on_event(defines.events.on_gui_switch_state_changed, Gui_Event.on_gui_switch_state_changed)
script.on_event(defines.events.on_gui_checked_state_changed, Gui_Event.on_gui_checked_state_changed)
script.on_event(defines.events.on_gui_text_changed, Gui_Event.on_gui_text_changed)
script.on_event(defines.events.on_gui_closed, Gui_Event.on_gui_closed)
script.on_event(defines.events.on_gui_confirmed, Gui_Event.on_gui_confirmed)
script.on_event(defines.events.on_gui_selection_state_changed, Gui_Event.on_gui_selection_state_changed)
script.on_event('0-event-trace-toggle-frame', Gui.toggle_frame)
script.on_event('0-event-trace-toggle-logging', Gui.toggle_logging)
script.on_event(defines.events.on_player_removed, Load.on_player_removed)
script.on_event(defines.events.on_player_demoted, Load.on_player_demoted)
script.on_event(defines.events.on_player_created, Load.on_player_created)

script.on_init(Load.on_init)
script.on_load(Load.on_load)
script.on_configuration_changed(Load.on_configuration_changed)
Injector.on_load()
