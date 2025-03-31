@tool
extends TabContainer
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
var _item_list : ItemList = null:
	get:
		if _item_list == null:
			var script_editor: ScriptEditor = EditorInterface.get_script_editor()
			var items : Array[Node] = script_editor.find_children("*", "ItemList", true, false)
			if items.size() > 0:
				_item_list =  items[0]
			else:
				push_warning("Can not find item")
		return _item_list

func _set(property: StringName, value: Variant) -> bool:
	if property == &"tabs_visible" and value == true:
		return true
	return false

func get_item_text(c : int) -> String:
	var item_list : Control = _item_list
	var text : String = ""
	if null != item_list and c < get_child_count() and item_list.item_count > c:
		text = item_list.get_item_text(c).trim_suffix("(*)") #base.get_child(c).name
	return text
