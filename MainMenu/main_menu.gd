extends CanvasLayer

@onready var sub_viewport_container = $SubViewportContainer
@onready var menu_buttons = $Control/MenuButtons
@onready var settings = $Control/Settings
@onready var fps_counter = $Control/FPSCounter
@onready var credits = $Control/Credits

func _ready():
	get_viewport().connect("size_changed", 
		func():
			sub_viewport_container.size = get_viewport().size
	)
	
	sub_viewport_container.stretch_shrink = GlobalScript.settings['downscaling']
	sub_viewport_container.size = get_viewport().size

func _process(delta):
	fps_counter.text = str(Engine.get_frames_per_second())
	fps_counter.visible = GlobalScript.settings['show_fps']

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://World/world2.tscn")

func _on_settings_button_pressed():
	menu_buttons.hide()
	settings.show()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_credits_button_pressed():
	menu_buttons.hide()
	credits.show()

func _on_back_button_pressed():
	menu_buttons.show()
	credits.hide()
