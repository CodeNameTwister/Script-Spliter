@tool
extends Popup
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	Script Splitter
#	https://github.com/CodeNameTwister/Script-Splitter
#
#	Script Splitter addon for godot 4
#	author:		"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

signal accepted()
signal canceled()

@export var _ok : Button
@export var _cancel : Button

func _on_hide() -> void:
	queue_free()

func _ready() -> void:
	popup_hide.connect(_on_hide)
	_ok.pressed.connect(_on_ok)
	_cancel.pressed.connect(_on_cancel)
	
func _on_ok() -> void:
	accepted.emit()
	hide()
	
func _on_cancel() -> void:
	canceled.emit()
	hide()
