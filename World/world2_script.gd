extends Node

#var waves_survived_text = ''
#var lost_hp_text = ''
#var fired_shots_text = ''
#var score_text = ''

var texts = ['', '', '', '']

var currently_processed_label = 0
var type_timer = 0.0
var build_menu = false

@onready var labels = [$CanvasLayer/GUI/GameOver/VBoxContainer/WavesSurvived, $CanvasLayer/GUI/GameOver/VBoxContainer/HPLost, $CanvasLayer/GUI/GameOver/VBoxContainer/ShotsFIred, $CanvasLayer/GUI/GameOver/VBoxContainer/Score]

@onready var hp_counter = $CanvasLayer/GUI/PlayerGUI/HPCounter
@onready var fps_counter = $CanvasLayer/GUI/FPSCounter
@onready var player = $CanvasLayer/SubViewportContainer/SubViewport/world/Player
@onready var sub_viewport_container = $CanvasLayer/SubViewportContainer
@onready var gui = $CanvasLayer/GUI
@onready var world = $CanvasLayer/SubViewportContainer/SubViewport/world
@onready var show_buttons_timer = $CanvasLayer/GUI/GameOver/ShowButtonsTimer
@onready var v_box_container = $CanvasLayer/GUI/GameOver/VBoxContainer

func apply_settings():
	sub_viewport_container.stretch_shrink = GlobalScript.settings['downscaling']
	sub_viewport_container.size = get_viewport().size
	v_box_container.size = get_viewport().size
	v_box_container.position = Vector2(0, get_viewport().size.y)

func _ready():
	randomize()
	get_viewport().connect("size_changed", 
		func():
			sub_viewport_container.size = get_viewport().size
	)
	
	apply_settings()
	get_node("CanvasLayer/SubViewportContainer/SubViewport/world/WorldEnvironment").environment.volumetric_fog_density = 0.3302
	GlobalScript.total_lost_hp = 0
	GlobalScript.total_shots = 0
	GlobalScript.pumpkins_killed = 0

func _process(delta):
	if get_node_or_null('CanvasLayer/SubViewportContainer/SubViewport/world/Player'):
		hp_counter.value = player.hp
		
	fps_counter.text = str(Engine.get_frames_per_second())
	fps_counter.visible = GlobalScript.settings['show_fps']
	
	if build_menu:
		type_timer += delta
		if type_timer >= randf_range(0.01, 0.04):
			if len(labels[currently_processed_label].text) < len(texts[currently_processed_label]):
				labels[currently_processed_label].text += texts[currently_processed_label][len(labels[currently_processed_label].text)]
			elif currently_processed_label < len(labels)-1:
				currently_processed_label += 1
				labels[currently_processed_label].show()
			else:
				build_menu = false
				$CanvasLayer/GUI/GameOver/VBoxContainer/ColorRect.show()
				show_buttons_timer.start()
			type_timer = 0


func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")

func _on_retry_button_pressed():
	get_tree().change_scene_to_file("res://World/world2.tscn")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'die_anim':
		labels.remove_at(3)
	
	texts[0] = 'highest wave: ' + str(world.current_wave+1) + '/' + str(len(world.wave_settings))
	texts[1] = 'total damage taken: ' + str(GlobalScript.total_lost_hp)
	texts[2] = 'total shots: ' + str(GlobalScript.total_shots)
	texts[3] = 'SCORE: ' + str(int((world.current_wave+1) * 3549 / ((GlobalScript.total_lost_hp+1)/5.0) * 14 - GlobalScript.total_shots * 1.79))
	if GlobalScript.pumpkins_killed == 0:
		texts[3] = 'SCORE: PACIFIST!'
		if GlobalScript.total_lost_hp == 0:
			texts[3] = 'SCORE: NO DAMAGE PACIFIST!'
	elif GlobalScript.total_lost_hp == 0:
			texts[3] = 'SCORE: NO DAMAGE!'
	$CanvasLayer/GUI/GameOver/VBoxContainer/WavesSurvived.show()
	
	build_menu = true
	
func _on_show_buttons_timer_timeout():
	$CanvasLayer/GUI/GameOver/VBoxContainer/HBoxContainer.show()
