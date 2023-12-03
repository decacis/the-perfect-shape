extends Node3D

@export var left_controller : Node3D
@export var right_controller : Node3D
@export var camera : Node3D

var computed_scale : Vector3


func calc_scale(robot_hmd_pos : Vector3, robot_pos : Vector3) -> void:
	var local_y_offset : float = camera.global_position.y - global_position.y
	var remote_y_offset : float = robot_hmd_pos.y - robot_pos.y
	
	var temp_computed_scale : float = remote_y_offset / local_y_offset
	computed_scale = Vector3(temp_computed_scale, temp_computed_scale, temp_computed_scale)
