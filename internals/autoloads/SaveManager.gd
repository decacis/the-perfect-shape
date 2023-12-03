extends Node

@onready var tree : SceneTree = get_tree()


const SETTINGS_PATH : String = "user://settings.json"
const DEFAULT_SETTINGS : Dictionary = {
	"general": {
		"locale": "en"
	},
	"input": {
		"primary_stick_controller": Enums.Controller.RIGHT,
		"secondary_stick_controller": Enums.Controller.LEFT,
		"function_key": Enums.InputType.AX_RIGHT
	}
}
var settings : Dictionary = DEFAULT_SETTINGS.duplicate(true)

const PROGRESS_PATH : String = "user://progress.json"
const DEFAULT_PROGRESS : Dictionary = {
	"general": {
		"first_game": true
	},
	"score": {
		"best": 0
	}
}
var progress : Dictionary = DEFAULT_PROGRESS.duplicate(true)


func load_data(type : Enums.SaveDataType) -> void:
	
	var selected_path : String = SETTINGS_PATH
	
	if type == Enums.SaveDataType.PROGRESS:
		selected_path = PROGRESS_PATH
	
	var file = FileAccess.open(selected_path, FileAccess.READ)
	
	if file and Features.feature.load:
		var json_result = JSON.parse_string(file.get_as_text())
		
		if json_result:
			
			if type == Enums.SaveDataType.SETTINGS:
				settings = json_result
			else:
				progress = json_result
			
			_process_loaded_data(type)
			file = null
		
		else:
			print_debug("Failed to saved data with type: {d_type}".format({
				d_type = type
			}))
			tree.quit()
	
	# Either an error or the file doesn't exists yet
	else:
		# Reset
		if type == Enums.SaveDataType.SETTINGS:
			settings = DEFAULT_SETTINGS.duplicate(true)
			save_data(Enums.SaveDataType.SETTINGS)
		else:
			settings = DEFAULT_PROGRESS.duplicate(true)
			save_data(Enums.SaveDataType.PROGRESS)
		
		file = null

func save_data(type : Enums.SaveDataType) -> void:
	var selected_path : String = SETTINGS_PATH
	
	if type == Enums.SaveDataType.PROGRESS:
		selected_path = PROGRESS_PATH
	
	if Features.feature.save:
		
		var file = FileAccess.open(selected_path, FileAccess.WRITE)
		
		if file:
			if type == Enums.SaveDataType.SETTINGS:
				file.store_line(JSON.stringify(settings))
			else:
				file.store_line(JSON.stringify(progress))
			
			file = null
		
		else:
			print_debug("Unable to write to file: {f_path}".format({
				f_path = selected_path
			}))
			tree.quit()


func _process_loaded_data(type : Enums.SaveDataType) -> void:
	if type == Enums.SaveDataType.SETTINGS:
		settings.input.primary_stick_controller = int(settings.input.primary_stick_controller) as Enums.Controller
		settings.input.secondary_stick_controller = int(settings.input.secondary_stick_controller) as Enums.Controller
		settings.input.function_key = int(settings.input.function_key) as Enums.InputType
	
	else:
		progress.score.best = int(progress.score.best)
