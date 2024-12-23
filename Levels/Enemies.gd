extends Node

#func _process(_delta: float) -> void:
	#enemies_alive()

func enemies_alive() -> bool:
	return get_tree().get_nodes_in_group("enemies").size() > 0
