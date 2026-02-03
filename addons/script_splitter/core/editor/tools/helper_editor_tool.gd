@tool
extends "./../../../core/editor/tools/editor_tool.gd"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Splitter
#	https://github.com/CodeNameTwister/Script-Splitter
#
#	Script Splitter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

func _fallback(ctrl : Control, expt : int = 5) -> void:
	if !is_instance_valid(ctrl) or expt < 1:
		return
	
	if ctrl.size.x < 100.0 or ctrl.size.y < 100.0:
		ctrl.set_deferred(&"size_flags_vertical", Control.SIZE_EXPAND_FILL)
		ctrl.set_deferred(&"size_flags_horizontal", Control.SIZE_EXPAND_FILL)
		
		var pnode : Node = ctrl.get_parent()
		if pnode is Control:
			ctrl.size = pnode.size
			
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
			
			for n : Node in childs:
				control.remove_child(n)
				canvas.add_child(n)
					
			canvas.size = control.size
			canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
			canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
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
		canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
		canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		if canvas.get_child_count() < 1:
			var childs : Array[Node] = control.get_children()
			for n : Node in childs:
				control.remove_child(n)
				canvas.add_child(n)
				
		canvas.size = control.size
		mickey = MickeyToolRoute.new(control, canvas, canvas)
	return mickey
