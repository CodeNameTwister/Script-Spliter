@tool
extends Window
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@export var _container : Node

var _plugin : Object = null
var _selected : int = 0

func _init() -> void:
	visibility_changed.connect(_on_visibility_change)

func set_plugin(current_plugin : Object) -> void:
	assert(current_plugin.has_method(&"get_type_split"))

	_plugin = current_plugin
	_selected = _plugin.call(&"get_type_split")

func _on_visibility_change() -> void:
	if !visible: return
	if !_plugin:
		push_warning("Not plugin degifed!")
		return
	_selected = _plugin.call(&"get_type_split")

func _ready() -> void:
	await get_tree().process_frame
	popup_centered()

func _update_gui() -> void:
	for x : Node in _container.get_children():
		if x is CheckBox:
			x.button_pressed = false
	if _selected < _container.get_child_count():
		var node : Node = _container.get_child(_selected)
		if node is CheckBox:
			node.button_pressed = true
		return
	push_error("[PLUGIN] Error!, this version is outdate!")

func selected(index :int) -> void:
	_selected = index
	_update_gui()

func _on_ok_pressed() -> void:
	_update_gui()
	if !_plugin.call(&"set_type_split", _selected):
		push_error("[ERROR] Can not set split type!")
	else:
		hide()


func _on_cancel_pressed() -> void:
	hide()
