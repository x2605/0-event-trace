--gvv 사용

local gvv = {}

------------------
local lua_code = require('modules.remote_code.remote_gvv')

gvv.loader = function()
  if script.active_mods['gvv'] then
    local pc, ret = pcall(function() remote.call('__gvv__gvv','c',lua_code) end)
    if pc then
      _gvv_recognized_ = true
    else
      log(ret)
    end
  end
end

return gvv
