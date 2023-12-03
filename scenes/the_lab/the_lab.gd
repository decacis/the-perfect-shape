extends DCScene

@onready var tree : SceneTree = get_tree()

@export var player_spawn_pos : DCPlayerSpawnPos
@export var target_vapor : MeshInstance3D
@export var vapor : MeshInstance3D
@export var right_lever_handle : RigidBody3D
@export var right_lever_handle_grab : StaticBody3D
@export var left_lever_handle : RigidBody3D
@export var left_lever_handle_grab : StaticBody3D
@export var left_flag_pos : Marker3D
@export var right_flag_pos : Marker3D
@export var instructions_lbl : Label3D
@export var flag_material : ShaderMaterial
@export var flag_scene : PackedScene
@export var last_lbl : MeshInstance3D
@export var best_lbl : MeshInstance3D
@export var vapor_sfx : AudioStreamPlayer3D
@export var vacuum_sfx : AudioStreamPlayer3D
@export var success_sfx : AudioStreamPlayer
@export var highscore_sfx : AudioStreamPlayer
@export var start_game_sfx : AudioStreamPlayer
@export var scribble_sfx : AudioStreamPlayer3D

const MIN_WIDTH : float = 0.15
const MAX_WIDTH : float = 1.65
const MIN_HEIGHT : float = 0.2
const MAX_HEIGHT : float = 2.75

const BASE_POINTS : int = 1000

var current_target_dimensions : Dictionary

var vapor_listening_to_input : bool = false

var flag_state : Dictionary = {
	"left": false,
	"right": false
}

var lever_state : Dictionary = {
	"left": Enums.LeverRange.MID,
	"right": Enums.LeverRange.MID
}


func _ready() -> void:
	right_lever_handle.update_val.connect(update_v_height)
	right_lever_handle.change_range_state.connect(update_lever_state)
	left_lever_handle.update_val.connect(update_v_width)
	left_lever_handle.change_range_state.connect(update_lever_state)
	
	if SaveManager.progress.general.first_game:
		instructions_lbl.visible = true
		await tree.create_timer(2.0).timeout
	else:
		best_lbl.mesh.text = "BEST SCORE: %s" % SaveManager.progress.score.best
		
	# Spawn initial flags
	_spawn_flags()
	_play_sribble_sfx()


func scene_loaded() -> void:
	if player_spawn_pos:
		SceneManager.player_ref.global_position = player_spawn_pos.global_position
		SceneManager.player_ref.global_position.y += SceneManager.player_ref.height_offset
		SceneManager.player_ref.global_rotation = player_spawn_pos.global_rotation
	
	
	current_target_dimensions = _get_random_dimensions()
	target_vapor.mesh.radius = current_target_dimensions.width
	target_vapor.mesh.height = current_target_dimensions.height
	
	vapor_listening_to_input = true
	

func _get_random_dimensions() -> Dictionary:
	var dimensions : Dictionary = {
		"width": randf_range(MIN_WIDTH, MAX_WIDTH),
		"height": randf_range(MIN_HEIGHT, MAX_HEIGHT)
	}
	
	return dimensions


func update_lever_state(left : bool, state : Enums.LeverRange) -> void:
	if left:
		lever_state.left = state
	else:
		lever_state.right = state

func update_v_height(value : float) -> void:
	if vapor_listening_to_input:
		if (vapor.mesh.height + value) >= 0.01:
			vapor.mesh.height += value

func update_v_width(value : float) -> void:
	if vapor_listening_to_input:
		if (vapor.mesh.radius + value) >= 0.01:
			vapor.mesh.radius += value


func _handle_grabbed_flag(left_side : bool, grabbed : bool, start : bool) -> void:
	if left_side:
		flag_state.left = grabbed
	else:
		flag_state.right = grabbed
		
	if flag_state.right and flag_state.left:
		if left_flag_pos.get_child_count() == 1:
			left_flag_pos.get_child(0).get_child(0).should_delete_on_let_go = true
		
		if right_flag_pos.get_child_count() == 1:
			right_flag_pos.get_child(0).get_child(0).should_delete_on_let_go = true
		
		# Reset
		flag_state.left = false
		flag_state.right = false
		
		if not start:
			_eval_vapor()
		else:
			_handle_new_game()


func _eval_vapor() -> void:
	vapor_listening_to_input = false
	
	right_lever_handle_grab.reset_pos()
	await right_lever_handle.reset()
	
	left_lever_handle_grab.reset_pos()
	await left_lever_handle.reset()
	
	var last_score_tween : Tween = create_tween()
	last_score_tween.set_ease(Tween.EASE_IN)
	last_score_tween.set_trans(Tween.TRANS_CUBIC)
	last_score_tween.tween_property(last_lbl, "surface_material_override/0:albedo_color", Color("#a6ffb1"), 0.5)
	last_score_tween.tween_property(last_lbl, "surface_material_override/0:albedo_color", Color.WHITE, 0.5)
	
	var height_diff : float = abs(current_target_dimensions.height - vapor.mesh.height)
	var width_diff : float = abs(current_target_dimensions.width - vapor.mesh.radius)
	
	var avr_diff : float = (height_diff + width_diff) / 2.0
	
	var points_multiplier : float = clampf((1.0 - avr_diff), 0.0, 1.0)
	
	var total_points : int = roundi(BASE_POINTS * points_multiplier)
	
	success_sfx.play()
	
	# Save score if best
	if total_points > SaveManager.progress.score.best:
		highscore_sfx.play()
		
		SaveManager.progress.score.best = total_points
		SaveManager.save_data(Enums.SaveDataType.PROGRESS)
		
		best_lbl.mesh.text = "BEST SCORE: %s" % total_points
	
	last_lbl.mesh.text = "LAST SCORE: %s" % total_points
	
	# Spawn start flags
	# Wait for player to drop flags
	while left_flag_pos.get_child_count() != 0 or right_flag_pos.get_child_count() != 0:
		await tree.process_frame
	
	_spawn_flags()


func _spawn_flags(start : bool = true) -> void:
	if start:
		# Set start texture offset
		flag_material.set_shader_parameter("uv_offset", Vector2.ZERO)
		
		var left_flag : Node3D = flag_scene.instantiate()
		left_flag_pos.add_child(left_flag)
		left_flag.get_child(0).left_side = true
		left_flag.get_child(0).grabbed.connect(_handle_grabbed_flag.bind(true, start))
		left_flag.get_child(0).ungrabbed.connect(_handle_grabbed_flag.bind(false, start))
		
		var right_flag : Node3D = flag_scene.instantiate()
		right_flag_pos.add_child(right_flag)
		right_flag.get_child(0).left_side = false
		right_flag.get_child(0).grabbed.connect(_handle_grabbed_flag.bind(true, start))
		right_flag.get_child(0).ungrabbed.connect(_handle_grabbed_flag.bind(false, start))
	
	else:
		# Set finish texture offset
		flag_material.set_shader_parameter("uv_offset", Vector2(0.0, 1.0))
		
		var left_flag : Node3D = flag_scene.instantiate()
		left_flag_pos.add_child(left_flag)
		left_flag.get_child(0).left_side = true
		left_flag.get_child(0).grabbed.connect(_handle_grabbed_flag.bind(true, start))
		left_flag.get_child(0).ungrabbed.connect(_handle_grabbed_flag.bind(false, start))
		
		var right_flag : Node3D = flag_scene.instantiate()
		right_flag_pos.add_child(right_flag)
		right_flag.get_child(0).left_side = false
		right_flag.get_child(0).grabbed.connect(_handle_grabbed_flag.bind(true, start))
		right_flag.get_child(0).ungrabbed.connect(_handle_grabbed_flag.bind(false, start))


func _handle_new_game() -> void:
	if SaveManager.progress.general.first_game:
		SaveManager.progress.general.first_game = false
		SaveManager.save_data(Enums.SaveDataType.PROGRESS)
		
		instructions_lbl.visible = false
	
	# Wait for player to drop flags
	while left_flag_pos.get_child_count() != 0 or right_flag_pos.get_child_count() != 0:
		await tree.process_frame
	
	start_game_sfx.play()
	
	current_target_dimensions = _get_random_dimensions()
	
	var target_vapor_tween : Tween = create_tween()
	target_vapor_tween.set_ease(Tween.EASE_IN)
	target_vapor_tween.set_trans(Tween.TRANS_CUBIC)
	target_vapor_tween.set_parallel(true)
	
	target_vapor_tween.tween_property(target_vapor.mesh, "radius", current_target_dimensions.width, 0.3)
	target_vapor_tween.tween_property(target_vapor.mesh, "height", current_target_dimensions.height, 0.3)
	
	target_vapor_tween.tween_property(vapor.mesh, "radius", 0.5, 0.3)
	target_vapor_tween.tween_property(vapor.mesh, "height", 1.0, 0.3)
	
	await target_vapor_tween.finished
	
	vapor_listening_to_input = true
	
	_spawn_flags(false)


func _process(_delta : float) -> void:
	if lever_state.left == Enums.LeverRange.MINUS or lever_state.right == Enums.LeverRange.MINUS:
		if not vacuum_sfx.playing:
			vacuum_sfx.play()
	elif vacuum_sfx.playing:
		vacuum_sfx.stop()
	
	if lever_state.left == Enums.LeverRange.PLUS or lever_state.right == Enums.LeverRange.PLUS:
		if not vapor_sfx.playing:
			vapor_sfx.play()
	elif vapor_sfx.playing:
		vapor_sfx.stop()


func _play_sribble_sfx() -> void:
	scribble_sfx.play()
	
	await tree.create_timer(randf_range(6.0, 18.0)).timeout
	
	_play_sribble_sfx()
