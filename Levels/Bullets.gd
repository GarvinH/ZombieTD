extends Node

func _on_Player_player_died() -> void:
	for bullet in get_children():
		bullet.queue_free()
