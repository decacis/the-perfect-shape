extends Node


var current_scene : DCScene
var scene_directory : Dictionary = {
	"the_lab": "res://scenes/the_lab/the_lab.tscn"
}

var current_scene_parent : Node3D
var player_ref : Node3D


func load_game_scene(scene_name : String) -> void:
	if not player_ref or not current_scene_parent:
		print_debug("Player or current scene parent reference missing")
		return
	
	if scene_directory.has(scene_name):
		if current_scene:
			await current_scene.remove_scene()
		
		await player_ref.fade_out()
		
		var new_scene = await ResourceManager.load_resource(scene_directory[scene_name])
		if new_scene:
			if current_scene:
				current_scene.queue_free()
				await current_scene.tree_exited
			
			current_scene = new_scene.instantiate()
			current_scene_parent.add_child(current_scene)
			
			await current_scene.scene_loaded()
			
			await player_ref.fade_in()
		
		else:
			print_debug("Unable to load scene")
		
	else:
		print_debug("Invalid scene name")
