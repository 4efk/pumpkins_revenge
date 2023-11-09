extends Node

@export var jump_force = Vector3(0, 100, 0)

func player_near():
	get_parent().apply_impulse(jump_force)
