extends Node3D

const wave_settings = [ #pumpkin spaw cooldown, spawn places, pumpkin speed, pumpkin damage, pumpkin types, wave duration [s], drop heal
	[5, [0, 2], 125.0, 14, 1, 60, false],
	[3, [0, 2, 5], 125.0, 20, 1, 90, true],
	[3, [1, 2, 4, 5, 6], 125.0, 32, 2, 90, false],
	[4, [0, 1, 2, 4, 5, 6], 125.0, 43, 2, 45, true],
	[3, [0, 2, 4], 125.0, 24, 3, 90, true],
	[2.5, [0, 1, 2, 4, 6], 135.0, 16, 3, 60, true],
	[3.5, [0, 1, 2, 3, 4, 5, 6], 125.0, 24, 4, 120, false],
]

var default_wave_gap = 15

var wave_gap_timer = 5
var current_wave = 0 #0
var current_wave_timer = 60 #60
var waving = false
var waiting = true
var play_music = true

var last_delta
var mid_wave_heal = true

var enemy_pumpkins = [preload("res://Enemy/enemy_pumpkin.tscn"), preload("res://Enemy/enemy_pumpkin2.tscn"), preload("res://Enemy/enemy_pumpkin3.tscn"), preload("res://Enemy/enemy_pumpkin4.tscn"), preload("res://Enemy/enemy_pumpkin.tscn"), preload("res://Enemy/enemy_pumpkin2.tscn"), preload("res://Enemy/enemy_pumpkin3.tscn")]

@onready var enemy_spawns = [$EnemySpawn1, $EnemySpawn2, $EnemySpawn3, $EnemySpawn4, $EnemySpawn5, $EnemySpawn6, $EnemySpawn7]
@onready var spawn_timer_1 = $SpawnTimer1
@onready var enemies = $Enemies
@onready var wave_counter = $"../../../GUI/WaveEffects/WaveCounter"
@onready var animation_player = $"../../../GUI/WaveEffects/AnimationPlayer"
@onready var player = $Player
@onready var new_wave_sound = $"../../../GUI/WaveEffects/NewWaveSound"
@onready var game_music = $"../../../../GameMusic"
@onready var win_music = $"../../../../WinMusic"

func _process(delta):
	last_delta = delta
	
	if !game_music.playing and play_music:
		game_music.play()
	
	if waving:
		current_wave_timer -= delta
	
	elif waiting:
		wave_gap_timer -= delta
		
	if wave_gap_timer <= 0:
		waiting = false
		waving = true
		
		#settings vars
		wave_gap_timer = default_wave_gap
		spawn_timer_1.wait_time = wave_settings[current_wave][0]
		
		#effects
		wave_counter.text = '- WAVE ' + str(current_wave+1) + ' -'
		if current_wave == len(wave_settings)-1:
			wave_counter.text = '- FINAL WAVE -'
			
		animation_player.play("new_wave")
		new_wave_sound.play()
	
	if current_wave_timer <= 0:
		waving = false
		waiting = true
		if current_wave == len(wave_settings)-1:
			player.win()
			game_music.stop()
			play_music = false
			win_music.play()
			waiting = false
			waving = false
			current_wave_timer = 1
			wave_gap_timer = 1
			return
		current_wave += 1
		
		current_wave_timer = wave_settings[current_wave][5]
		
func _on_spawn_timer_1_timeout():
	if waving:
		var enemy_instance = enemy_pumpkins[randi() % wave_settings[current_wave][4]].instantiate()
		enemies.add_child(enemy_instance)
		enemy_instance.global_position = enemy_spawns[wave_settings[current_wave][1][randi() % len(wave_settings[current_wave][1])]].global_position
		enemy_instance.damage = wave_settings[current_wave][3]
		enemy_instance.speed = wave_settings[current_wave][2]
		if current_wave_timer - wave_settings[current_wave][0] - 1 <= 0:
			enemy_instance.drop = wave_settings[current_wave][6]
		if current_wave == 6 and current_wave_timer - wave_settings[current_wave][0] - 1 <= 60 and mid_wave_heal:
			enemy_instance.drop = true
			mid_wave_heal = false
