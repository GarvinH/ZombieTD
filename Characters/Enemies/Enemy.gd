extends "res://Characters/TemplateCharacter.gd"

var motion = Vector2();
var hp = 1;
onready var navigation = get_tree().get_root().find_node("Ground", true, false)

func _ready():
	add_to_group("enemies")

func on_Player_died() -> void:
	queue_free()
