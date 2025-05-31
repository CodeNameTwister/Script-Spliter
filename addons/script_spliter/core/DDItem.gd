@tool
extends ItemList
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


signal on_start_drag(t : ItemList)
signal on_stop_drag(t : ItemList)

const PREVIEW : PackedScene = preload("res://addons/script_spliter/context/tab_preview.tscn")

var is_drag : bool = false:
	set(e):
		is_drag = e
		if is_drag:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

var _fms : float = 0.0

func _init() -> void:
	setup()
	if is_node_ready():
		set_process(false)

func _ready() -> void:
	set_process(false)

func make_preview() -> Control:
	var items : PackedInt32Array = get_selected_items()
	if items.size() > 0:
		var tab : TabContainer = (get_parent() as TabContainer)
		var preview : Control = PREVIEW.instantiate()
		var label : Label = preview.get_node("Label")
		
		var ctrl : Control = preview.get_child(0)
		var item_id : int = items[0]
		if ctrl is TextureRect:
			ctrl.texture = get_item_icon(item_id)
			ctrl.modulate = get_item_icon_modulate(item_id)
			
		
		label.text = get_item_text(item_id)
		preview.z_as_relative = false
		preview.z_index = 4096
		preview.top_level = true
		preview.visible = true
		if label.text.is_empty():
			label.text = str("Grab File index " , tab.current_tab)
		return preview
	return null

func _process(delta: float) -> void:
	_fms += delta
	if _fms > 0.24:
		if is_drag:
			if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				set_process(false)
				is_drag = false
				on_stop_drag.emit(self)
		else:
			force_drag(
				self
			,make_preview()
			)
			on_start_drag.emit(self)
			is_drag = true

func setup() -> void:
	if !gui_input.is_connected(_on_input):
		gui_input.connect(_on_input)

func _on_input(e : InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.button_index == 1:
			if e.pressed:
				_fms = 0.0
				is_drag = false
				set_process(true)
			else:
				set_process(false)
				if _fms >= 0.24:
					on_stop_drag.emit(self)
