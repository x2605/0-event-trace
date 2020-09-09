-- 데이터

local prefix = '0-event-trace-'
local suffix = '_0-event-trace'

data:extend{
  {
    type = 'custom-input',
    name = prefix..'toggle-frame',
    key_sequence = 'SHIFT + F3'
  },
  {
    type = 'custom-input',
    name = prefix..'toggle-logging',
    key_sequence = 'SHIFT + F2'
  },
}

local default_gui = data.raw['gui-style'].default
local copytbl = function(dupl,source)
  default_gui[dupl] = table.deepcopy(source)
  return default_gui[dupl]
end
local emptywidget = function(dupl)
  default_gui[dupl] = {type = 'empty_widget_style', graphical_set = {}}
  return default_gui[dupl]
end
local c

default_gui['hflow'..suffix] = {
  type = "horizontal_flow_style",
  padding = 0,
  vertical_spacing = 0,
  horizontal_spacing = 0,
}
default_gui['vflow'..suffix] = {
  type = "vertical_flow_style",
  padding = 0,
  vertical_spacing = 0,
  horizontal_spacing = 0,
}

c = copytbl('output'..suffix, default_gui.label)
c.single_line = false

c = copytbl('frame'..suffix, default_gui.frame)
c.graphical_set.base.draw_type = 'outer'
c.graphical_set.base.center = {position = {25, 8}, size = {1, 1}}
c.top_padding = 0
c.right_padding = 0
c.bottom_padding = 0
c.left_padding = 0
c.vertical_spacing = 0
c.horizontal_spacing = 0
c.horizontal_flow_style = default_gui['hflow'..suffix]
c.vertical_flow_style = default_gui['vflow'..suffix]

c = copytbl('frame-bg'..suffix, default_gui.frame)
c.graphical_set = {base = {center = {position = {8, 8}, size = {1, 1}}}}
c.top_padding = 0
c.right_padding = 0
c.bottom_padding = 0
c.left_padding = 0
c.use_header_filler = false

c = emptywidget('empty-frame-bg'..suffix)
c.graphical_set = {base = {center = {position = {8, 8}, size = {1, 1}}}}

c = copytbl('tabbed_pane_frame'..suffix, default_gui.tabbed_pane_frame)
c.top_padding = 0
c.right_padding = 0
c.bottom_padding = 0
c.left_padding = 0
c.vertical_spacing = 0
c.horizontal_spacing = 0
c.graphical_set.base.center = {position = {25, 8}, size = {1, 1}}
c.graphical_set.base.bottom = nil

c = emptywidget('empty-tabbed_pane_frame-bg'..suffix)
c.graphical_set = {
  base = {
    center = {position = {76, 8}, size = {1, 1}},
    bottom = {position = {76, 9}, size = {1, 8}}
  },
  shadow = table.deepcopy(default_gui.subheader_frame.graphical_set.shadow)
}
c.horizontally_stretchable = 'on'

c = copytbl('tabbed_pane'..suffix, default_gui.tabbed_pane)
c.tab_content_frame.parent = 'tabbed_pane_frame'..suffix

c = copytbl('inside-wrap'..suffix, default_gui['frame'..suffix])
c.graphical_set = {
  base = {
    position = {17, 0}, corner_size = 8, draw_type = 'inner',
    center = {position = {25, 8}, size = {1, 1}},
  }
}

c = copytbl('inside_deep_frame'..suffix, default_gui.inside_deep_frame)
c.graphical_set.base = {
  center = {position = {336, 0}, size = {1, 1}},
  opacity = 0.75,
  background_blur = true
}

c = copytbl('scroll_pane'..suffix, default_gui.scroll_pane_under_subheader)
c.horizontally_stretchable = 'on'
c.vertically_stretchable = 'on'
c.vertical_scrollbar_style = table.deepcopy(default_gui.scroll_pane.vertical_scrollbar_style)
c.vertical_scrollbar_style.width=18
c.vertical_scrollbar_style.thumb_button_style = table.deepcopy(default_gui.vertical_scrollbar.thumb_button_style)
c.vertical_scrollbar_style.thumb_button_style.width=16

c = copytbl('scroll_pane-thickthumb'..suffix, default_gui['scroll_pane'..suffix])
c.horizontally_stretchable = 'off'
c.left_padding = 8
c.right_padding = 16

c = copytbl('dropdown'..suffix, default_gui.dropdown)
c.list_box_style.scroll_pane_style.vertical_scrollbar_style = table.deepcopy(default_gui.scroll_pane.vertical_scrollbar_style)
c.list_box_style.scroll_pane_style.vertical_scrollbar_style.width=18
c.list_box_style.scroll_pane_style.vertical_scrollbar_style.thumb_button_style = table.deepcopy(default_gui.vertical_scrollbar.thumb_button_style)
c.list_box_style.scroll_pane_style.vertical_scrollbar_style.thumb_button_style.width=16
