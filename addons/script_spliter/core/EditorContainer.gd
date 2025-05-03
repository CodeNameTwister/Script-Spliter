@tool
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Spliter
#	https://github.com/CodeNameTwister/Script-Spliter
#
#	Script Spliter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

extends "res://addons/script_spliter/core/ui/multi_split_container.gd"

const PREVIEW : PackedScene = preload("res://addons/script_spliter/context/panel_preview.tscn")

var preview : Control = null
#var _last_container_dd : Control = null

func get_total_containers() -> int:
	var total : int = 0
	for x : Node in get_children():
		if x is SplitContainerItem:
			if x.get_child_count() > 0:
				total += 1
	return total

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(preview) and !preview.is_queued_for_deletion():
			preview.queue_free()

func make_split_container_item() -> Control:
	var x : SplitContainerItem = SplitContainerItem.new()
	x.size_flags_horizontal = Control.SIZE_FILL
	x.size_flags_vertical = Control.SIZE_FILL
	x.custom_minimum_size = Vector2.ZERO
	x.clip_contents = true
	x.visible = false
	return x

# v3
#func enable_drag_and_drop(enable : bool, exception : Control = null) -> void:
	#_last_container_dd = exception
	#if preview == null:
		#preview = PREVIEW.instantiate()
	#preview.visible = false
	#preview.z_index = 4000
	#for x : Node in get_children():
		#x.set(&"focus_handler", enable)

func in_focus(_node : Node) -> void:
	return
	#if _last_container_dd != node:
		#node = _last_container_dd
		#var parent : Node = preview.get_parent()
		#if parent != node:
			#if is_instance_valid(parent):
				#parent.remove_child(preview)
			#node.add_child(preview)
		#preview.visible = true

func has_items() -> bool:
	return get_child_count() > 0

func is_split_container_item(x : Object) -> bool:
	return x is SplitContainerItem
	
