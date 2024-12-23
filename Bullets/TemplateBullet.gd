extends Area2D

var motion = Vector2()
const SPEED = 500
const DMG = 1

func init(parentPos, xMove, yMove, direction):
	position = parentPos
	motion.x = xMove
	motion.y = yMove
	motion = motion.normalized()
	rotation = direction
	
	add_to_group("bullets")

func _physics_process(delta: float) -> void:
	position += motion*SPEED*delta


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func _on_TemplateBullet_body_entered(body: Node) -> void:
	if body.get_collision_layer_bit(State.COLLISION_LAYER.tiles):
		queue_free()
	elif body.get_collision_layer_bit(State.COLLISION_LAYER.air_enemies) or body.get_collision_layer_bit(State.COLLISION_LAYER.ground_enemies):
		body.hit(DMG)
		queue_free()
		
func _on_Player_died() -> void:
	queue_free()
