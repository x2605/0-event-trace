# 0-event-trace
 Factorio event trace viewer mod. Visit https://lua-api.factorio.com/latest/events.html to see full description of events.  
 
### Download  
https://mods.factorio.com/mod/0-event-trace  
To keep event logs and investigate them, use this with **gvv** mod https://mods.factorio.com/mod/gvv  
 
### How to use  
- Press SHIFT+F3 (you can change key bindings) to open GUI. Only admins can use the mod if it is multiplay game.  
- Press SHIFT+F2 for quick toggle logging mode while GUI is opened.  
- Only works while GUI is opened.  
- You can set up filter for events what you want to see.  
- Supports export/import filter list.  

### LuaRemote interfaces added to "gvv" mod if it is active
- **remote.call("__gvv__0-event-trace","add",<player_name>, <event_name>(string), <event_data>(table))** : Adds a log entry in global table of gvv.
- **remote.call("__gvv__0-event-trace","del",<player_name>, <event_name>(string), <start_index>, <end_index>)** : Deletes a range of log entries in global table of gvv.
- **remote.call("__gvv__0-event-trace","clear",<player_name>)** : Empties all log entries in global table of gvv. Only of specific player's.
- **remote.call("__gvv__0-event-trace","get",<player_name>, <event_name>(string), <index>)** : Returns a <event_data> table stored in global table of gvv.
