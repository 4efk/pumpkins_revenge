extends RigidBody3D

var broken_pieces_scene = preload("res://Enemy/enemy_pumpkin_broken.tscn")
var heal_scene = preload("res://World/heal_pack_1.tscn")

@export var speed = 125.0
@export var damage = 14
@export var drop = false

@onready var collision_shape = $CollisionShape3D
@onready var pumpkin_model = $pumpkin
@onready var specific_control = $SpecificControl
@onready var die_sounds = [$DieSound, $DieSound2]
@onready var despawn_timer = $DespawnTimer
@onready var on_ground_detect_area = $OnGroundDetectArea
@onready var roll_sound = $RollSound

var dead = false

func shot(point=Vector3(), bullet_energy=8, explode=false):
	if dead:
		return
	dead = true
	apply_impulse(Vector3(0, 1, 0), point)
	
	var last_vel = linear_velocity
	var last_avel = angular_velocity
	freeze = true
	collision_shape.queue_free()
	pumpkin_model.queue_free()
	die_sounds[randi() % len(die_sounds)].pitch_scale = randf_range(.8, 1.2)
	die_sounds[randi() % len(die_sounds)].play()
	if get_node_or_null('BeepLight'):
		get_node('BeepLight').hide()
		get_node("pumpkin2").hide()
		if !explode:
			get_node("AudioStreamPlayer3D").stop()
			GlobalScript.pumpkins_killed += 1
		roll_sound.stop()
	var broken_pieces_scene_instance = broken_pieces_scene.instantiate()
	for piece in broken_pieces_scene_instance.get_children():
		if piece is RigidBody3D:
			piece.linear_velocity = piece.get_child(0).position.normalized().rotated(Vector3(1, 0, 0), randf_range(-1, 1)).rotated(Vector3(0, 1, 0), randf_range(-1, 1)) * bullet_energy + last_vel
			piece.angular_velocity = Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10)) + last_avel
	add_child(broken_pieces_scene_instance)
	despawn_timer.start()
	if drop:
		var drop_instance = heal_scene.instantiate()
		get_node('../../Drops').add_child(drop_instance)
		drop_instance.global_position = global_position
		drop_instance.get_node('AnimationPlayer').play('idle')
#	queue_free()

func activated_by_player():
	specific_control.player_near()

func _ready():
	randomize()

func _physics_process(delta):
	if get_node_or_null('../../Player'):
		apply_central_force((get_node('../../Player').global_position - global_position).normalized() * speed)
#
#		var vel = (get_parent().get_node('Player').global_position - global_position).normalized() * speed
#		linear_velocity.x = vel.x
#		linear_velocity.z = vel.z

	for body in on_ground_detect_area.get_overlapping_bodies():
		if body.name == "FieldBody" and !roll_sound.playing and !dead:
			roll_sound.play()
		elif dead:
			roll_sound.stop()

func _on_despawn_timer_timeout():
	queue_free()
