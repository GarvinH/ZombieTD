extends Node2D

var player_respawned = false

signal update_timer
signal start_fighting

func _process(_delta: float) -> void:
	handle_mode()
	emit_signal("update_timer", $Timer.time_left)

func handle_mode() -> void:
	if $Timer.is_stopped():
		match State.mode:
			State.MODE.fighting:
				if (State.started):
					if (State.run_timer):
						$Timer.wait_time = State.time_left
						$Timer.start()
					if (!player_respawned):
						State.can_spawn = true
			State.MODE.building:
				if (!$Enemies.enemies_alive()):
						$Timer.wait_time = State.time_left
						$Timer.start()
						State.can_shop = true
				State.can_spawn = false

func _on_Timer_timeout():
	if (State.mode == State.MODE.fighting):
		State.mode = State.MODE.building;
		State.time_left = 60
	else:
		State.mode = State.MODE.fighting;
		State.can_shop = false
		State.time_left = 60
		$Timer.wait_time = 60
		State.run_timer = false
		emit_signal("start_fighting")

func _on_Player_player_respawned():
	if (State.mode == State.MODE.fighting):
		player_respawned = true
		State.time_left = $Timer.time_left
		$Timer.stop()
		State.run_timer = false
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		State.can_spawn = true
		player_respawned = false
