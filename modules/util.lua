-- 유틸

local Util = {}

--LuaGuiElement label개체 추가하기
Util.add_label_w_style = function(parent, caption, style, styles)
  local l = parent.add{type = 'label', caption = caption, style = style}
  for k, v in pairs(styles) do
    l.style[k] = v
  end
  return l
end

--얕은 테이블 복사
Util.copytbl = function(ori)
  local ret = {}
  for k, v in pairs(ori) do
    ret[k] = v
  end
  return ret
end

--깊은 테이블 복사
Util.deepcopytbl = function(ori)
  local t = type(ori)
  local ret
  if t == 'userdata' and ori.object_name then
    ret = ori
  elseif t == 'table' then
    ret = {}
    for k, v in next, ori, nil do
      ret[Util.deepcopytbl(k)] = Util.deepcopytbl(v)
    end
    setmetatable(ret, Util.deepcopytbl(getmetatable(ori)))
  else
    ret = ori
  end
  return ret
end

--부모개체 검사
Util.have_parent_0_event_trace = function(gui_elem)
  if not gui_elem or not gui_elem.valid then return end
  if gui_elem.name == '_0_event_trace_frame_' then
    return true
  elseif gui_elem.parent and gui_elem.parent.name == '_0_event_trace_frame_' then
    return true
  elseif _gvv_recognized_ and gui_elem.name == '_gvv-mod_frame_' then
    return true
  elseif _gvv_recognized_ and gui_elem.parent and gui_elem.parent.name == '_gvv-mod_frame_' then
    return true
  elseif gui_elem.parent then
    return Util.have_parent_0_event_trace(gui_elem.parent)
  else
    return false
  end
end

--닫기 버튼이 있는 프레임 만들기
Util.create_frame_w_closebtn = function(player, frame_name, title)
  local frame = player.gui.screen.add{type = 'frame', name = frame_name, direction = 'vertical'}
  frame.add{type = 'flow', name = 'header', direction = 'horizontal'}
  frame.header.drag_target = frame
  local tit = frame.header.add{type = 'label', caption = title, style = 'frame_title'}
  tit.drag_target = frame
  local drag = frame.header.add{type = 'empty-widget', name = 'dragspace', style = 'draggable_space_header'}
  drag.drag_target = frame
  drag.style.right_margin = 8
  drag.style.height = 24
  drag.style.horizontally_stretchable = true
  drag.style.vertically_stretchable = true
  local closebtn = frame.header.add{type = 'sprite-button', name = 'closebtn', sprite = 'utility/close', style = 'frame_action_button', mouse_button_filter = {'left'}}
  local innerframe = frame.add{type = 'flow', direction = 'vertical'}
  frame.auto_center = true
  return frame, closebtn, innerframe
end

return Util
