extends Node2D

onready var ground = get_tree().get_root().find_node("Ground", true, false)
const OPACITY = 0.75

const WALL_TEXTURE = preload("res://GFX/Tiles/Wall.png")
const GRASS_TEXTURE = preload("res://GFX/Tiles/Grass.png")
const BARRICADE_TEXTURE = preload("res://GFX/Objects/Barricade.png")

var show_preview : bool = false
var tile_pos : Vector2 #Refers to the last tile position of the mouse
var pressed : bool = false
var new_pos : Vector2 = global_position
var path_not_blocking: bool = false

func _ready() -> void:
	$Sprite.texture = WALL_TEXTURE
	$Sprite.modulate.a = 0
	$Area2D/CollisionShape2D.shape.extents = Vector2(ground.TILE_SIZE_HALF_X-.1, 
			ground.TILE_SIZE_HALF_Y-.1) #must subtract by .1 or will collide with adjacent wall tiles

func _physics_process(_delta) -> void:
	if show_preview:
		if new_pos != position:
			position = new_pos
			path_not_blocking = ground.can_buy_wall(position)
		elif $Area2D.get_overlapping_bodies().size() == 0 and path_not_blocking:
			$Sprite.modulate = Color(1,1,1,OPACITY)
			if pressed:
				ground.buy_wall(tile_pos)
		else:
			$Sprite.modulate = Color(1,0,0,OPACITY)
		
func _input(event) -> void:
	if event.is_action_pressed("open_buy_menu"):
		show_preview = !show_preview
		$Sprite.modulate.a = OPACITY * int(show_preview)
		update_pos(get_global_mouse_position())
	elif show_preview:
		if event is InputEventMouseMotion:
			update_pos(event.position)
		if event is InputEventMouseButton:
			if event.is_action("buy_sell_tiles_objects"):
				pressed = !pressed

func update_pos(mouse_coord) -> void:
	var current_tile = ground.world_to_map(mouse_coord)
	if current_tile != tile_pos:
		$Sprite.modulate.a = OPACITY * int(ground.get_cellv(current_tile) == ground.GRASS)
		tile_pos = current_tile
		var pos = ground.map_to_world(tile_pos)
		new_pos = Vector2(pos.x + ground.TILE_SIZE_HALF_X, pos.y + ground.TILE_SIZE_HALF_Y)
