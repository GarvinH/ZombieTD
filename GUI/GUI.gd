extends CanvasLayer

func _process(_delta):
	update_fps()

func update_fps() -> void:
	$Control/FPS.text = String(Engine.get_frames_per_second())

func update_timer(time_left: float) -> void:
	$Control/Timer.text = String(floor(time_left))
	
func update_lives(lives: int) -> void:
	$Control/HBoxContainer/Lives.text = String(lives)
