extends "res://Characters/TemplateCharacter.gd"

const Bullet : = preload("res://Bullets/TemplateBullet.tscn")

var motion = Vector2()
onready var ground = get_tree().get_root().find_node("Ground", true, false)
onready var tile_pos = ground.world_to_map(position) #Refers to "previous" tile player was on
var hp = 3
 
signal player_died
signal player_respawned
signal update_lives

func _ready() -> void:
	emit_signal("update_lives", hp)

func _physics_process(_delta: float) -> void:
	move()
	shoot()
	motion = move_and_slide(motion)
	
func take_damage() -> void:
	State.can_spawn = false
	State.run_timer = false
	hp -= 1;
	emit_signal("player_died")
	
	# Remove all enemies from scene tree
	get_tree().call_group("enemies", "on_Player_died")
	
	emit_signal("update_lives", hp)
	if hp < 0:
		get_tree().quit()
	else:
		respawn()
		
func respawn() -> void:
	position.x = 960
	position.y = 540
	emit_signal("player_respawned")
	
func move() -> void:
	var xMove : int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var yMove : int = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	motion.x = xMove
	motion.y = yMove
	motion = motion.normalized()*speed
	if (!State.started && motion):
		State.started = true
	change_flow_field()
	
func change_flow_field():
	var current_tile = ground.world_to_map(position)
	if current_tile != tile_pos: #Update the flow field if the player changes tiles on the map
		tile_pos = current_tile
		ground.update_flow_field()

func shoot() -> void:
	var xShoot : int = int(Input.is_action_pressed("shoot_right")) - int(Input.is_action_pressed("shoot_left"))
	var yShoot : int = int(Input.is_action_pressed("shoot_down")) - int(Input.is_action_pressed("shoot_up"))
	var bulletPosition = position
	
	var xDir : int = 90
	if (xShoot < 0):
		xDir *= 3
	elif (xShoot == 0):
		xDir *= 0
	var yDir : int = 180
	if (yShoot < 0):
		yDir *= 2
	elif (yShoot == 0):
		yDir *= 0
			
	bulletPosition.x += 40 * (xShoot)
	bulletPosition.y += 40 * (yShoot)
	# warning-ignore:integer_division
	var dir = (xDir + yDir) / (2 if (bool(xDir) && bool(yDir)) else 1)
	if (xShoot != 0 || yShoot != 0):
		create_bullet(bulletPosition, xShoot, yShoot, deg2rad(dir))
		
func create_bullet(bulletPosition, xShoot, yShoot, direction):
	if ($Timer.is_stopped()):
		var b = Bullet.instance()
		b.init(bulletPosition, xShoot, yShoot, direction)
		get_tree().get_root().find_node("Bullets", true, false).add_child(b)
		$Timer.start()
