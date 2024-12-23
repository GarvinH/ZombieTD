extends StaticBody2D

var hp

func take_damage() -> void:
	hp -= 1;
	if hp <= 0:
		destroy()
	
func destroy() -> void:
	queue_free()
