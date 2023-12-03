extends RigidBody3D

signal grabbed
signal ungrabbed

var left_side : bool = true
var should_delete_on_let_go : bool = false


func grab() -> void:
	grabbed.emit(left_side)


func let_go() -> void:
	if should_delete_on_let_go:
		get_parent().queue_free()
		return
	
	ungrabbed.emit(left_side)
