extends Control

@onready var settings = $Settings
@onready var menu_buttons = $MenuButtons
@onready var world = $"../../../SubViewportContainer/SubViewport/world"

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and (world.waving or world.waiting):
		if get_tree().paused:
			hide()
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
		else:
			show()
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_button_pressed():
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_settings_button_pressed():
	settings.show()
	menu_buttons.hide()

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")

func _on_restart_button_2_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://World/world2.tscn")
