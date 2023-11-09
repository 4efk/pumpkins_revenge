extends Node

const SETTINGS_FILEPATH = 'user://settings.dat'

var settings = {'downscaling': 1, 'mouse_sensitivity':0.2, 'master_volume':0, 'music_volume':-20, 'sfx_volume':-20, 'fps':6, 'vsync':false, 'show_fps':false, 'fullscreen':4}
var fps_options = [30, 60, 120, 144, 240, 360, 0]

var total_shots = 0
var total_lost_hp = 0
var waves_survived = 0
var pumpkins_killed = 0

func _ready():
	load_settings()
	apply_settings()

func apply_settings():
	if GlobalScript.settings['master_volume'] <= -45:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, GlobalScript.settings['master_volume'])
	
	if GlobalScript.settings['sfx_volume'] <= -45:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_volume_db(1, GlobalScript.settings['sfx_volume'])
	
	if GlobalScript.settings['music_volume'] <= -45:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
		AudioServer.set_bus_volume_db(2, GlobalScript.settings['music_volume'])
		
	Engine.max_fps = GlobalScript.fps_options[GlobalScript.settings['fps']]
	DisplayServer.window_set_vsync_mode(GlobalScript.settings['vsync'])
	DisplayServer.window_set_mode(GlobalScript.settings['fullscreen'])
	
func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		settings['fullscreen'] = 4 * int(!settings['fullscreen'])
		DisplayServer.window_set_mode(settings['fullscreen'])
		save_settings()

func save_settings():
	var error = FileAccess.open(SETTINGS_FILEPATH, FileAccess.WRITE)
	error.store_var(settings)
	error.close()

func load_settings():
	if FileAccess.file_exists(SETTINGS_FILEPATH):
		var error = FileAccess.open(SETTINGS_FILEPATH, FileAccess.READ)
		if error:
			settings = error.get_var()
			error.close()
