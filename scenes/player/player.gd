class_name DCPlayer
extends XROrigin3D

@onready var tree : SceneTree = get_tree()

@export var height_offset : float = 0.0
@export var left_controller : XRController3D
@export var right_controller : XRController3D
@export var camera : XRCamera3D
@export var fade_out_screen : MeshInstance3D
@export var right_grab_area : Area3D
@export var left_grab_area : Area3D
@export var start_lbl : Label3D
@export var logo_mesh : MeshInstance3D
@export var left_hand_mesh_p : Node3D
@export var right_hand_mesh_p : Node3D

var fade_tween : Tween

var right_hand_grabbable_bodies : Array[Dictionary]
var left_hand_grabbable_bodies : Array[Dictionary]


func _ready() -> void:
#	right_grab_area.body_entered.connect(_grab_detect.bind(right_controller))
	right_controller.button_pressed.connect(_handle_pressed_input.bind(Enums.Controller.RIGHT))
	right_controller.button_released.connect(_handle_released_input.bind(Enums.Controller.RIGHT))
	
	left_controller.button_pressed.connect(_handle_pressed_input.bind(Enums.Controller.LEFT))
	left_controller.button_released.connect(_handle_released_input.bind(Enums.Controller.LEFT))


func fade_out(fade_time : float = 0.5) -> void:
	if fade_tween:
		fade_tween.kill()

	fade_out_screen.visible = true
	fade_tween = create_tween()
	fade_tween.tween_property(fade_out_screen.material_override, "shader_parameter/albedo_color", Color(0.0, 0.0, 0.0, 1.0), fade_time)
	await fade_tween.finished

func fade_in(fade_time : float = 0.5) -> void:
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(fade_out_screen.material_override, "shader_parameter/albedo_color", Color(0.0, 0.0, 0.0, 0.0), fade_time)
	fade_tween.tween_callback(func():
		fade_out_screen.visible = false
	)
	await fade_tween.finished


#func _grab_detect(body : Node3D, controller_ref : XRController3D) -> void:
#	if body.has_meta("grabbable_type"):
#		match body.get_meta("grabbable_type", -1):
#			Enums.Grabbable.LEVER:
#				if controller_ref.is_button_pressed("grip_click"):
#					body.global_position.y = controller_ref.global_position.y
#			_:
#				pass

func _handle_pressed_input(action_name : String, controller : Enums.Controller) -> void:
	match action_name:
		"grip_click":
			if controller == Enums.Controller.RIGHT:
				right_hand_mesh_p.get_node("AnimationPlayer").play("Grab")
				
				if right_grab_area.has_overlapping_bodies():
					for body in right_grab_area.get_overlapping_bodies():
						var remote_t : RemoteTransform3D = RemoteTransform3D.new()
						var body_dict : Dictionary = {
							"body": body,
							"remote_transform": remote_t,
#							"offset": body.global_position - right_controller.global_position
						}
						right_controller.add_child(remote_t)
						remote_t.global_position = body.global_position
						remote_t.remote_path = body.get_path()
						
						if body.has_meta("remote_options"):
							var remote_options : Dictionary = body.get_meta("remote_options", {
								"position": true,
								"rotation": false,
								"scale": false
							})
							
							remote_t.update_position = remote_options.position
							remote_t.update_scale = remote_options.scale
							remote_t.update_rotation = remote_options.rotation
						
						right_hand_grabbable_bodies.push_back(body_dict)
						body.grab()
			else:
				left_hand_mesh_p.get_node("AnimationPlayer").play("Grab")
				
				if left_grab_area.has_overlapping_bodies():
					for body in left_grab_area.get_overlapping_bodies():
						var remote_t : RemoteTransform3D = RemoteTransform3D.new()
						var body_dict : Dictionary = {
							"body": body,
							"remote_transform": remote_t,
#							"offset": body.global_position - left_controller.global_position
						}
						left_controller.add_child(remote_t)
						remote_t.global_position = body.global_position
						remote_t.remote_path = body.get_path()
						
						if body.has_meta("remote_options"):
							var remote_options : Dictionary = body.get_meta("remote_options", {
								"position": true,
								"rotation": false,
								"scale": false
							})
							
							remote_t.update_position = remote_options.position
							remote_t.update_scale = remote_options.scale
							remote_t.update_rotation = remote_options.rotation
						
						left_hand_grabbable_bodies.push_back(body_dict)
						body.grab()

func _handle_released_input(action_name : String, controller : Enums.Controller) -> void:
	match action_name:
		"grip_click":
			if controller == Enums.Controller.RIGHT:
				right_hand_mesh_p.get_node("AnimationPlayer").play_backwards("Grab")
				
				for body_dict in right_hand_grabbable_bodies:
					body_dict.body.let_go()
					body_dict.remote_transform.queue_free()
				
				right_hand_grabbable_bodies.clear()
			else:
				left_hand_mesh_p.get_node("AnimationPlayer").play_backwards("Grab")
				
				for body_dict in left_hand_grabbable_bodies:
					body_dict.body.let_go()
					body_dict.remote_transform.queue_free()
				
				left_hand_grabbable_bodies.clear()


#func _process(_delta : float) -> void:
#	for body_dict in right_hand_grabbable_bodies:
#		if body_dict.body.has_meta("grabbable_type"):
#			match body_dict.body.get_meta("grabbable_type", -1):
#				Enums.Grabbable.LEVER:
#					body_dict.body.global_position = (right_controller.global_position + body_dict.offset)
#				_:
#					pass


func remove_start_lbl() -> void:
	if start_lbl:
		start_lbl.queue_free()
	
	if logo_mesh:
		logo_mesh.queue_free()
