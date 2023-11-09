extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var base_look_sensitivity = 0.015
@export var acceleration_ground = 35.0
@export var acceleration_air = 3.0
@export var weapon_range = 20

var guns = [preload("res://Weapons/handgun_1.tscn")]

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var acceleration = 1
var horizontal_velocity = Vector3()
var vertical_velocity = 0

var hp = 100

@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var shoot_raycast = $Head/ShootRaycast
@onready var shoot_timer = $ShootTimer
@onready var hand = $Head/Hand
@onready var flashlight = $Head/Flashlight
@onready var player_gui = $"../../../../GUI/PlayerGUI"
@onready var go_animation_player = $"../../../../GUI/GameOver/AnimationPlayer"
@onready var free_timer = $FreeTimer
@onready var world = $".."
@onready var game_music = $"../../../../../GameMusic"
@onready var hit_sounds = [$HitSound1, $HitSound2]
@onready var heal_sound = $HealSound

func hit(damage=100, sound=true):
	if sound:
		hit_sounds[randi() % len(hit_sounds)].play()
	hp -= damage
	if hp > 100:
		hp = 100
	if hp <= 0:
		die()
		GlobalScript.total_lost_hp += hp
	
	if damage > 0:
		GlobalScript.total_lost_hp += damage
	
func die():
#	queue_free()
	world.waving = false
	world.waiting = false
	world.current_wave_timer = 1
	world.wave_gap_timer = 1
	player_gui.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#	get_node('../DirectionalLight3D').light_energy = .7
#	get_node('../WorldEnvironment').environment.volumetric_fog_density = 0.1
	free_timer.start()
	go_animation_player.play("die_anim")
	

func win():
#	queue_free()
	player_gui.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
##	get_node('../DirectionalLight3D').light_energy = .7
#	get_node('../WorldEnvironment').environment.volumetric_fog_density = 0.1
	free_timer.start()
	go_animation_player.play("win_anim")
	game_music.stop()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	shoot_raycast.target_position.z = -weapon_range

func  _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * base_look_sensitivity * GlobalScript.settings['mouse_sensitivity'] *  GlobalScript.settings['downscaling'])
		head.rotate_x(-event.relative.y * base_look_sensitivity * GlobalScript.settings['mouse_sensitivity'] *  GlobalScript.settings['downscaling'])
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func  _physics_process(delta):
	#movement
	horizontal_velocity = Input.get_vector("left", "right", "forward", "backward").normalized() * speed
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'velocity', horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z, 1/acceleration)
	
	if is_on_floor():
		acceleration = acceleration_ground
		vertical_velocity = 0
		if Input.is_action_just_pressed("jump"): vertical_velocity = jump_velocity
	else:
		acceleration = acceleration_air
		vertical_velocity -= gravity * delta
	
	velocity.y = vertical_velocity
	move_and_slide()
	
	#flashlight
	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight.visible = !flashlight.visible
	
	#shooting
	if hand.get_child_count() > 0:
		if Input.is_action_just_pressed("shoot") and !hand.get_child(0).get_node('Animations').is_playing():
			hand.get_child(0).get_node('Animations').play("fire")
			hand.get_child(0).get_node('SoundShot').play()
			hand.get_child(0).get_node('MuzzleFlashParticles').restart()
			GlobalScript.total_shots += 1
			if !shoot_raycast.is_colliding():
				return
			if shoot_raycast.get_collider().is_in_group("shootable"):
				shoot_raycast.get_collider().shot(shoot_raycast.get_collision_point())
		elif Input.is_action_just_pressed("inspect") and !hand.get_child(0).get_node('Animations').is_playing():
			hand.get_child(0).get_node('Animations').play("inspect")

func _on_area_3d_body_entered(body):
	if body.is_in_group("deadly"):
		hit(body.damage)
	elif body.is_in_group("heal"):
		hit(randi_range(-63, -20), false)
		heal_sound.play()
		body.queue_free()

func _on_enemy_effect_area_body_entered(body):
	if body.is_in_group("deadly"):
		body.activated_by_player()


func _on_free_timer_timeout():
	get_node('../WorldEnvironment').environment.volumetric_fog_density = 0.1
	queue_free()
