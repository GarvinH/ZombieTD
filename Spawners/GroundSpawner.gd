extends StaticBody2D

const Regular = preload("res://Characters/Enemies/Ground_Enemies/Regular.tscn")
onready var can_spawn = true

func _process(_delta: float) -> void:
	if State.started && State.can_spawn && can_spawn && $Timer.is_stopped():
		var time = (randi() % 5) + 5
		$Timer.wait_time = time
		$Timer.start()
	elif (!State.can_spawn):
		$Timer.stop()
	
func spawn() -> void:
	var spawn = Regular.instance()
	spawn.position = global_position
	get_tree().get_root().find_node("GroundEnemies", true, false).add_child(spawn)
	can_spawn = false
	State.run_timer = true

func _on_Timer_timeout() -> void:
	spawn()

func _on_Area2D_body_exited(_body: Node) -> void:
	can_spawn = true

func _on_Area2D_body_entered(_body: Node) -> void:
	can_spawn = false
	$Timer.stop()
