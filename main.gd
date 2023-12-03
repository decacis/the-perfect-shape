extends Node3D

@onready var tree : SceneTree = get_tree()

@export var player_ref : DCPlayer
@export var current_scene_parent : Node3D


func _ready() -> void:
	Global.player_ref = player_ref
	
	SceneManager.player_ref = player_ref
	SceneManager.current_scene_parent = current_scene_parent
	
	InputManager.grip_pressed.connect(_handle_input.bind(true), CONNECT_ONE_SHOT)
	InputManager.trigger_pressed.connect(_handle_input.bind(false), CONNECT_ONE_SHOT)


func _handle_input(_controller : Enums.Controller, input_grip : bool) -> void:
	if input_grip:
		InputManager.trigger_pressed.disconnect(_handle_input)
	else:
		InputManager.grip_pressed.disconnect(_handle_input)
	
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)
	
	await tree.process_frame
	await tree.process_frame
	
	var camera_height : float = player_ref.camera.global_position.y
	
	if camera_height < Global.MIN_CAMERA_HEIGHT:
		var height_diff : float = Global.MIN_CAMERA_HEIGHT - camera_height
		
		player_ref.height_offset = height_diff
	
	player_ref.remove_start_lbl()
	await SceneManager.load_game_scene("the_lab")
