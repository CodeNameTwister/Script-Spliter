@tool
extends HBoxContainer
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Splitter
#	https://github.com/CodeNameTwister/Script-Splitter
#
#	Script Splitter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const CONFIRM = preload("uid://d08g07ma7o1n0")

var remove : Button

func _ready() -> void:
	remove.pressed.connect(_on_remove)
	
func _on_accept() -> void:
	
	pass
	
func _on_remove() -> void:
	var o : Node = CONFIRM.instantiate()
	add_child(o)
	
	o.accepted.connect(_on_accept)
