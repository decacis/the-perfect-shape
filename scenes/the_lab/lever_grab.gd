extends StaticBody3D

@export var return_pos : Marker3D
@export var pin_joint : PinJoint3D

@onready var tree : SceneTree = get_tree()
@onready var original_position : Vector3 = global_position


func grab() -> void:
	pin_joint.node_b = get_path()

func let_go() -> void:
	pin_joint.node_b = ""
	await tree.create_timer(0.1).timeout
	global_transform = return_pos.global_transform


func reset_pos() -> void:
	global_position = original_position
