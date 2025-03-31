@tool
extends MarginContainer
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
const ALPHA_TEXT_NAME : float = 0.55
const LABEL_RES : Resource = preload("res://addons/script_spliter/label.gd")

const PLACEHOLDER_IMAGE : Texture = preload("res://addons/script_spliter/assets/placeholder.png")
const STYLE_SEPARATOR : StyleBox = preload("res://addons/script_spliter/assets/style_sep.tres")

const USE_VISIBILITY_ON_WINDOWS : bool = false

var slots : Array[Slot] = []
var lbls : Array[Label] = []

var base : TabContainer = null
var _last_sc : Control = null
var _flg_chg : bool = false

var _current_type_split : int = 0


func _on_enter_callback() -> void:
	if is_queued_for_deletion():
		return
	if is_inside_tree():
		await get_tree().process_frame
	set_base.call_deferred(base)

func on_exiting_tree() -> void:
	if is_instance_valid(base):
		if is_queued_for_deletion():
			if base.tab_changed.is_connected(tab_changed):
				base.tab_changed.disconnect(tab_changed)
			if base.child_exiting_tree.is_connected(_on_tab_exit):
				base.child_exiting_tree.disconnect(_on_tab_exit)
			if base.item_rect_changed.is_connected(_on_update_rect):
				base.item_rect_changed.disconnect(_on_update_rect)

func _ready() -> void:
	if !tree_exiting.is_connected(on_exiting_tree):
		tree_exiting.connect(on_exiting_tree)
	if !tree_exiting.is_connected(_on_enter_callback):
		tree_exiting.connect(_on_enter_callback)

	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	create_slot(self)

func _update_gui() -> void:
	var sames : Dictionary = {}
	for x : Slot in slots:
		for r : Rub in [x.left, x.right]:
			var element : Node = r.get_container_element()
			var is_current : bool = element == base
			var container : Node = r.get_base_control()
			var valid_ref : bool = is_instance_valid(r.instance_ref)
			if container:
				var label : Node = container.get_parent().find_child("sc_name", true, false)
				if is_instance_valid(label):
					label.text = ""
					if valid_ref:
						if r.instance_ref is ScriptEditorBase:
							var _c : int = r.instance_ref.get_index()
							if _c < base.get_child_count() and _c > -1:
								label.text = base.get_item_text(_c)
					if is_current:
						var _c : Color = Color.CYAN
						_c.a =  min(ALPHA_TEXT_NAME + 0.25, 1.0)
						label.set_new_color(_c, true)

						if USE_VISIBILITY_ON_WINDOWS:
							r.get_base_control().get_parent().visible = true

						var bc : SplitContainer = x.get_base_control()
						var _size : float = 0.0

						if x.left == r:
							if r.instance_ref == null:
								if bc.vertical:
									_size = bc.get_rect().size.y
								else:
									_size = bc.get_rect().size.x
								bc.split_offset = int(_size)
							else:
								if bc.split_offset < _size:
									bc.split_offset = 0
						if x.right == r:
							if r.instance_ref == null:
								if bc.vertical:
									_size = bc.get_rect().size.y
								else:
									_size = bc.get_rect().size.x
								bc.split_offset = -int(_size)
							else:
								if bc.split_offset > _size:
									bc.split_offset = 0
						bc.clamp_split_offset()
					else:
						var _c : Color = Color.ORANGE
						_c.a = ALPHA_TEXT_NAME
						label.set_new_color(_c, false)

						if r.instance_ref == null:
							if USE_VISIBILITY_ON_WINDOWS:
								if element == r._placeholder_tx:
									var cr : Control = x.right.get_base_control().get_parent()
									var cl : Control = x.left.get_base_control().get_parent()
									if r == x.left:
										if cr.visible == true:
											cl.visible = false
									elif r == x.right:
										if cl.visible == true:
											cr.visible = false
							else:
								var bc : SplitContainer = x.get_base_control()
								var _size : float = 0.0
								if x.left == r:
									if bc.vertical:
										_size = bc.get_rect().size.y
									else:
										_size = bc.get_rect().size.x
									bc.split_offset = -int(_size)
								if x.right == r:
									if bc.vertical:
										_size = bc.get_rect().size.y
									else:
										_size = bc.get_rect().size.x
									bc.split_offset = int(_size)
			if valid_ref:
				if sames.has(r.instance_ref):
					var i : int = r.instance_ref.get_index()
					if base.current_tab == i:
						if r.get_container_element() == base:
							var _r : Rub = sames[r.instance_ref]
							if _r.get_container_element() != base:
								_r.reset()
								sames[r.instance_ref] = r
								push_warning("PREVENTION")
								continue
					r.reset()
				else:
					sames[r.instance_ref] = r

func tab_changed(tab: int) -> void:
	if _flg_chg:return
	_flg_chg = true
	await get_tree().process_frame
	if !is_instance_valid(base):return

	tab = base.current_tab

	for s : Slot in slots:
		if !s.left.is_valid_reference():
			s.left.reset()
		if !s.right.is_valid_reference():
			s.right.reset()

	if base.get_child_count() < 2:
		_last_sc = null
		if base.get_child_count() == 1:
			_last_sc = base.get_child(0)

	if tab < 0 or base.get_child_count() <= tab or !is_instance_valid(base):
		_update_gui()
		if base.get_child_count() < 1:
			for s : Slot in slots:
				if s.left.get_container_element() == base:
					var sp : SplitContainer = s.get_base_control()
					var vsize : float = sp.get_rect().size.x
					if sp.vertical:
						vsize = sp.get_rect().size.y
					sp.set(&"split_offset", -vsize)
					sp.clamp_split_offset()
					break
				elif s.right.get_container_element() == base:
					var sp : SplitContainer = s.get_base_control()
					var vsize : float = sp.get_rect().size.x
					if sp.vertical:
						vsize = sp.get_rect().size.y
					sp.set(&"split_offset", vsize)
					sp.clamp_split_offset.call()
					break
		set_deferred(&"_flg_chg", false)
		return

	var nw : Control = base.get_child(tab)
	var is_editor : bool = nw is ScriptEditorBase
	var exist : bool = false
	var _last_know : Rub = null

	if nw is ScriptEditorBase:
		for s : Slot in slots:
			if s.left.instance_ref == nw:
				exist = true
				_last_know = s.left
				break
			if s.right.instance_ref == nw:
				exist = true
				_last_know = s.right
				break

		if !exist:
			var same_ctx : bool = false
			if !is_instance_valid(_last_sc) or _last_sc is ScriptEditorBase:
				for s : Slot in slots:
					var r : Rub = s.get_aviable()
					if is_instance_valid(r):
						r.set_reference(base)
						var _current : int = base.current_tab
						if base.get_child_count() > _current:
							_last_sc = base.get_child(_current)
						same_ctx = true
						break
			if !same_ctx:
				var current : int = base.current_tab
				if base.get_child_count() > current:
					_last_sc = base.get_child(current)
				if is_editor:
					for s : Slot in slots:
						var r : Rub = s.get_rub_by(base)
						if is_instance_valid(r):
							r.instance_ref = nw
							if base.tree_exited.is_connected(r.on_exit_reference):
								base.tree_exited.disconnect(r.on_exit_reference)
							if is_instance_valid(nw):
								base.tree_exited.connect(r.on_exit_reference.bind(nw), CONNECT_ONE_SHOT)
							break
		else:
			_last_know.set_reference(base)
			var current : int = base.current_tab
			if base.get_child_count() > current:
				_last_sc = base.get_child(current)
			for s : Slot in slots:
				if _last_know != s.left and s.left.instance_ref == _last_know.instance_ref:
					s.left.reset()
					break
				if _last_know !=  s.right  and s.right.instance_ref == _last_know.instance_ref:
					s.right.reset()
					break
			if is_editor:
				if base.tree_exited.is_connected(_last_know.on_exit_reference):
					base.tree_exited.disconnect(_last_know.on_exit_reference)
				if is_instance_valid(nw):
					base.tree_exited.connect(_last_know.on_exit_reference.bind(nw), CONNECT_ONE_SHOT)
	_update_gui()
	set_deferred(&"_flg_chg", false)

class Rub extends Object:
	var _slot : Slot = null
	var _container : Control = null
	var instance_ref : Control = null

	var _placeholder_tx : Control = null
	var _placeholder_edit : Control = null

	var index : int = 0

	#region 0
	func _init(slot : Slot, control : Control, set_index : int) -> void:
		index = set_index
		_slot = slot
		_container = control

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			if is_instance_valid(_container) and !_container.is_queued_for_deletion():
				if !(_container is TabContainer):
					_container.propagate_call(&"queue_free")
			if is_instance_valid(_placeholder_tx) and !_placeholder_tx.is_queued_for_deletion():
				_placeholder_tx.propagate_call(&"queue_free")
			if is_instance_valid(_placeholder_edit) and !_placeholder_edit.is_queued_for_deletion():
				var settings : EditorSettings = EditorInterface.get_editor_settings()
				if settings.settings_changed.is_connected(_on_change_settings):
					settings.settings_changed.disconnect(_on_change_settings)
				_placeholder_edit.propagate_call(&"queue_free")
			instance_ref = null
			if !is_queued_for_deletion():
				call_deferred(&"free")
	#endregion

	#region 1
	func clear_by(sc : Control, base : Control) -> bool:
		if instance_ref == sc:
			if base and base.tree_exited.is_connected(on_exit_reference):
				base.tree_exited.disconnect(on_exit_reference)
			var child : Node = get_container_element()
			if is_instance_valid(child):
				if child is CodeEdit:
					_container.remove_child(child)
					_placeholder_edit = child
					child = null

			if child == null:
				if _placeholder_tx == null:
					_placeholder_tx = _slot.create_placeholder()
				child = _placeholder_tx

			if child and child.get_parent() == null:
				_container.add_child(child)
			instance_ref = null
			return true
		return false

	func get_base_control() -> Control:
		return _container

	func set_control(ctrl : Control) -> void:
		_container = ctrl

	func _on_change_settings() -> void:
		var settings : EditorSettings = EditorInterface.get_editor_settings()
		if settings:
			_placeholder_edit.minimap_draw = settings.get_setting("plugin/script_spliter/minimap_for_unfocus_window")

	func on_exit_reference(ref : Variant = null) -> void:
		var child : Node = get_container_element()
		if is_instance_valid(ref):
			if !ref.is_queued_for_deletion():
				if ref is ScriptEditorBase:
					var be : Control = ref.get_base_editor()
					if be is CodeEdit:
						if !(child is CodeEdit):
							if null != child:
								var p : Node = child.get_parent()
								if p:
									p.remove_child.call_deferred(child)
							if (child is TextureRect):
								_placeholder_tx = child
							if _placeholder_edit == null:
								child = be.duplicate()
								_placeholder_edit = child
								var settings : EditorSettings = EditorInterface.get_editor_settings()
								if settings:
									_placeholder_edit.minimap_draw = settings.get_setting("plugin/script_spliter/minimap_for_unfocus_window") as bool
									if !settings.settings_changed.is_connected(_on_change_settings):
										settings.settings_changed.connect(_on_change_settings)
							else:
								child = _placeholder_edit
						if is_instance_valid(_placeholder_edit):
							_placeholder_edit.set_deferred(&"text", be.text)

							for cr : int in be.get_sorted_carets(true):
								_placeholder_edit.set_caret_column.call_deferred(be.get_caret_column(cr), true, cr)
								_placeholder_edit.set_caret_line.call_deferred(be.get_caret_line(cr), true, true, be.get_caret_wrap_index(cr), cr)

							_placeholder_edit.set_selection_origin_line.call_deferred(be.get_selection_origin_line())
							_placeholder_edit.get_v_scroll_bar().set_deferred(&"value", be.get_v_scroll_bar().value)
							_placeholder_edit.get_h_scroll_bar().set_deferred(&"value", be.get_h_scroll_bar().value)
							_placeholder_edit.set_selection_origin_column.call_deferred(be.get_selection_origin_column())

						var root : Control = _slot.get_root()
						if !child.gui_input.is_connected(root.on_gui):
							child.gui_input.connect(root.on_gui.bind(_slot, child))

						get_base_control().get_parent().visible = true
		if child == null:
			if _placeholder_tx == null:
				_placeholder_tx = _slot.create_placeholder()
			child = _placeholder_tx
		if child.get_parent() == null:
			if _container.is_inside_tree():
				_container.add_child(child)
			else:
				_container.add_child.call_deferred(child)

	func reset() -> void:
		var child : Node = get_container_element()
		if child is CodeEdit:
			_container.remove_child(child)
			_placeholder_edit = child
			child = null

		if child == null:
			if _placeholder_tx == null:
				_placeholder_tx = _slot.create_placeholder()
			child = _placeholder_tx

		if child and child.get_parent() == null:
			_container.add_child(child)

			if self == _slot.left:
				var p : SplitContainer = _slot.get_base_control()
				p.split_offset = int(p.size.x)
				p.clamp_split_offset()
			if self == _slot.right:
				var p : SplitContainer = _slot.get_base_control()
				p.split_offset = 0
				p.clamp_split_offset()

			instance_ref = null

	func get_container_element() -> Control:
		if _container.get_child_count() > 0:
			return _container.get_child(0)
		return null

	func set_reference(container : TabContainer) -> void:
		if !is_instance_valid(container):return
		var parent_container : Node = container.get_parent()

		if _container == parent_container:
			return

		if parent_container != null and parent_container != _container:
			parent_container.remove_child(container)

		var current_ref : Control = null
		var child : Node = get_container_element()

		var csize : int =  container.get_child_count()
		if container.current_tab > -1 and container.current_tab < csize and csize > 0:
			current_ref = container.get_child(container.current_tab)

		if child:
			_container.remove_child(child)
			if child is CodeEdit:
				_placeholder_edit = child
			elif child is TextureRect:
				_placeholder_tx = child
			else:
				child.visible = false
				Engine.get_main_loop().root.add_child(child)
				child.propagate_call(&"queue_free")
			child = null

		if container.get_parent() != _container:
			_container.add_child(container)

		if is_instance_valid(instance_ref) and instance_ref.get_parent() == container:
			container.current_tab = instance_ref.get_index()
			if csize > 0:
				current_ref = container.get_child(container.current_tab)
			if current_ref != null:
				var c : Node = current_ref.get_base_editor()

				for cr : int in _placeholder_edit.get_sorted_carets(true):
					c.set_caret_column.call_deferred(_placeholder_edit.get_caret_column(cr), true, cr)
					c.set_caret_line.call_deferred(_placeholder_edit.get_caret_line(cr), true, true, _placeholder_edit.get_caret_wrap_index(cr), cr)

				c.set_selection_origin_line.call_deferred(_placeholder_edit.get_selection_origin_line())
				c.get_v_scroll_bar().set_deferred(&"value", _placeholder_edit.get_v_scroll_bar().value)
				c.get_h_scroll_bar().set_deferred(&"value", _placeholder_edit.get_h_scroll_bar().value)
				c.set_selection_origin_column.call_deferred(_placeholder_edit.get_selection_origin_column())
		else:
			if current_ref == instance_ref and current_ref != null and _placeholder_edit:
				var c : CodeEdit = current_ref.get_base_editor()
				_placeholder_edit.set_deferred(&"text", c.text)

				for cr : int in c.get_sorted_carets(true):
					_placeholder_edit.set_caret_column.call_deferred(c.get_caret_column(cr), true, cr)
					_placeholder_edit.set_caret_line.call_deferred(c.get_caret_line(cr), true, true, c.get_caret_wrap_index(cr), cr)

				_placeholder_edit.set_selection_origin_line.call_deferred(c.get_selection_origin_line())
				_placeholder_edit.set_selection_origin_column.call_deferred(c.get_selection_origin_column())
				_placeholder_edit.get_v_scroll_bar().set_deferred(&"value", c.get_v_scroll_bar().value)
				_placeholder_edit.get_h_scroll_bar().set_deferred(&"value", c.get_h_scroll_bar().value)

			instance_ref = current_ref


		if container.tree_exited.is_connected(on_exit_reference):
			container.tree_exited.disconnect(on_exit_reference)

		container.tree_exited.connect(on_exit_reference.bind(instance_ref), CONNECT_ONE_SHOT)


	func is_valid_reference() -> bool:
		return is_instance_valid(instance_ref) and instance_ref.get_parent() != null

	func is_empty() -> bool:
		var child : Node = get_container_element()
		if !is_instance_valid(child):
			return true
		return !(child is CodeEdit) and !(child is TabContainer)
	#endregion

func create_slot(root : Node = self) -> SplitContainer:
	var slot : Slot = Slot.new(root, STYLE_SEPARATOR)
	slots.append(slot)
	return slot.get_base_control()

func on_gui(e : InputEvent, slot : Slot, placeholder : Control) -> void:
	if e is InputEventMouseButton:
		if e.pressed and (e.button_index > 0 and e.button_index < 4):
			var rub : Rub = slot.get_rub_by(placeholder)
			if rub:
				var tab : int = (base as TabContainer).current_tab
				if tab > -1:
					rub.set_reference(base)
					return
				push_warning("Can not find active id ", tab)
				return
			push_warning("Can not find references!")

func _on_tab_exit(n : Node) -> void:
	if is_instance_valid(n):
		if n.get_parent() != base:
			for s : Slot in slots:
				s.clear_ref(n, base)

class Slot extends Object:
	var _root : Control = null
	var _base : SplitContainer = null
	var left : Rub = null
	var right : Rub = null

	var next_rub : Rub = null

	func get_root() -> Control:
		return _root

	func get_rub_by(placeholder : Control) -> Rub:
		if left.get_container_element() == placeholder:
			return left
		if right.get_container_element() == placeholder:
			return right
		return null

	func get_base_control() -> SplitContainer:
		return _base

	func set_left_reference(tab : TabContainer) -> void:
		left.set_reference(tab)

	func set_right_reference(tab : TabContainer) -> void:
		right.set_reference(tab)

	func _on_text_change(label : Label) -> void:
		if is_instance_valid(label):
			var _p : Control = label.get_parent()
			label.visible = _p.size.y >= label.size.x + 4.0
			label.position.y = (label.size.x * 0.5) + _p.size.y * 0.5


	func _on_rect_change(pl : Control) -> void:
		if pl.get_child_count() > 0:
			var c : Control = pl.get_child(0)
			if c is TextureRect:
				var _min : float = min(pl.size.x - 50.0, pl.size.y - 50.0, 128.0)
				c.custom_minimum_size = Vector2(_min, _min)

	func create_container_placeholder() -> Control:
		var root : Control = MarginContainer.new()
		var placeholder : Control = MarginContainer.new()

		placeholder.item_rect_changed.connect(_on_rect_change.bind(placeholder))

		var control : Control = Panel.new()
		var label : Label = Label.new()

		control.set("theme_override_styles/panel", StyleBoxEmpty.new())

		label.set_script(LABEL_RES)

		label.rotation_degrees = -90.0

		root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		root.size_flags_vertical = Control.SIZE_EXPAND_FILL
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.size_flags_horizontal = Control.SIZE_SHRINK_END
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.name = &"sc_name"
		root.clip_contents = true

		root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		root.size_flags_vertical = Control.SIZE_EXPAND_FILL
		placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL

		label.set(&"theme_override_font_sizes/font_size", 12)
		label.text = ""
		label.position.y = label.size.x

		label.item_rect_changed.connect(_on_text_change.bind(label))

		placeholder.add_child(create_placeholder())

		control.add_child(label)
		root.add_child(placeholder)
		root.add_child(control)

		placeholder.owner = root

		return placeholder

	func _on_placeholder_enter(c : Control) -> void:
		var v : Control = c.get_parent()
		var s : Signal = v.item_rect_changed
		s.emit.call_deferred()


	func create_placeholder() -> Control:
		var placeholder : TextureRect = TextureRect.new()
		placeholder.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		placeholder.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		placeholder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		placeholder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		placeholder.texture = PLACEHOLDER_IMAGE
		placeholder.modulate.a = 0.4
		placeholder.gui_input.connect(_root.on_gui.bind(self, placeholder))
		placeholder.tree_entered.connect(_on_placeholder_enter.bind(placeholder))

		return placeholder

	func _init(root : Control, style : StyleBox = null) -> void:
		_root = root
		_base = SplitContainer.new()

		if style:
			_base.set(&"theme_override_styles/split_bar_background", style)

		var control0 : Control = create_container_placeholder()
		var control1 : Control = create_container_placeholder()

		_base.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_base.size_flags_vertical = Control.SIZE_EXPAND_FILL

		_base.add_child(control0.owner)
		_base.add_child(control1.owner)

		left = Rub.new(self, control0, 0)
		right = Rub.new(self, control1, 1)

		_root.add_child(_base)

		if _base.vertical:
			_base.split_offset = int(_root.size.y)
		else:
			_base.split_offset = int(_root.size.x)
		_base.clamp_split_offset()

	func clear_ref(sc : Control, base : TabContainer) -> bool:
		return left.clear_by(sc, base) or right.clear_by(sc, base)

	func get_aviable() -> Rub:
		if left.is_empty():
			return left
		if right.is_empty():
			return right
		return null

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			if is_instance_valid(left):
				left._notification(what)
			if is_instance_valid(right):
				left._notification(what)
			if is_instance_valid(_base):
				_base.propagate_call(&"queue_free")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for s : Slot in slots:
			if is_instance_valid(s):
				if is_instance_valid(s.left):
					s.left._notification(NOTIFICATION_PREDELETE)
				if is_instance_valid(s.right):
					s.right._notification(NOTIFICATION_PREDELETE)
				s.free()
		slots.clear()

func _on_update_rect() -> void:
	for s : Slot in slots:
		var ctrl : Control = s.get_base_control()
		for x : Node in ctrl.find_children("*", "Label", true, false):
			x.position.y = (x.size.x * 0.5) + x.get_parent().size.y * 0.5

func set_base(new_base : TabContainer) -> void:
	if !is_instance_valid(new_base):
		if base:
			if base.tab_changed.is_connected(tab_changed):
				base.tab_changed.disconnect(tab_changed)
			if base.child_exiting_tree.is_connected(_on_tab_exit):
				base.child_exiting_tree.disconnect(_on_tab_exit)
			if base.item_rect_changed.is_connected(_on_update_rect):
				base.item_rect_changed.disconnect(_on_update_rect)
		return
	base = new_base
	new_base.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_base.size_flags_vertical = Control.SIZE_EXPAND_FILL

	if !new_base.tab_changed.is_connected(tab_changed):
		new_base.tab_changed.connect(tab_changed)
	if !new_base.child_exiting_tree.is_connected(_on_tab_exit):
		new_base.child_exiting_tree.connect(_on_tab_exit)
	if !new_base.item_rect_changed.is_connected(_on_update_rect):
		new_base.item_rect_changed.connect(_on_update_rect)

	if slots.size() > 0:
		slots[0].set_left_reference(new_base)

	var i : int = new_base.current_tab
	if new_base.get_child_count() > i and i > -1:
		_last_sc = new_base.get_child(i)

	tab_changed(i)

func set_split_type(type : int, as_toggle : bool) -> void:
	if type == 0:
		_current_type_split = 0
		return
	if as_toggle:
		if type == _current_type_split:
			if type == 1:
				type = 2
			elif type == 2:
				type = 1

	if type == 1:
		for s : Slot in slots:
			var c : SplitContainer = s.get_base_control()
			c.vertical = false
	elif  type == 2:
		for s : Slot in slots:
			var c : SplitContainer = s.get_base_control()
			c.vertical = true
	else:
		push_warning("Not valid split type!")
		return
	_current_type_split = type
