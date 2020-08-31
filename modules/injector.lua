-- 인젝터

local Util = require('modules.util')
local Table_to_str = require('modules.table_to_str')

local Injector = {}

local get_handlers = function(event_list)
  local r = {}
  for k, v in pairs(event_list) do
    r[k] = script.get_event_handler(v)
    if not r[k] then r[k] = true end
  end
  return r
end

local set_handlers = function(handler_list)
  for k, v in pairs(handler_list) do
    local f = v
    script.on_event(
      defines.events[k],
      function(e)
        if global.players then
          local ed = Util.deepcopytbl(e)
          local tick = ed.tick
          local logging = true
          ed.tick = nil
          ed.name = nil
          if k == k:match('^on_gui_.+') and Util.have_parent_0_event_trace(ed.element) then logging = false end
          if logging then
            for player_index, g in pairs(global.players) do
              if g.logging and game.players[player_index] and game.players[player_index].connected and g.whitelist[k] and g.gui.outpane.valid then
                g.counter[k] = g.counter[k] + 1
                local str = {"",'[color=0.6,0.6,0.6,1][font=default-tiny-bold]',tick,' . [color=yellow][font=default]',k,'[/font][/color] ',g.counter[k],'[/font][/color] ',
                  Table_to_str.to_richtext(ed),
                }
                g.gui.outpane.add{type = 'label', caption = str, style = 'output_0-event-trace'}
                if #g.gui.outpane.children > 100 then g.gui.outpane.children[1].destroy() end
                g.gui.outpane.scroll_to_bottom()
              end
            end
          end
        end
        if type(f) == 'function' then f(e) end
      end,
      script.get_event_filter(defines.events[k])
    )
  end
end

Injector.on_load = function()
  local events = Util.copytbl(defines.events)
  events.on_tick = nil
  set_handlers(get_handlers(events))
end

return Injector
