@tool
extends Label
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const TIME : int = 12

var _p : float = 0.0
var _s : int = 0
var _e : Color = Color.BLACK
var _c : Color = Color.BLACK

func _init() -> void:
	if is_node_ready():
		_ready()

func _ready() -> void:
	set_process(false)

func set_new_color(c : Color, focus : bool = false) -> void:
	if focus:
		_e = c
		_p = -0.2
		_s = 0
		_c = Color.YELLOW
		modulate = c
		set_process(true)
	else:
		modulate = c
		set_process(false)

func _process(delta: float) -> void:
	_p += delta * 10.0
	if _p < 1.0:
		modulate = lerp(modulate, _c, _p)
		return
	modulate = _c
	_s += 1
	if _s > TIME:
		_c = _e
		if _s > TIME + 1:
			set_process(false)
			return
	else:
		if _s % 2 == 0:
			_c = _e.lightened(0.75)
		else:
			_c = _e.darkened(0.35)
	_p = 0.0
