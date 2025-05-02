@tool
extends TabContainer
		
func _on_change(__ : int) -> void:
	set_deferred(&"visible" , false)
	
func _init() -> void:
	setup(1)	

func setup(init : int) -> void:
	if init != 0:
		if !tab_changed.is_connected(_on_change):
			tab_changed.connect(_on_change)
	else:
		if tab_changed.is_connected(_on_change):
			tab_changed.disconnect(_on_change)
		for x : Node in get_children():
			if x is Control:
				x.visible = true
		
