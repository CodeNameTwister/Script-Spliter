@tool
extends TabContainer
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@warning_ignore("unused_signal")
signal on_dragging(e : Control)
signal out_dragging(e : Control)

const DDTAB : Script = preload("res://addons/script_spliter/core/DDTAB.gd")

var _buffer_editors : Array[Object] = []

func clear_editors() -> void:
	_buffer_editors.clear()

func add_editor(o : Object, limit : int) -> Object:
	if limit > 0:
		var i : int = _buffer_editors.find(o)
		if i > -1:
			_buffer_editors.remove_at(i)
		_buffer_editors.append(o)
	if limit > -1:
		while _buffer_editors.size() > limit:
			_buffer_editors.remove_at(0)
	return o
	
func remove_editor(o : Object) -> void:
	_buffer_editors.erase(o)
	
func backward_editor() -> Object:
	if _buffer_editors.size() > 1:
		var o : Object = _buffer_editors.pop_back()
		_buffer_editors.push_front(o)
		return o
	return null
	
func forward_editor() -> Object:
	if _buffer_editors.size() > 1:
		var o : Object = _buffer_editors.pop_front()
		_buffer_editors.push_back(o)
		return o
	return null


func _on_child(n : Node) -> void:
	if n is TabBar:
		n.set_script(DDTAB)

		if !n.on_start_drag.is_connected(_on_start_drag):
			n.on_start_drag.connect(_on_start_drag)
		if !n.on_stop_drag.is_connected(_on_stop_drag):
			n.on_stop_drag.connect(_on_stop_drag)
			
func _on_stop_drag(tab : TabBar) -> void:
	out_dragging.emit(tab)

func _on_start_drag(tab : TabBar) -> void:
	on_dragging.emit(tab)
#
func _init() -> void:
	child_entered_tree.connect(_on_child)
