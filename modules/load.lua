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
  local mod_changed = false
  if data.mod_changes then
    mod_changed = true
    local thismod = data.mod_changes['0-event-trace']
    if thismod then
      if thismod.old_version and thismod.new_version then
      end
    end
  end
  if data.old_version and data.new_version or mod_changed then
    if storage.players then
      local eventnames = {}
      for k, _ in pairs(defines.events) do
        table.insert(eventnames, k)
      end
      table.sort(eventnames, function(a,b) return a < b end)
      for i1, g in pairs(storage.players) do
        if g.gui.frame and g.gui.frame.valid then
          g.gui.frame.destroy()
        end
        if g.gui.imframe and g.gui.imframe.valid then
          g.gui.imframe.destroy()
        end
        if g.gui.exframe and g.gui.exframe.valid then
          g.gui.exframe.destroy()
        end
        g.logging = false
        if g.whitelist then
          for i2, k in pairs(eventnames) do
            g.whitelist[k] = g.whitelist[k] or false
          end
          for k in pairs(g.whitelist) do
            if not defines.events[k] then
              g.whitelist[k] = nil
            end
          end
        end
        if g.counter then
          for i2, k in pairs(eventnames) do
            g.counter[k] = g.counter[k] or false
          end
          for k in pairs(g.counter) do
            if not defines.events[k] then
              g.counter[k] = nil
            end
          end
        end
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
