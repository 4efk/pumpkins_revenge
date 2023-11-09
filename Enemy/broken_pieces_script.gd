extends Node3D

func _on_timer_timeout():
	for piece in get_children():
		if piece is RigidBody3D:
			piece.freeze = true
