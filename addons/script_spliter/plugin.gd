@tool
extends EditorPlugin
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const BUILDER : Script = preload("res://addons/script_spliter/core/builder.gd")
const CONTEXT : Script = preload("res://addons/script_spliter/context/context_window.gd")

const CMD_MENU_TOOL : String = "Script Spliter"

#CONTEXT
const ICON_ADD_COLUMN : Texture = preload("res://addons/script_spliter/context/icons/split_cplus.svg")
const ICON_REMOVE_COLUMN : Texture = preload("res://addons/script_spliter/context/icons/split_cminus.svg")
const ICON_ADD_ROW : Texture = preload("res://addons/script_spliter/context/icons/split_rplus.svg")
const ICON_REMOVE_ROW : Texture = preload("res://addons/script_spliter/context/icons/split_rminus.svg")

var _rmb_editor_add_split : EditorContextMenuPlugin = null
var _rmb_editor_remove_split: EditorContextMenuPlugin = null
var _rmb_editor_code_add_split : EditorContextMenuPlugin = null
var _rmb_editor_code_remove_split : EditorContextMenuPlugin = null

var _menu_split_selector : Window = null
var _builder : Object = null

# BUFFERED CONFIG
var _rows : int = 0:
	set(e):
		_rows = maxi(e, 0)
var _columns : int = 0:
	set(e):
		_columns = maxi(e, 0)

var _frm : int = 0

func get_builder() -> Object:
	return _builder

func _get_first_element(root : Node, pattern : String, type : String) -> Node:
	var e : Array[Node] = root.find_children(pattern, type, true, false)
	if e.size() > 0:
		return e[0]
	return null

func get_split_rows() -> int:
	return _rows

func get_split_columns() -> int:
	return _columns

func _process(__: float) -> void:
	if _frm < 2:
		_frm += 1
		return
	_frm = 0
	set_process(false)
	if is_instance_valid(_builder):
		_builder.update()

func _on_change_settings() -> void:
	if is_instance_valid(_builder):
		_builder.update_config()

func _run() -> void:
	if is_instance_valid(_builder):
		var script_editor: ScriptEditor = EditorInterface.get_script_editor()
		var settings : EditorSettings = EditorInterface.get_editor_settings()
		var scripts_tab_container : Node = _get_first_element(script_editor, "*", "TabContainer")
		
		if !scripts_tab_container.is_node_ready():
			await scripts_tab_container.ready

		settings.settings_changed.connect(_on_change_settings)

		_builder.init_1()
		_builder.build(scripts_tab_container, _columns, _rows)
		set_process_input(true)

func set_type_split(columns : int, rows : int) -> void:
	_columns = columns
	_rows = rows
	
	var str_columns : String = str(maxi(_columns, 1))
	var str_rows : String = str(maxi(rows, 1))
	
	print("[{0}] {1} {2}: > {3} {5} - {4} {6}".format(
		[
			_get_translated_text("INFO"),
			_get_translated_text("Setting"),
			_get_translated_text("To"),
			_get_translated_text("Columns"),
			_get_translated_text("Rows"),
			str_columns, 
			str_rows
			]) )

	if is_instance_valid(_builder):
		_builder.update_build(columns, rows)

func _exit_tree() -> void:
	remove_tool_menu_item(CMD_MENU_TOOL)
	_setup(0)

	if is_instance_valid(_builder):
		_builder.init_0()
		_builder.free.call_deferred()

	var settings : EditorSettings = EditorInterface.get_editor_settings()
	if settings.settings_changed.is_connected(_on_change_settings):
		settings.settings_changed.disconnect(_on_change_settings)

func _get_translated_text(text : String) -> String:
	# TODO: Translation
	return text

func _setup(input : int) -> void:
	var settings : EditorSettings = EditorInterface.get_editor_settings()

	if input != 0:
		var ctx_add_column : String = _get_translated_text("ADD_SPLIT").capitalize()
		var ctx_remove_split : String = _get_translated_text("REMOVE_SPLIT").capitalize()

		#SETUP
		_rmb_editor_add_split = CONTEXT.new(ctx_add_column, _add_window_split, _can_add_split, ICON_ADD_COLUMN)
		_rmb_editor_remove_split = CONTEXT.new(ctx_remove_split, _remove_window_split, _can_remove_split, ICON_REMOVE_COLUMN)

		_rmb_editor_code_add_split = CONTEXT.new(ctx_add_column, _add_window_split, _can_add_split, ICON_ADD_COLUMN)
		_rmb_editor_code_remove_split = CONTEXT.new(ctx_remove_split, _remove_window_split, _can_remove_split, ICON_REMOVE_COLUMN)

		add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR, _rmb_editor_add_split)
		add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR, _rmb_editor_remove_split)

		add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, _rmb_editor_code_add_split)
		add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, _rmb_editor_code_remove_split)

		if !settings.has_setting(&"plugin/script_spliter/rows"):
			settings.set_setting(&"plugin/script_spliter/rows", _rows)
		else:
			_rows = settings.get_setting(&"plugin/script_spliter/rows")
		if !settings.has_setting(&"plugin/script_spliter/columns"):
			settings.set_setting(&"plugin/script_spliter/columns", _columns)
		else:
			_columns = settings.get_setting(&"plugin/script_spliter/columns")
		if !settings.has_setting(&"plugin/script_spliter/save_rows_columns_count_on_exit"):
			settings.set_setting(&"plugin/script_spliter/save_rows_columns_count_on_exit", false)
	else:
		if is_instance_valid(_rmb_editor_add_split):
			remove_context_menu_plugin(_rmb_editor_add_split)
		if is_instance_valid(_rmb_editor_remove_split):
			remove_context_menu_plugin(_rmb_editor_remove_split)
		if is_instance_valid(_rmb_editor_code_add_split):
			remove_context_menu_plugin(_rmb_editor_code_add_split)
		if is_instance_valid(_rmb_editor_code_remove_split):
			remove_context_menu_plugin(_rmb_editor_code_remove_split)

		if settings.has_setting(&"plugin/script_spliter/save_rows_columns_count_on_exit"):
			if settings.get_setting(&"plugin/script_spliter/save_rows_columns_count_on_exit") == true:
				settings.set_setting(&"plugin/script_spliter/rows", _rows)
				settings.set_setting(&"plugin/script_spliter/columns", _columns)

func _can_add_split(path : PackedStringArray) -> bool:
	if !is_instance_valid(_builder):
		return false
	for x : String in path:
		if x.begins_with("res://"):
			var sc : ScriptEditor = EditorInterface.get_script_editor()
			var arr : Array[ScriptEditorBase] = sc.get_open_script_editors()
			var scs : Array[Script] = sc.get_open_scripts()
			if arr.size() == scs.size():
				for y : int in range(0, scs.size(), 1):
					if scs[y].resource_path == x:
						return _builder.can_add_split(arr[y].get_base_editor())
		else:
			var node : Node = get_node_or_null(x)
			if node:
				return _builder.can_add_split(node)
	return false

func _can_remove_split(path : PackedStringArray) -> bool:
	if !is_instance_valid(_builder):
		return false
	for x : String in path:
		var node : Node = get_node_or_null(x)
		if node:
			return _builder.can_remove_split(node)
	return false

func _add_window_split(variant : Variant) -> void:
	var control : Control = null
	if variant is Script:
		var sc : ScriptEditor = EditorInterface.get_script_editor()
		var arr : Array[ScriptEditorBase] = sc.get_open_script_editors()
		var scs : Array[Script] = sc.get_open_scripts()
		if arr.size() == scs.size():
			for y : int in range(0, scs.size(), 1):
				if scs[y] == variant:
					control = arr[y].get_base_editor()
					break
	if variant is CodeEdit:
		control = variant
	if is_instance_valid(control):
		_builder.add_split(control)

func _remove_window_split(variant : Variant) -> void:
	var control : Control = null
	if variant is Script:
		var sc : ScriptEditor = EditorInterface.get_script_editor()
		var arr : Array[ScriptEditorBase] = sc.get_open_script_editors()
		var scs : Array[Script] = sc.get_open_scripts()
		if arr.size() == scs.size():
			for y : int in range(0, scs.size(), 1):
				if scs[y] == variant:
					control = variant
					break
	if variant is CodeEdit:
		control = variant
	if is_instance_valid(control):
		_builder.remove_split(control)

func _enter_tree() -> void:
	_setup(1)

	if !is_instance_valid(_builder):
		_builder = BUILDER.new(self)
	add_tool_menu_item(CMD_MENU_TOOL, _on_tool_command)

func _on_tool_command() -> void:
	if is_instance_valid(_builder):
		var data : Array[int] = _builder.get_current_columns_and_rows()
		_columns = data[0]
		_rows = data[1]
	
	if !is_instance_valid(_menu_split_selector):
		_menu_split_selector = (ResourceLoader.load("res://addons/script_spliter/context/menu_tool.tscn") as PackedScene).instantiate()
		_menu_split_selector.set_plugin(self)
		_menu_split_selector.visible = false
		add_child(_menu_split_selector)
	_menu_split_selector.popup_centered.call_deferred()

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	if !get_tree().root.is_node_ready():
		await get_tree().root.ready
	for __ : int in range(2):
		await get_tree().process_frame
	_run()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_builder) and !_builder.is_queued_for_deletion():
			_builder.init_0()
			_builder.free()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.ctrl_pressed:
			if event.keycode == 49:
				set_type_split(0, 0)
			elif event.keycode == 50:
				set_type_split(2, 1)
			elif event.keycode == 51:
				set_type_split(1, 2)
			elif event.keycode == 52:
				set_type_split(3, 1)
			elif event.keycode == 53:
				set_type_split(1, 3)
			elif event.keycode == 54:
				set_type_split(2, 2)
