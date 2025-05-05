@tool
extends Button

func _pressed() -> void:
	var parent : Node = owner
	if parent == null:
		parent = get_parent()
	if parent:
		if parent.has_method(name):
			parent.call(name)
