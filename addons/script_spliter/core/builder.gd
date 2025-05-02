@tool
extends Object
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const EditorContainer : Script = preload("res://addons/script_spliter/core/EditorContainer.gd")
const DD : Script = preload("res://addons/script_spliter/core/DDContainer.gd")
const ETAB : Script = preload("res://addons/script_spliter/core/ETab.gd")

var _plugin : Node = null

var _root : Node = null
var _main : EditorContainer = null
var _container : Root = null
var _editor : TabContainer = null
var _editor_min_size : Vector2 = Vector2.ZERO

var _code_editors : Array[Mickeytools] = []
var _last_tool : Mickeytools = null

var _tweener : ReTweener = null
var _item_list : ItemList = null:
	get:
		if !is_instance_valid(_item_list):
			var script_editor: ScriptEditor = EditorInterface.get_script_editor()
			var items : Array[Node] = script_editor.find_children("*", "ItemList", true, false)
			if items.size() > 0:
				_item_list =  items[0]
			else:
				push_warning("Can not find item list!")
		return _item_list


#region __CONFIG__
var _SPLIT_USE_HIGHLIGHT_SELECTED : bool = true
var _MINIMAP_4_UNFOCUS_WINDOW : bool = true

var _SPLIT_HIGHLIGHT_COLOR : Color = Color.MEDIUM_SLATE_BLUE

var _SEPARATOR_LINE_SIZE : int = 8
var _SEPARATOR_LINE_COLOR : Color = Color.MAGENTA
var _SEPARATOR_BUTTON_SIZE : int = 19
var _SEPARATOR_BUTTON_MODULATE : Color = Color.WHITE
var _SEPARATOR_BUTTON_ICON : Texture = preload("res://addons/script_spliter/context/icons/expand.svg")


var _SEPARATOR_SMOOTH_EXPAND : bool = true
var _SEPARATOR_SMOOTH_EXPAND_TIME : float = 0.24

# CURRENT CONFIG
var current_columns : int = 1
var current_rows : int = 1

func _get_data_cfg() -> Array[Array]:
	const CFG : Array[Array] = [
			[&"plugin/script_spliter/window/use_highlight_selected", &"_SPLIT_USE_HIGHLIGHT_SELECTED"]
			,[&"plugin/script_spliter/window/highlight_selected_color",&"_SPLIT_HIGHLIGHT_COLOR"]

			,[&"plugin/script_spliter/editor/minimap_for_unfocus_window", &"_MINIMAP_4_UNFOCUS_WINDOW"]
			,[&"plugin/script_spliter/editor/smooth_expand", &"_SEPARATOR_SMOOTH_EXPAND"]
			,[&"plugin/script_spliter/editor/smooth_expand_time", &"_SEPARATOR_SMOOTH_EXPAND_TIME"]

			,[&"plugin/script_spliter/line/size", &"_SEPARATOR_LINE_SIZE"]
			,[&"plugin/script_spliter/line/color", &"_SEPARATOR_LINE_COLOR"]

			,[&"plugin/script_spliter/line/button/size", &"_SEPARATOR_BUTTON_SIZE"]
			,[&"plugin/script_spliter/line/button/modulate", &"_SEPARATOR_BUTTON_MODULATE"]
			,[&"plugin/script_spliter/line/button/icon", &"_SEPARATOR_BUTTON_ICON"]
		]
	return CFG

func init_1() -> void:
	var settings : EditorSettings = EditorInterface.get_editor_settings()

	for x : Array in _get_data_cfg():
		if !settings.has_setting(x[0]):
			settings.set_setting(x[0], get(x[1]))
		else:
			set(x[1], settings.get_setting(x[0]))

	settings.add_property_info({
		"name": &"plugin/script_spliter/window/highlight_selected_color",
		"type": TYPE_COLOR
	})
	settings.add_property_info({
		"name": &"plugin/script_spliter/line/button/modulate",
		"type": TYPE_COLOR
	})
	settings.add_property_info({
		"name": &"plugin/script_spliter/line/button/icon",
		"type": TYPE_OBJECT,
		"hint" : PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Texture2D"
	})
#endregion

func update_config() -> void:
	var settings : EditorSettings = EditorInterface.get_editor_settings()
	var changes : PackedStringArray = settings.get_changed_settings()

	for x : Array in _get_data_cfg():
		if x[0] in changes:
			set(x[1], settings.get_setting(x[0]))

	_update_container()

func _update_container() -> void:
	if !is_instance_valid(_main):
		return
	_main.separator_line_size = _SEPARATOR_LINE_SIZE
	_main.separator_line_color = _SEPARATOR_LINE_COLOR
	_main.drag_button_size = _SEPARATOR_BUTTON_SIZE
	_main.drag_button_modulate = _SEPARATOR_BUTTON_MODULATE
	_main.drag_button_icon = _SEPARATOR_BUTTON_ICON
	_main.behaviour_expand_smoothed = _SEPARATOR_SMOOTH_EXPAND
	_main.behaviour_expand_smoothed_time = _SEPARATOR_SMOOTH_EXPAND_TIME

func _init(plugin : Object) -> void:
	_plugin = plugin

func init_0() -> void:
		if is_instance_valid(_tweener):
			_tweener.clear()
		_tweener = null

		if _editor.tree_exiting.is_connected(_on_container_exit):
			_editor.tree_exiting.disconnect(_on_container_exit)
		if _editor.tree_entered.is_connected(_on_container_entered):
			_editor.tree_entered.disconnect(_on_container_entered)

		for x : Mickeytools in _code_editors:
			x.reset(false)
			x.free()
		_code_editors.clear()

		if is_instance_valid(_container):
			var parent : Node = _container.get_parent()
			_container.visible = false
			if is_instance_valid(parent):
				parent.remove_child(_container)
			_container.queue_free()

		if is_instance_valid(_editor):
			_setup(_editor, false)
			if _editor.get_script() == ETAB:
				_editor.setup(0)
				_editor.set_script(null)
			_editor.custom_minimum_size = _editor_min_size
			_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _clear() -> void:
	for z : int in range(_code_editors.size() - 1, -1 , -1):
		var x : Mickeytools = _code_editors[z]
		var dirty : bool = false
		for e : Node in _editor.get_children():
			if x.is_equal(e):
				dirty = true
		if !dirty:
			_code_editors[z].reset()
			_code_editors.remove_at(z)

	for x : Node in _main.get_children():
		if x is TabContainer:continue
		if x.get_child_count() > 0:
			for y : Node in x.get_children():
				for z : Node in y.get_children():
					var dirty : bool = false
					for t : Mickeytools in _code_editors:
						if t.get_control() == z:
							dirty = true
					if !dirty:
						for zx : Node in _editor.get_children():
							if z == zx:
								dirty = true
								break
						if dirty:
							z.queue_free.call_deferred()
						else:
							y.remove_child(z)

func _get_editor_root() -> Node:
	var aviable : Node = get_aviable()
	if is_instance_valid(aviable):
		return aviable
	if is_instance_valid(_last_tool):
		return _last_tool.get_root()
	return null

class Root extends PanelContainer:
	pass

class Mickeytools extends Object:
	signal focus(_self : Mickeytools)

	var _helper : Object = null

	var _root : Node = null
	var _parent : Node = null
	var _reference : Node = null
	var _control : Node = null
	var _gui : Node = null
	var _index : int = 0

	func get_gui() -> Node:
		return _gui

	func grab_focus() -> void:
		var root : TabContainer = _root
		if is_instance_valid(root) and is_instance_valid(_control):
			if _control.get_parent() == null:
				return
			var index : int = _control.get_index()
			for x : Node in root.get_children():
				if x == _control:
					if index > -1 and index < root.get_child_count():
						root.current_tab = index
					break
		if is_instance_valid(_gui) and _gui.is_inside_tree():
			(_gui as Control).grab_focus()

	func get_control() -> Node:
		return _control

	func get_root() -> Node:
		return _root

	func get_reference() -> Node:
		return _reference

	func is_equal(reference : Node) -> bool:
		return _reference == reference

	func __hey_listen(c : Control, out : Array[CodeEdit]) -> bool:
		if c is CodeEdit and out.size() > 0:
			out[0] = c
			return true
		for x : Node in c.get_children():
			if __hey_listen(x, out):
				return true
		return false

	func _i_like_coffe() -> void:
		focus.emit(self)
		var tab : TabContainer = _root

		var parent : Node = tab.get_parent()
		if parent and parent.has_method(&"show_splited_container"):
			parent.call(&"show_splited_container")

		update()
		_helper.update_queue()

	func _init(helper : Object, root : Node, control : Control) -> void:
		_helper = helper
		_root = root

		set_reference(control)

	func set_root(root : Node) -> void:
		_root = root

	func set_reference(control : Node) -> void:
		if !is_instance_valid(control):
			return
		if _reference == control:
			return
		elif is_instance_valid(_reference):
			reset()

		_reference = control
		_control  = null
		_gui = null

		if control is ScriptEditorBase:
			_gui = control.get_base_editor()

			if _gui is CodeEdit:
				var carets : PackedInt32Array = _gui.get_sorted_carets()
				if carets.size() > 0:
					var sc : ScriptEditor = EditorInterface.get_script_editor()
					if is_instance_valid(sc):
						var line : int = _gui.get_caret_line(0)
						if line > _gui.get_line_count():
							line = _gui.get_line_count() - 1
						if line > -1:
							sc.goto_line(line)
			_control = _gui.get_parent()
		else:
			for x : Node in control.get_children():
				if x is RichTextLabel:
					_gui = x
					_control = x
					break

		if _control == null:
			_gui = control
			if control.get_child_count() > 0:
				_gui = control.get_child(0)
			_control = _gui

		_parent = _control.get_parent()

		if null != _gui:
			if !_gui.focus_entered.is_connected(_i_like_coffe):
				_gui.focus_entered.connect(_i_like_coffe)

		if is_instance_valid(_parent):
			_index = _control.get_index()
			_parent.remove_child(_control)

		_root.add_child(_control)

		if _gui:
			if !_gui.is_node_ready():
				await _gui.ready
			if is_instance_valid(_gui):
				_gui.grab_focus()

	func update() -> void:
		if is_instance_valid(_control) and is_instance_valid(_reference):
			var root : TabContainer = _root
			if is_instance_valid(root):
				if _control.get_parent() == root and _reference.get_parent() != null:
					var index : int = _control.get_index()
					if root.get_child_count() > index and index > -1:
						var text : String = _helper.get_item_text(_reference.get_index())
						if !text.is_empty():
							root.set_tab_title(index, text)

	func kill() -> void:
		for x : Node in [_gui, _reference]:
			if is_instance_valid(x) and x.is_queued_for_deletion():
				x.queue_free()

	func reset(disconnect_signals : bool = true) -> void:
		if disconnect_signals and  is_instance_valid(_gui):
			if disconnect_signals and _gui.focus_entered.is_connected(_i_like_coffe):
				_gui.focus_entered.disconnect(_i_like_coffe)
			_gui.modulate = Color.WHITE

		if is_instance_valid(_control):
				if is_instance_valid(_parent):
					var parent : Node = _control.get_parent()
					if parent != _parent:
						if is_instance_valid(parent):
							parent.remove_child(_control)
						_parent.add_child(_control)
						if _parent.is_inside_tree():
							if _index > -1 and _index < _parent.get_child_count():
								_parent.move_child(_control, _index)

		_gui = null
		_parent = null
		_control = null
		_reference = null
		_index = 0

class ReTweener extends RefCounted:
	var _tween : Tween = null
	var _ref : Control = null
	var color : Color = Color.MEDIUM_SLATE_BLUE

	func create_tween(control : Control) -> void:
		if !is_instance_valid(control) or control.is_queued_for_deletion() or !control.is_inside_tree():
			return

		if _ref == control:
			return
		clear()
		_tween = control.get_tree().create_tween()
		_ref = control
		_tween.tween_method(_callback, color, Color.WHITE, 0.35)

	func _callback(c : Color) -> void:
		if is_instance_valid(_ref) and _ref.is_inside_tree():
			_ref.modulate = c
			return
		clear()

	func secure_clear(ref : Object) -> void:
		if !is_instance_valid(_ref) or _ref == ref:
			clear()

	func clear() -> void:
		if _tween:
			if _tween.is_valid():
				_tween.kill()
			_tween = null
			if is_instance_valid(_ref):
				_ref.modulate = Color.WHITE

func _on_focus(tool : Mickeytools) -> void:
	_last_tool = tool
	var ref : Node = _last_tool.get_reference()
	if ref.get_parent() == null:
		return

	var index : int = ref.get_index()
	if index < 0:
		return

	for x : Node in _editor.get_children():
		if x == ref:
			if index > -1 and is_instance_valid(_item_list):
				if _item_list.item_count > index:
					_item_list.item_selected.emit(index)
			break

	if _SPLIT_USE_HIGHLIGHT_SELECTED and _code_editors.size() > 1:
		var control : Node = _last_tool.get_gui()
		if is_instance_valid(control) and control.is_inside_tree():
			if _tweener == null:
				_tweener = ReTweener.new()
			_tweener.color = _SPLIT_HIGHLIGHT_COLOR
			_tweener.create_tween(control)

func _out_it(node : Node, with_signals : bool = false) -> void:
	var has_tween : bool = is_instance_valid(_tweener)
	if has_tween and _code_editors.size() == 0:
		_tweener.clear()
	for x : int in range(_code_editors.size() - 1, -1 , -1):
		var tool : Mickeytools = _code_editors[x]
		if is_instance_valid(tool):
			if tool.is_equal(node):
				if has_tween:
					_tweener.secure_clear(tool.get_control())
				tool.reset(with_signals)
				tool.free()
			else:
				continue
		_code_editors.remove_at(x)

func _setup(editor : TabContainer, setup : bool) -> void:
	const INIT_2 : Array[StringName] = [&"connect", &"disconnect"]
	const INIT_3 : Array[Array] = [[&"tab_changed", &"process_update_queue"],[&"child_entered_tree", &"_on_it"], [&"child_exiting_tree", &"_out_it"]]
	var _2 : StringName = INIT_2[int(!setup)]
	for _3 : Array in INIT_3:
		var _0 : StringName = _3[0]
		if editor.has_signal(_0):
			var _1 : Callable = Callable.create(self, _3[1])
			if editor.is_connected(_0, _1) != setup:
				editor.call(_2, _0, _1)

func _on_sub_change(__ : int, tab : TabContainer) -> void:
	var _tab : int = tab.current_tab
	if _tab > -1 and _tab < tab.get_child_count():
		var control : Control = tab.get_child(_tab)
		if control.get_child_count() > 0:
			for x : Node in control.get_children():
				if x is Control:
					x.grab_focus()
					break
		else:
			control.grab_focus()

func _on_tab_rmb(itab : int, tab : TabContainer) -> void:
	if tab.get_child_count() > itab and itab > -1:
		if is_instance_valid(_item_list):
			var ref : Node = tab.get_child(itab)
			for x : Mickeytools in _code_editors:
				if x.get_control() == ref:
					for e : Node in _editor.get_children():
						if e == x.get_reference():
							var i : int = e.get_index()
							if i > -1 and i < _item_list.item_count:
								_item_list.item_clicked.emit(i, _item_list.get_local_mouse_position(), MOUSE_BUTTON_RIGHT)
							return
					break

func _on_close(itab : int, tab : TabContainer) -> void:
	if tab.get_child_count() > itab and itab > -1:
		if is_instance_valid(_item_list):
			var ref : Node = tab.get_child(itab)
			for x : Mickeytools in _code_editors:
				if x.get_control() == ref:
					for e : Node in _editor.get_children():
						if e == x.get_reference():
							x.reset()
							_code_editors.erase(x)

							x.free()
							var i : int = e.get_index()
							if i > -1 and i < _item_list.item_count:
								_item_list.item_clicked.emit(i, _item_list.get_local_mouse_position(), MOUSE_BUTTON_MIDDLE)
							return
					break

func _on_enter(n : Node, tab : TabContainer) -> void:
	var root : Node = n.get_parent()
	for x : Mickeytools in _code_editors:
		if x.get_root() == root:
			x.update.call_deferred()
			break
	var _v : bool = tab.get_child_count() > 0
	if tab.visible != _v:
		tab.visible = _v

func _on_exit(n : Node, tab : TabContainer) -> void:
	var _v : bool = tab.get_child_count() > 1 or (tab.get_child_count() > 0 and tab.get_child(0) != n)
	if tab.visible != _v:
		tab.visible = _v
	if !is_queued_for_deletion():
		process_update_queue()

func _get_root() -> Control:
	var margin : Root = Root.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var texture : TextureRect = TextureRect.new()
	texture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	texture.texture = preload("res://addons/script_spliter/assets/github_CodeNameTwister.png")
	texture.self_modulate.a = 0.25

	margin.add_child(texture)

	return margin

func _get_container() -> Control:
	var editor : EditorContainer = EditorContainer.new()
	editor.separator_line_size = 4.0
	editor.drag_button_size = 12.0
	editor.behaviour_can_expand_focus_same_container = true
	return editor

func _get_container_edit() -> Control:
	var rtab : DD = DD.new()

	rtab.get_tab_bar().tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ALWAYS

	rtab.drag_to_rearrange_enabled = true

	rtab.get_tab_bar().tab_close_pressed.connect(_on_close.bind(rtab))

	rtab.child_entered_tree.connect(_on_enter.bind(rtab))
	rtab.child_exiting_tree.connect(_on_exit.bind(rtab))

	rtab.visible = false

	var rcall : Callable = _on_sub_change.bind(rtab)

	rtab.tab_changed.connect(rcall)

	rtab.tab_clicked.connect(rcall)

	rtab.get_tab_bar().select_with_rmb = true
	rtab.get_tab_bar().tab_rmb_clicked.connect(_on_tab_rmb.bind(rtab))

	rtab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rtab.size_flags_vertical = Control.SIZE_EXPAND_FILL

	return rtab

func update() -> void:
	_clear()
	if _editor.get_child_count() > 0:
		var root : Node = _get_editor_root()
		if null != root:
			create_code_editor(root, _editor.get_current_tab_control())
		for x : Node in _main.get_children():
			if is_instance_valid(x):
				if x is TabContainer and x.get_child_count() == 0:
					for z : Node in _editor.get_children():
						if create_code_editor(x, z):
							break
				else:
					for y : Node in x.get_children():
						if y is TabContainer and y.get_child_count() == 0:
							for z : Node in _editor.get_children():
								if create_code_editor(y, z):
									break
	
	if !is_instance_valid(_last_tool) or _last_tool.is_queued_for_deletion():
		for z : Mickeytools in _code_editors:
			if is_instance_valid(z):
				_last_tool = z
				break
			_code_editors.erase(z)
			
	_editor.set_deferred(&"visible", true)
					

func is_visible_minimap_required() -> bool:
	return _MINIMAP_4_UNFOCUS_WINDOW

func get_item_text(c : int) -> String:
	var item_list : Control = _item_list
	var text : String = ""
	if c > -1:
		if is_instance_valid(item_list):
			if null != item_list and c < _editor.get_child_count() and item_list.item_count > c:
				text = item_list.get_item_text(c).trim_suffix("(*)")
	return text

func get_aviable() -> Node:
	for x : Node in _main.get_children():
		if x is TabContainer and x.get_child_count() == 0:
			return x
		for y : Node in x.get_children():
			if y is TabContainer and y.get_child_count() == 0:
				return y
	return null

func is_node_valid(root : Node) -> bool:
	return is_instance_valid(root) and root.is_inside_tree()

func create_code_editor(root : Node, editor : Node) -> bool:
	if !is_node_valid(root) or !is_node_valid(editor):
		return false

	if !editor.is_node_ready() or editor.get_child_count() == 0:
		return false

	for x : Mickeytools in _code_editors:
		if x.is_equal(editor):
			return false

	var tool : Mickeytools = null
	var childs : Array[Node] = root.get_children()

	if _code_editors.size() > 0 and childs.size() > 0:
		for m : Mickeytools in _code_editors:
			var o : Node = m.get_gui()
			if o in childs or o.get_parent() in childs:
				tool = m
				break

	if null == tool:
		tool = Mickeytools.new(self, root, editor)
		tool.focus.connect(_on_focus)
		_code_editors.append(tool)
	else:
		tool.reset()
		tool.set_reference(editor)

	if _last_tool == null:
		_last_tool = tool
		tool.focus.emit(tool)
	return true

func update_queue(__ : int = 0) -> void:
	if _plugin:
		_plugin.set_process(true)
	if _main and _container:
		_main.size = _container.size
		_main.update()

#region callback
func _on_it(_node : Node) -> void:
	update_queue(0)

func _on_container_entered() -> void:
	update_queue()

func _on_container_exit() -> void:
	for x : Node in _editor.get_children():
		_out_it(x, true)
	if !is_queued_for_deletion():
		process_update_queue()
#endregion

func remove_split(node : Node) -> void:
	if _code_editors.size() > 1:
		if node is CodeEdit:
			for it : int in range(_code_editors.size() - 1, -1, -1):
				var x : Mickeytools = _code_editors[it]
				if x.get_gui() == node:
					_remove_split_by_control(x.get_control())
					
					x.reset()
					_code_editors.erase(x)
					x.free()
												
					process_update_queue()
					break

func _remove_split_by_control(c : Control) -> void:
	for x : Node in _main.get_children():
		if x is TabContainer:continue
		if x.get_child_count() > 0:
			for y : Node in x.get_children():
				for z : Node in y.get_children():
					if z == c:
						_main.remove_child(x)
						return

func _get_unused_editor_control() -> Array[Node]:
	var out : Array[Node] = []
	for x : Node in _editor.get_children():
		var exist : bool = false
		for m : Mickeytools in _code_editors:
			if m.get_reference() == x:
				exist = true
				break
		if !exist:
			out.append(x)
	return out

func _free_editor_container(control : Control) -> bool:
	if control.get_parent() == _main:
		for c : Mickeytools in _code_editors:
			var _a : Node = c.get_control().get_parent()
			var b : Node = control
			if _a == b or _a.get_parent() == b:
				c.reset()
				_code_editors.erase(c)
				c.free()
				break
		_main.remove_child(control)
		control.queue_free()
		return true
	return false

func build(editor : TabContainer, columns : int = 0, rows : int = 0) -> void:
	_setup(editor, true)
	
	var root : Node = editor.get_parent()
	if is_instance_valid(root) and !(root is Root):
		_root = root

	if is_instance_valid(_editor) and _editor != editor:
		if _editor.tree_entered.is_connected(_on_container_entered):
			_editor.tree_entered.disconnect(_on_container_entered)

		if _editor.tree_exiting.is_connected(_on_container_exit):
			_editor.tree_exiting.disconnect(_on_container_exit)

	_editor = editor

	if !_editor.tree_entered.is_connected(_on_container_entered):
		_editor.tree_entered.connect(_on_container_entered)

	if !_editor.tree_exiting.is_connected(_on_container_exit):
		_editor.tree_exiting.connect(_on_container_exit)

	if !is_instance_valid(_container):
		_container = _get_root()

	if !is_instance_valid(_main):
		_main = _get_container()

	_editor_min_size = _editor.custom_minimum_size
	_editor.custom_minimum_size = Vector2.ZERO
	_editor.size_flags_vertical = Control.SIZE_FILL
	_editor.set_script(ETAB)

	root = _container.get_parent()

	if root != _root:
		if is_instance_valid(root):
			root.remove_child(_container)
		var index : int = _editor.get_index()
		_root.add_child(_container)
		_root.move_child(_container, index)

	root = _main.get_parent()
	if root != _container:
		if is_instance_valid(root):
			root.remove_child(_main)
		_container.add_child(_main)

	_container.size = _container.get_parent().size
	_container.anchor_left = 0.0
	_container.anchor_top = 0.0
	_container.anchor_right = 1.0
	_container.anchor_bottom = 1.0

	_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	_main.behaviour_expand_on_focus = true
	_main.behaviour_expand_on_double_click = true


	_main.visible = true
	
	update_config()

	update_build(columns, rows)

func find_editor(node : Node) -> Control:
	for x : Node in _main.get_children():
		for y : Node in x.get_children():
			if y == node:
				return x
	return null

func can_remove_split(node : Node) -> bool:
	if !is_instance_valid(_main):
		return false
	if _code_editors.size() > 1:
		if node is CodeEdit:
			for x : Mickeytools in _code_editors:
				if x.get_gui() == node:
					return true
	return false

func can_add_split(_node : Node) -> bool:
	if !is_instance_valid(_main):
		return false
	var unused : Array[Node] =_get_unused_editor_control()
	if unused.size() > 0:
		return true
	return false

func add_split(control : Node) -> void:
	var unused : Array[Node] = _get_unused_editor_control()
	if unused.size() == 0:
		print("[INFO] Not aviable split!")
		return

	var current_unused : Node = control

	var tool : Mickeytools = null
	for x : Mickeytools in _code_editors:
		if x.is_equal(control) or x.get_gui() == control:
			current_unused = null
			break

	var root : Control = get_aviable()
	if root == null:
		var broot : Node = _main.make_split_container_item()
		root = _get_container_edit()
		broot.add_child(root)
		_main.add_child(broot)

	if null == current_unused:
		current_unused = unused[0]

	tool = Mickeytools.new(self, root, current_unused)
	tool.focus.connect(_on_focus)
	_code_editors.append(tool)

	if _last_tool == null:
		_last_tool = tool
		tool.focus.emit(tool)
			
	process_update_queue()
	
func get_current_columns_and_rows() -> Array[int]:
	var out : Array[int] = [0, 0]
	if is_instance_valid(_main):
		var columns : int = _main.max_columns
		var container : int = _main.get_child_count()
		if container > 0 and columns > 0:
			@warning_ignore("integer_division")
			container = int(container / columns)
		out[0] = columns
		out[1] = container
	return out
	
func update_build(columns : int, rows : int) -> void:
	current_columns = maxi(columns, 0)
	current_rows = maxi(rows, 0)

	var totals : int = maxi(current_columns * current_rows, 1)
	_main.max_columns = current_columns

	while _main.get_child_count() > totals:
		if !_free_editor_container(_main.get_child(_main.get_child_count() - 1)):
			break

	while _main.get_child_count() < totals:
		var broot : Node = _main.make_split_container_item()
		var root : Node = _get_container_edit()
		broot.add_child(root)
		_main.add_child(broot)

	var aviable : Node = get_aviable()
	while aviable != null:
		var unused : Array[Node] = _get_unused_editor_control()
		if unused.size() == 0:
			break
		if !create_code_editor(aviable, unused[0]):
			break
		aviable = get_aviable()
	
	process_update_queue()

func process_update_queue(__ : int = 0) -> void:
	update_queue(__)
	update_queue.call_deferred(__)
