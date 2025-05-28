@tool
extends Control
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
var _0x0001 : float = 0.0
var _0x0002 : float= 0.5

func _ready() -> void:
	if !is_inside_tree():
		set_process(false)
		
func _process(delta: float) -> void:
	_0x0001 += delta * 3.0
	if _0x0001 >= 1.0:
		_0x0001 = 0.0
		if _0x0002 == 1.0:
			_0x0002 = 0.5
		else:
			_0x0002 = 1.0
	modulate.a = lerp(modulate.a, _0x0002, _0x0001)
	
	for x : Node in get_children():
		if x is Control:
			x.pivot_offset = x.size/2.0
			x.scale =  lerp(x.scale, Vector2.ONE * _0x0002, _0x0001)
	
func _enter_tree() -> void:
	set_process(true)
	for x : Node in get_children():
		if x is Control:
			x.set_deferred(&"size_flags_horizontal", Control.SIZE_SHRINK_CENTER)
			x.set_deferred(&"size_flags_vertical", Control.SIZE_SHRINK_CENTER)
	
func _exit_tree() -> void:
	set_process(false)
