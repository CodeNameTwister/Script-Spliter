@tool
extends TabBar
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


signal on_start_drag(t : TabBar)
signal on_stop_drag(t : TabBar)

const PREVIEW : PackedScene = preload("res://addons/script_spliter/context/tab_preview.tscn")

var _fms : float = 0.0

func _init() -> void:
	setup()
	if is_node_ready():
		set_process(false)

func _ready() -> void:
	set_process(false)

func make_preview(from : Control) -> Control:
	var tab : TabContainer = (get_parent() as TabContainer)
	var preview : Control = PREVIEW.instantiate()
	var label : Label = preview.get_node("Label")
	preview.z_as_relative = false
	preview.z_index = 4096
	preview.top_level = true
	label.text = tab.get_tab_title(tab.current_tab)
	preview.visible = true
	if label.text.is_empty():
		label.text = str("Grab File index " , tab.current_tab)
	return preview

func _process(delta: float) -> void:
	_fms += delta
	if _fms > 0.24:
		force_drag(
			get_parent()
		,make_preview(self)
		)
		on_start_drag.emit(self)
		set_process(false)

func setup() -> void:
	if !gui_input.is_connected(_on_input):
		gui_input.connect(_on_input)

func _on_input(e : InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.button_index == 1:
			if true == e.pressed:
				_fms = 0.0
				set_process(true)
			else:
				set_process(false)
				if _fms >= 24.0:
					on_stop_drag.emit()
