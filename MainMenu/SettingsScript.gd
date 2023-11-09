extends Control

@onready var master_volume_slider = $VBoxContainer/MasterVolumeSlider
@onready var downscaling_slider = $VBoxContainer/DownscalingSlider
var sub_viewport_container
@onready var fps_slider = $VBoxContainer/FPSSlider
@onready var fps_label = $VBoxContainer/FpsLabel
@onready var v_sync_checkbox = $VBoxContainer/HBoxContainer/VSyncCheckbox
@onready var show_fps_checkbox = $VBoxContainer/ShowFPSCheckbox
@onready var mouse_sensitivity_slider = $VBoxContainer/MouseSensitivitySlider
@onready var fullscreen_checkbox = $VBoxContainer/HBoxContainer/FullscreenCheckbox
@onready var sfx_volume_slider = $VBoxContainer/SFXVolumeSlider
@onready var music_volume_slider = $VBoxContainer/MusicVolumeSlider

func _ready():
	GlobalScript.apply_settings()
	
	if get_parent().name == 'PauseMenu':
		sub_viewport_container =  $"../../../../SubViewportContainer"
	else:
		sub_viewport_container = $"../../SubViewportContainer"
	
	master_volume_slider.value = GlobalScript.settings['master_volume']
	sfx_volume_slider.value = GlobalScript.settings['sfx_volume']
	music_volume_slider.value = GlobalScript.settings['music_volume']
	downscaling_slider.value = GlobalScript.settings['downscaling']
	fps_slider.value = GlobalScript.settings['fps']
	if GlobalScript.settings['fps'] < 6:
		fps_label.text = 'fps: ' + str(GlobalScript.fps_options[GlobalScript.settings['fps']])
	else:
		fps_label.text = 'fps: unlimited'
		
	v_sync_checkbox.button_pressed = GlobalScript.settings['vsync']
	show_fps_checkbox.button_pressed = GlobalScript.settings['show_fps']
	mouse_sensitivity_slider.value = GlobalScript.settings['mouse_sensitivity']
	fullscreen_checkbox.button_pressed = GlobalScript.settings['fullscreen']

func _on_master_volume_slider_value_changed(value):
	if value <= -45:
		AudioServer.set_bus_mute(0, true)
		GlobalScript.settings['master_volume'] = value
	else:
		GlobalScript.settings['master_volume'] = value
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, value)
	GlobalScript.save_settings()

func _on_downscaling_slider_value_changed(value):
	GlobalScript.settings['downscaling'] = value
	sub_viewport_container.stretch_shrink = value
	GlobalScript.save_settings()

func _on_downscaling_slider_2_value_changed(value):
	GlobalScript.settings['fps'] = value
	Engine.max_fps = GlobalScript.fps_options[value]
	GlobalScript.save_settings()
	if GlobalScript.settings['fps'] < 6:
		fps_label.text = 'fps: ' + str(GlobalScript.fps_options[GlobalScript.settings['fps']])
	else:
		fps_label.text = 'fps: unlimited'

func _on_v_sync_checkbox_toggled(button_pressed):
	GlobalScript.settings['vsync'] = button_pressed
	DisplayServer.window_set_vsync_mode(button_pressed)
	GlobalScript.save_settings()

func _on_show_fps_checkbox_toggled(button_pressed):
	GlobalScript.settings['show_fps'] = button_pressed
	GlobalScript.save_settings()

func _on_master_volume_slider_2_value_changed(value):
	GlobalScript.settings['mouse_sensitivity'] = value
	GlobalScript.save_settings()

func _on_back_button_pressed():
	get_node('../MenuButtons').show()
	hide()
	
func _on_fullscreen_checkbox_toggled(button_pressed):
	GlobalScript.settings['fullscreen'] = int(button_pressed) * 4
	DisplayServer.window_set_mode(GlobalScript.settings['fullscreen'])
	GlobalScript.save_settings()


func _on_sfx_volume_slider_value_changed(value):
	if value <= -45:
		AudioServer.set_bus_mute(1, true)
		GlobalScript.settings['sfx_volume'] = value
	else:
		GlobalScript.settings['sfx_volume'] = value
		AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_volume_db(1, value)
	GlobalScript.save_settings()

func _on_music_volume_slider_value_changed(value):
	if value <= -45:
		AudioServer.set_bus_mute(2, true)
		GlobalScript.settings['music_volume'] = value
	else:
		GlobalScript.settings['music_volume'] = value
		AudioServer.set_bus_mute(2, false)
		AudioServer.set_bus_volume_db(2, value)
	GlobalScript.save_settings()
