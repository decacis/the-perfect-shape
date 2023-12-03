extends Node

signal function_key_pressed
signal trigger_pressed(controller : Enums.Controller)
signal grip_pressed(controller : Enums.Controller)

const DEADZONE : float = 0.75


func _ready() -> void:
	while not Global.player_ref:
		await get_tree().process_frame
	Global.player_ref.left_controller.button_pressed.connect(\
	_handle_key_pressed.bind(Enums.Controller.LEFT))
	Global.player_ref.right_controller.button_pressed.connect(\
	_handle_key_pressed.bind(Enums.Controller.RIGHT))


func get_stick_value(stick_type : Enums.InputType) -> Vector2:
	var right_controller_vals : Vector2 = Global.player_ref.right_controller.get_vector2("primary")
	if right_controller_vals.length() < DEADZONE:
		right_controller_vals = Vector2.ZERO
	
	var left_controller_vals : Vector2 = Global.player_ref.left_controller.get_vector2("primary")
	if left_controller_vals.length() < DEADZONE:
		left_controller_vals = Vector2.ZERO
	
	match stick_type:
		Enums.InputType.PRIMARY_STICK:
			if SaveManager.settings.input.primary_stick_controller == Enums.Controller.RIGHT:
				return right_controller_vals
			else:
				return left_controller_vals
		Enums.InputType.SECONDARY_STICK:
			if SaveManager.settings.input.secondary_stick_controller == Enums.Controller.RIGHT:
				return right_controller_vals
			else:
				return left_controller_vals
		_:
			return Vector2.ZERO

func _handle_key_pressed(input_name : String, controller : Enums.Controller) -> void:
	match input_name:
		"ax_button":
			if controller == Enums.Controller.RIGHT \
			and SaveManager.settings.input.function_key == Enums.InputType.AX_RIGHT:
				function_key_pressed.emit()
			elif controller == Enums.Controller.LEFT \
			and SaveManager.settings.input.function_key == Enums.InputType.AX_LEFT:
				function_key_pressed.emit()
			
		"by_button":
			if controller == Enums.Controller.RIGHT \
			and SaveManager.settings.input.function_key == Enums.InputType.BY_RIGHT:
				function_key_pressed.emit()
			elif controller == Enums.Controller.LEFT \
			and SaveManager.settings.input.function_key == Enums.InputType.BY_LEFT:
				function_key_pressed.emit()
			
		"trigger_click":
			trigger_pressed.emit(controller)
		
		"grip_click":
			grip_pressed.emit(controller)
