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

# V3
#const DDTAB : Script = preload("res://addons/script_spliter/core/DDTAB.gd")
#
#func _on_child(n : Node) -> void:
	#if n is TabBar:
		#n.set_script(DDTAB)
#
		#if !n.on_start_drag.is_connected(_on_start_drag):
			#n.on_start_drag.connect(_on_start_drag)
#
#func _on_start_drag(__ : TabBar) -> void:
	#on_dragging.emit(get_parent())
#
#func _init() -> void:
	#child_entered_tree.connect(_on_child)
