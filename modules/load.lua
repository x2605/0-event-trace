--로드

local Load = {}

Load.on_configuration_changed = function(data)
  if data.mod_changes then
    local thismod = data.mod_changes['0-event-trace']
    if thismod then
      if thismod.old_version and thidmod.new_version then
      end
    end
  end
end

Load.on_init = function()
end

Load.on_load = function()
end

Load.on_player_demoted = function(event)
  if not global.players then return end
  local g = global.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  g.gui.frame.destroy()
  g.logging = false
  if g.gui.exframe and g.gui.exframe.valid then
    g.gui.exframe.destroy()
  end
  if g.gui.imframe and g.gui.imframe.valid then
    g.gui.imframe.destroy()
  end
end

Load.on_player_removed = function(event)
  if not global.players then return end
  local g = global.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  global.players[event.player_index] = nil
end

return Load
