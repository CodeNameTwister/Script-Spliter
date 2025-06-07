# Script Spliter in Editor Settings
Each plugin configuration parameter is documented here.

**Root of EditorSettings**: *plugin/script_spliter/**

|  Setting  | Description  |
| ------------ | ------------ |
|  Row | (Work on start/Managed by Plugin) Initial rows, if it is zero it will be equal to 1 |
| Column  |  (Work on start/Managed by Plugin) Initial columns, if it is zero it will be equal to 1 |
| Save Rows Columns Count on exit  |  Save the current columns and rows you split before exiting to open them on next startup |

### Behaviour
|  Setting  | Description  |
| ------------ | ------------ |
| Refresh Warnings On Save | Check on save if all scripts has new errors/warnings|

### Window
|  Setting  | Description  |
| ------------ | ------------ |
| Use Highlight Selected | Show fade color when focus a window|
| Highlight Selected Color | Color of the fader when focus |

### Editor
|  Setting  | Description  |
| ------------ | ------------ |
| Minimap for unfocus window | Hide minimap of the script when focus another window |
| Out Focus Color Enabled | Enable set a modulate color when focus another window |
| Out Focus Color Value | Modulate color when focus another window |

### Editor/Behaviour
|  Setting  | Description  |
| ------------ | ------------ |
| Expand on focus | Enable expand when focus a split window shrunk |
| Can expand on same focus | Force Expand if the window current focused is shrunk |
| Smooth expand | Enable Smooth when expand the window shrunk |
| Smooth expand time| Total time for complete expand the window shrunk|
| Swap by double click separator button | Enable swap between windows when double click in separator button |

### Editor/Behaviour/Back And Forward
|  Setting  | Description  |
| ------------ | ------------ |
| Handle Back And Forward | Enable handler event of back and forward by internal function addon |
| History Size | Max buffer size history of scripts/documents recent opened by the window split (Are stored independently by window)
| Using As Next And Back Tab| Change Behaviour and use back and forward as next or back aviable tab |
| Backward Key Button Path| Path of resource setting of backward key button |
| Forward Key Button Path| Path of resource setting of forward key button |
| Backward Mouse Button Path| Path of resource setting of backward mouse button |
| Forward Mouse Button Path| Path of resource setting of forward mouse button |
| Use Native Handler When There Are No More Tabs| Enable leave to godot handle the back and forward when not exist more tabs in the focused window |

### Editor/Split
This section work only when you add new split/s.
in old versions < 0.3 was more useful.

|  Setting  | Description  |
| ------------ | ------------ |
| Reopen Last Closed Editor On Add Split | Enable open a script recent used and closed (Only for script / unless you make a request on github and change your mind)|
| Remember Last Used Editor Buffer Size | Max last scripts for remember, maybe you want increase if you usually work with more than 4 windows |


### Line
|  Setting  | Description  |
| ------------ | ------------ |
| Size | Line width  |
| Color | Color of the Line, magenta is default that mean use editor color  |
| Draggable | Allow drag the Line pressing the primary mouse button |
| Expand by Double Click | When you press with mouse (double click) the line back to initial position |

### Button
|  Setting  | Description  |
| ------------ | ------------ |
| Size | Button width  |
| Modulate | Modulate Button Color  |
| Icon Path | Texture path for the button  |
# 
Script Spliter tool plugin for Community Of Godot 4, created by Twister.
