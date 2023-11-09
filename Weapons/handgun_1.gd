extends Node3D

func  _ready():
	$MuzzleFlashParticles.top_level = true

func _process(delta):
	$MuzzleFlashParticles.global_position = get_parent().global_position * get_parent().transform.basis.y + Vector3(0, 0.01, 0.4) * get_parent().transform.basis.y
