extends "res://Characters/Enemies/Enemy.gd"

var can_attack = true;
var attacking = false;
var direction = Vector2();

const arrival_tolerance = 1

func _physics_process(_delta: float) -> void:
	move();
	attack();
	
func move() -> void:
	var tile = Vector2(navigation.world_to_map(position))
	var tile_pos = navigation.map_to_world(tile)
	tile_pos.x += 30
	tile_pos.y += 30
	if (abs(position.x - tile_pos.x) < arrival_tolerance and abs(position.y - tile_pos.y) < arrival_tolerance):
		if (State.flowField[tile]):
			var next_tile = State.flowField[tile]
			direction = next_tile
			motion = direction*speed*0.75
			motion = move_and_slide(motion)
	else:
		motion = direction * speed*0.75
		motion = move_and_slide(motion)

func hit(dmg) -> void:
	hp -= dmg
	if (hp <= 0):
		die()
		
func die() -> void:
	queue_free()

func attack() -> void:
	if (can_attack and attacking):
		for collider in $Area2D.get_overlapping_bodies():
			if collider.get_collision_layer_bit(State.COLLISION_LAYER.player) || collider.get_collision_layer_bit(State.COLLISION_LAYER.map_objects):
				if collider.has_method("take_damage"):
					collider.take_damage()
					$Timer.start()
					can_attack = false

func _on_Timer_timeout():
	can_attack = true

func _on_Area2D_body_entered(_body):
	attacking = true

func _on_Area2D_body_exited(_body):
	attacking = false
