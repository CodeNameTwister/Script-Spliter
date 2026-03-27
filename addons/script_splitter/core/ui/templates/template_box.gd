@tool
extends Control
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Splitter
#	https://github.com/CodeNameTwister/Script-Splitter
#
#	Script Splitter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const TEMPLATE_CONTAINER = preload("template_container.tscn")

func _enter_tree() -> void:
	add_to_group(&"__SP_C_TEMPLATE__")
	
func _exit_tree() -> void:
	remove_from_group(&"__SP_C_TEMPLATE__")
