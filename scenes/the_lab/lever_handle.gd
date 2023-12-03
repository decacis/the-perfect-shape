extends RigidBody3D

signal update_val(value : float)
signal change_range_state(left : bool, range : Enums.LeverRange)

@onready var tree : SceneTree = get_tree()

@export var is_left : bool = false
@export var change_per_sec : float = 0.1
@export var lower_range_max : float = -0.139626 # -8 degrees
@export var mid_range_max : float = 0.139626 # 8 degrees
@export var hinge_joint : HingeJoint3D
@export var pin_joint : PinJoint3D
@export var lever_click : AudioStreamPlayer3D

var current_range : Enums.LeverRange = Enums.LeverRange.MID


func _physics_process(delta : float) -> void:
	var new_range : Enums.LeverRange
	
	if global_rotation.x <= lower_range_max:
		new_range = Enums.LeverRange.MINUS
	elif global_rotation.x > lower_range_max and global_rotation.x <= mid_range_max:
		new_range = Enums.LeverRange.MID
	else:
		new_range = Enums.LeverRange.PLUS
	
	if new_range != current_range:
		current_range = new_range
		change_range_state.emit(is_left, current_range)
		lever_click.play()
	
	if current_range == Enums.LeverRange.MINUS:
		update_val.emit(-change_per_sec * delta)
	elif current_range == Enums.LeverRange.PLUS:
		update_val.emit(change_per_sec * delta)


func reset() -> void:
	hinge_joint.node_b = ""
	pin_joint.node_a = ""
	await tree.process_frame
	rotation.x = 0.0
	await tree.process_frame
	hinge_joint.node_b = get_path()
	pin_joint.node_a = get_path()
