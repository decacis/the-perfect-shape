extends Node3D

@onready var tree : SceneTree = get_tree()

@onready var animation_tree : AnimationTree = $AnimationTree

var current_animation : int = 0


func _ready() -> void:
	current_animation = randi_range(0, 1)
	
	if current_animation == 0:
		animation_tree.set("parameters/blend_position", -1.0)
	else:
		animation_tree.set("parameters/blend_position", 1.0)
		
	await tree.create_timer(randf_range(4.0, 6.0)).timeout
		
	_switch_animation()


func _switch_animation() -> void:
	if current_animation == 0:
		current_animation = 1
		
		var tween : Tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(animation_tree, "parameters/blend_position", 1.0, 0.6)
		
		await tween.finished
		
		await tree.create_timer(randf_range(4.0, 6.0)).timeout
		
		_switch_animation()
	else:
		current_animation = 0
		
		var tween : Tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(animation_tree, "parameters/blend_position", -1.0, 0.6)
		
		await tween.finished
		
		await tree.create_timer(randf_range(4.0, 6.0)).timeout
		
		_switch_animation()
