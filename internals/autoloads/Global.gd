extends Node

@onready var tree : SceneTree = get_tree()

var xr_interface : OpenXRInterface

var player_ref : Node3D :
	get:
		return player_ref
	set(value):
		player_ref = value
		set_physics_process(true)

const DEADZONE : float = 0.65
var last_left_controller_stick : Vector2 = Vector2.ZERO
var last_right_controller_stick : Vector2 = Vector2.ZERO

const MIN_CAMERA_HEIGHT : float = 1.5


func _ready() -> void:
	set_physics_process(false)
	xr_interface = XRServer.find_interface("OpenXR")
	xr_interface.set_render_target_size_multiplier(1.2)
	
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialised successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
		
		xr_interface.display_refresh_rate = 90.0
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	
	SaveManager.load_data(Enums.SaveDataType.SETTINGS)
	SaveManager.load_data(Enums.SaveDataType.PROGRESS)


func _physics_process(_delta : float) -> void:
	if not player_ref:
		return
	
	# Set stick value. Correct dead zones
	# https://web.archive.org/web/20191208161810/http://www.third-helix.com/2013/04/12/doing-thumbstick-dead-zones-right.html
	last_left_controller_stick = player_ref.left_controller.get_vector2("primary")
	if last_left_controller_stick.length() < DEADZONE:
		last_left_controller_stick = Vector2.ZERO
#	else:
#		last_left_controller_stick = last_left_controller_stick.normalized() * ((last_left_controller_stick.length() - DEADZONE) / (1 - DEADZONE))
	
	last_right_controller_stick = player_ref.right_controller.get_vector2("primary")
	if last_right_controller_stick.length() < DEADZONE:
		last_right_controller_stick = Vector2.ZERO
#	else:
#		last_right_controller_stick = last_right_controller_stick.normalized() * ((last_right_controller_stick.length() - DEADZONE) / (1 - DEADZONE))


func play_rumble(controller : Enums.Controller, hit_force : float) -> void:
	if controller == Enums.Controller.LEFT:
		player_ref.left_controller.trigger_haptic_pulse("haptic", 0.05 + hit_force, 0.12 + hit_force, 0.06, 0.0)
	else:
		player_ref.right_controller.trigger_haptic_pulse("haptic", 0.05 + hit_force, 0.12 + hit_force, 0.06, 0.0)
