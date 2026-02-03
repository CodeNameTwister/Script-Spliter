@tool
extends "./../../../core/editor/tools/editor_tool.gd"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Splitter
#	https://github.com/CodeNameTwister/Script-Splitter
#
#	Script Splitter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

func _fallback(ctrl : Control, expt : int = 200) -> void:
	if !is_instance_valid(ctrl) or !is_instance_valid(ctrl.get_parent()) or expt < 1:
		if expt == 0:
			var n : Node = ctrl.get_parent()
			while is_instance_valid(n) and n is Control:
				ctrl.size = n.size
				if ctrl.size.x >= 50.0 or ctrl.size.y >= 50.0:
					ctrl.visible = false
					ctrl.set_deferred(&"visible", true)
					ctrl.item_rect_changed.emit.call_deferred()
					return
				n = n.get_parent()
		return
		
	if ctrl.size.x < 50.0 or ctrl.size.y < 50.0:
		ctrl.set_deferred(&"size_flags_vertical", Control.SIZE_EXPAND_FILL)
		ctrl.set_deferred(&"size_flags_horizontal", Control.SIZE_EXPAND_FILL)
		var pnode : Node = ctrl.get_parent()
		
		ctrl.visible = false
		ctrl.set_deferred(&"visible", true)
		
		if pnode is Control:
			ctrl.size = pnode.size
			ctrl.set_deferred(&"visible", true)
			ctrl.item_rect_changed.emit.call_deferred()
		else:
			ctrl.set_deferred(&"visible", true)
		
		_fallback.call_deferred(ctrl, expt - 1)
		

func _build_tool(control : Node) -> MickeyTool:
	if control is ScriptEditorBase:
		return null
	if control.name.begins_with("@"):
		return null
	
	var mickey : MickeyTool = null
	for x : Node in control.get_children():
		if x is RichTextLabel:
			var canvas : VBoxContainer = VBoxContainer.new()
		
			var childs : Array[Node] = control.get_children()
			canvas.size = control.size
			canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
			canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			for n : Node in childs:
				control.remove_child(n)
				canvas.add_child(n)
					
			mickey = MickeyToolRoute.new(control, canvas, canvas)
			for z : Node in canvas.get_children():
				if z is RichTextLabel:
					_fallback(z)
			break
	return mickey

func _handler(control : Node) -> MickeyTool:
	var mickey : MickeyTool = null
	if control is RichTextLabel:
		var canvas : VBoxContainer = VBoxContainer.new()
		canvas.size = control.size
		canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
		canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		canvas.size = control.size
		
		if canvas.get_child_count() < 1:
			var childs : Array[Node] = control.get_children()
			for n : Node in childs:
				control.remove_child(n)
				canvas.add_child(n)
				
		mickey = MickeyToolRoute.new(control, canvas, canvas)
		
		for z : Node in canvas.get_children():
			if z is RichTextLabel:
				_fallback(z)
	return mickey
