extends Node

@export var jump_force = Vector3(0, 105, 0)

@onready var explode_timer = $"../ExplodeTimer"
@onready var animation_player = $"../AnimationPlayer"
@onready var beep_light = $"../BeepLight"
@onready var pumpkin_normal = $"../pumpkin"
@onready var pumpkin_explode = $"../pumpkin2"
@onready var explode1_sound = $"../AudioStreamPlayer3D"
@onready var pumpkin_affected_area = $"../PumpkinAffectedArea"

func player_near():
	get_parent().apply_impulse(jump_force)
	explode_timer.start()
	beep_light.show()
	pumpkin_normal.hide()
	pumpkin_explode.show()
	explode1_sound.play(1.65)

func _on_explode_timer_timeout():
	if get_parent().dead:
		return
	get_parent().shot(Vector3(), 24, true)
	$"../GPUParticles3D".restart()
	if get_node_or_null('../../../Player'):
		var real_damage = int(5 - (get_node('../../../Player').global_position - get_parent().global_position).length()) * get_parent().damage
		if real_damage > 0:
			get_node('../../../Player').hit(real_damage, false)
	for body in pumpkin_affected_area.get_overlapping_bodies():
		if body.is_in_group("shootable"):
			body.shot(Vector3(), 10, false)
