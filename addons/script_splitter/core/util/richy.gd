@tool
extends RichTextLabel

var _ref : Control = null
var _wait : float = 0.0
var _treshold : float = 0.05

func _update() -> void:
	_wait = 0.0
	set_process(true)

func _draw() -> void:
	if size != _ref.size:
		_update()

func _on_change() -> void:
	_update()
	
func _process(delta: float) -> void:
	_wait += delta
	if _wait < _treshold:
		return
		
	var _global_rect : Rect2 = _ref.get_rect()
	var offset : float = 500.0 * EditorInterface.get_editor_scale()
	var operation : float = _global_rect.size.x/offset*0.85
	
	position.x = -offset
	size = _global_rect.size
	
	if operation < 1.0:
		size.x += (offset * (_global_rect.size.x/offset*0.85))
	else:
		size.x += offset * (size.x/400.0)
		
	set_process(false)

func set_reference(c : Control) -> void:
	if _ref:
		if _ref.item_rect_changed.is_connected(_on_change):
			_ref.item_rect_changed.disconnect(_on_change)
	_ref = c
	if _ref:
		if !_ref.item_rect_changed.is_connected(_on_change):
			_ref.item_rect_changed.connect(_on_change)
	_update.call_deferred()
