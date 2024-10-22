--로드

local Load = {}
local gvv = require('modules.gvv')

if not _initiated_session_ then
  _loaded_ = false
  _initiated_session_ = true
end

local loader = function()
  if not _loaded_ then
    _gvv_recognized_ = false
    gvv.loader()
    _loaded_ = true
  end
end

Load.on_configuration_changed = function(data)
  if data.mod_changes then
    local thismod = data.mod_changes['0-event-trace']
    if thismod then
      if thismod.old_version and thismod.new_version then
      end
    end
  end
  loader()
end

Load.on_init = function()
  loader()
end

Load.on_load = function()
  loader()
end

Load.on_player_demoted = function(event)
  if not storage.players then return end
  local g = storage.players[event.player_index]
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
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  storage.players[event.player_index] = nil
end

Load.on_player_created = function(event)
  if not storage.players then return end
  local g = storage.players[event.player_index]
  if not g or not g.gui.frame or not g.gui.frame.valid then return end
  storage.players[event.player_index] = nil
end

return Load
