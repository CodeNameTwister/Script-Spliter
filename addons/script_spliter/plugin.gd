@tool
extends EditorPlugin
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
const MRES : Resource = preload("res://addons/script_spliter/main.gd")
const CRES : Resource = preload("res://addons/script_spliter/container.gd")

const CMD_MENU_TOOL : String = "Script Spliter"

var _main : Node = null
var _is_enabled : bool = false
var _menu_split_selector : Window = null

func get_first_element(root : Node, pattern : String, type : String) -> Node:
	var e : Array[Node] = root.find_children(pattern, type, true, false)
	if e.size() > 0:
		return e[0]
	return null

func _ready() -> void:
	var script_editor: ScriptEditor = EditorInterface.get_script_editor()
	var settings : EditorSettings = EditorInterface.get_editor_settings()
	var scripts_tab_container : Node = get_first_element(script_editor, "*", "TabContainer")

	if scripts_tab_container.get_script() != null:
		push_error("Plugin incompatibility, can`t enable plugin!")
		var plg : String = (get_script() as Resource).resource_path.get_base_dir().get_file()
		if !plg.is_empty():
			EditorInterface.set_plugin_enabled(plg, false)
		return

	if settings and !settings.has_setting("plugin/script_spliter/minimap_for_unfocus_window"):
		settings.set_setting("plugin/script_spliter/minimap_for_unfocus_window", false)

	add_tool_menu_item(CMD_MENU_TOOL, _on_tool_command)

	_setup(_setup_cfg(true))

func _on_tool_command() -> void:
	if !is_instance_valid(_menu_split_selector):
		_menu_split_selector = (ResourceLoader.load("res://addons/script_spliter/context/menu_tool.tscn") as PackedScene).instantiate()
		_menu_split_selector.set_plugin(self)
		add_child(_menu_split_selector)
	_menu_split_selector.popup_centered()

func set_type_split(type : int) -> bool:
	var setup : bool = false

	if type > 0 and type < 3:
		setup = true
	elif type != 0:
		return false

	_setup(setup)
	if setup:
		if is_instance_valid(_main):
			_main.set_split_type(type, false)
	return true

func get_type_split() -> int:
	if _is_enabled:
		return 1
	return 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.ctrl_pressed:
			if event.keycode == 49:
				_setup(false)
			elif event.keycode == 50:
				if !_is_enabled:
					_setup(true)
				if is_instance_valid(_main):
					_main.set_split_type(1, false)
			elif event.keycode == 51:
				if !_is_enabled:
					_setup(true)
				if is_instance_valid(_main):
					_main.set_split_type(2, false)

func _setup_cfg(as_load : bool) -> bool:
	const FILE : String = "user://editor/script_file.cfg"
	if !DirAccess.dir_exists_absolute(FILE.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(FILE.get_base_dir())
	if as_load == true:
		if !FileAccess.file_exists(FILE):
			_is_enabled = true
		else:
			var cfg : ConfigFile = ConfigFile.new()
			if cfg.load(FILE) == OK:
				return bool(cfg.get_value("plugin", "enabled", true))
	else:
		var cfg : ConfigFile = ConfigFile.new()
		cfg.set_value("plugin", "enabled", _is_enabled)
		if cfg.save(FILE) == OK:
			return true
		push_warning("Error plugin save changes!")
	return false

func _setup(enable : bool) -> void:
	if _is_enabled == enable:return
	_is_enabled = enable
	if enable:
		var script_editor: ScriptEditor = EditorInterface.get_script_editor()
		var scripts_tab_container : Node = get_first_element(script_editor, "*", "TabContainer")
		var parent : Control = scripts_tab_container.get_parent()
		var i : int = scripts_tab_container.get_index()

		if _main == null:
			_main = MRES.new()
		if scripts_tab_container.get_script() != CRES:
			scripts_tab_container.set_script(CRES)

		if _main.get_parent() != parent:
			parent.add_child(_main)

		_main.set_base(scripts_tab_container)

		if parent.get_child_count() > i:
			parent.move_child(_main, i)
		_main.visible = true
	else:
		var script_editor: ScriptEditor = EditorInterface.get_script_editor()
		var scripts_tab_container : Node = get_first_element(script_editor, "*", "TabContainer")
		if scripts_tab_container.get_script() == CRES:
			scripts_tab_container.set_script(null)
		if is_instance_valid(_main):
			_main.set_base(null)
			if _main.tree_exiting.is_connected(_main.on_exiting_tree):
				_main.tree_exiting.disconnect(_main.on_exiting_tree)
			var base : Node = _main.base
			var root : Node = _main.get_parent()
			if base != null and base.get_parent() != root and root != null:
				var i : int = _main.get_index()
				if base.get_parent() == null:
					root.add_child.call_deferred(base)
				else:
					if base.get_parent() != root:
						base.reparent.call_deferred(root)
				root.move_child.call_deferred(base, i)
			_main.visible = false

func _exit_tree() -> void:
	remove_tool_menu_item(CMD_MENU_TOOL)

	if is_instance_valid(_menu_split_selector) and !_menu_split_selector.is_queued_for_deletion():
		_menu_split_selector.queue_free()
		_menu_split_selector = null

	var script_editor: ScriptEditor = EditorInterface.get_script_editor()
	var scripts_tab_container : Node = get_first_element(script_editor, "*", "TabContainer")
	if scripts_tab_container.get_script() == CRES:
		scripts_tab_container.set_script(null)
	if is_instance_valid(_main):
		if _main.tree_exiting.is_connected(_main.on_exiting_tree):
			_main.tree_exiting.disconnect(_main.on_exiting_tree)
		var base : Node = _main.base
		var root : Node = _main.get_parent()
		if base != null and base.get_parent() != root and root != null:
			var i : int = _main.get_index()
			if base.get_parent() == null:
				root.add_child.call_deferred(base)
			else:
				if base.get_parent() != root:
					base.reparent.call_deferred(root)
			root.move_child.call_deferred(base, i)
			_main.set_base(null)
		_main.queue_free()


func _notification(what: int) -> void:
	if what != NOTIFICATION_PREDELETE:return
	_exit_tree()
