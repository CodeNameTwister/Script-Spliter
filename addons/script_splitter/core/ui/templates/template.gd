@tool
extends Control
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Splitter
#	https://github.com/CodeNameTwister/Script-Splitter
#
#	Script Splitter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@warning_ignore("unused_signal")
signal open(container : Node)
@warning_ignore("unused_signal")
signal edit(container : Node)
@warning_ignore("unused_signal")
signal add(container : Node)
@warning_ignore("unused_signal")
signal cancel(container : Node)

@export var button : Control = null

var id : int = 0
var order : int = 0

func _ready() -> void:
	update()
	button.resized.connect(update)

func update() -> void:
	
	var b_size : Vector2 = button.get_combined_minimum_size()
	custom_minimum_size = Vector2(b_size.y, b_size.x)
	
	if button.size != b_size:
		button.size = b_size
	
	if abs(button.rotation_degrees) == 90.0:
		if button.rotation_degrees > 0:
			button.position = Vector2(b_size.y, 0)
		else:
			button.position = Vector2(0, b_size.x)
