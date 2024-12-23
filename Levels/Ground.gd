extends TileMap

# Shoud be constants but cannot be
var GRASS : int = tile_set.find_tile_by_name("Grass")
var SPAWNER : int = tile_set.find_tile_by_name("Spawner")
var WALL : int = tile_set.find_tile_by_name("Wall")

onready var grass := get_used_cells_by_id(GRASS)
onready var spawners := get_used_cells_by_id(SPAWNER)
onready var player := get_tree().get_root().find_node("Player", true, false)

# Should be constants but cannot be
var TILE_SIZE_HALF_X : int = cell_size.x/2;
var TILE_SIZE_HALF_Y : int = cell_size.y/2;
var TILE_SIZE_HALF_VECTOR: Vector2 = Vector2(TILE_SIZE_HALF_X, TILE_SIZE_HALF_Y)

var astar : AStar2D
var mutex
var semaphore
var thread

func _ready() -> void:
	randomize()
	var navigate_tiles = spawners + grass
	astar = generate_astar(navigate_tiles)
	State.flowField = fill_flow_field(navigate_tiles)
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	thread = Thread.new()
	thread.start(self, "_thread_function")
	
func can_buy_wall(pos : Vector2) -> bool:
	var astar_buy_wall_id = astar.get_closest_point(pos)
	var astar_player_id = astar.get_closest_point(player.global_position)
	
	# Don't want to disable astar point if filling flow field
	mutex.lock()
	astar.set_point_disabled(astar_buy_wall_id, true)
	
	var can_buy : bool = true
	
	# Check astar connections from all spawners (because its efficient and can check all possibilities)
	for spawner_tile in spawners:
		if astar.get_id_path(astar.get_closest_point(map_to_world(spawner_tile)+TILE_SIZE_HALF_VECTOR), astar_player_id).empty():
			can_buy = false
	
	astar.set_point_disabled(astar_buy_wall_id, false)
	mutex.unlock()
	return can_buy
	
func buy_wall(tile_pos : Vector2) -> void:
	#if (State.can_shop and State.started):
	if (get_cellv(tile_pos) == GRASS):
		set_cellv(tile_pos, WALL)
		
		#get astar point id for position of wall being purchased
		var astar_point_id = astar.get_closest_point(map_to_world(tile_pos)+TILE_SIZE_HALF_VECTOR)
		
		astar.set_point_disabled(astar_point_id, true)
	
# Creating the graph for movement of ground enemies
func generate_astar(tiles: Array) -> AStar2D:
	var _astar : AStar2D = AStar2D.new()
	var id = 0
	for tile in tiles:
		var tile_pos = map_to_world(tile)
		tile_pos.x += TILE_SIZE_HALF_X
		tile_pos.y += TILE_SIZE_HALF_Y
		_astar.add_point(id, tile_pos, 1)
		id += 1
	for tile in tiles:
		for i in range(-1,2,2):
			var adjacent_tile = tile
			adjacent_tile.x += i
			if adjacent_tile in tiles:
				if (tile in spawners && adjacent_tile in spawners):
					break # Don't connect spawners together
				var tile_pos = map_to_world(tile)
				tile_pos.x += TILE_SIZE_HALF_X
				tile_pos.y += TILE_SIZE_HALF_Y
				var adjacent_tile_pos = map_to_world(adjacent_tile)
				adjacent_tile_pos.x += TILE_SIZE_HALF_X
				adjacent_tile_pos.y += TILE_SIZE_HALF_Y
				if !(_astar.are_points_connected(_astar.get_closest_point(tile_pos), _astar.get_closest_point(adjacent_tile_pos))):
					_astar.connect_points(_astar.get_closest_point(tile_pos), _astar.get_closest_point(adjacent_tile_pos), true)
		for k in range(-1,2,2):
			var adjacent_tile = tile
			adjacent_tile.y += k
			if adjacent_tile in tiles:
				if (tile in spawners && adjacent_tile in spawners):
					break
				var tile_pos = map_to_world(tile)
				tile_pos.x += TILE_SIZE_HALF_X
				tile_pos.y += TILE_SIZE_HALF_Y
				var adjacent_tile_pos = map_to_world(adjacent_tile)
				adjacent_tile_pos.x += TILE_SIZE_HALF_X
				adjacent_tile_pos.y += TILE_SIZE_HALF_Y
				if !(_astar.are_points_connected(_astar.get_closest_point(tile_pos), _astar.get_closest_point(adjacent_tile_pos))):
					_astar.connect_points(_astar.get_closest_point(tile_pos), _astar.get_closest_point(adjacent_tile_pos), true)
	return _astar

# Filing in the flow field dictionary using generated AStar graph
func fill_flow_field(tiles: Array) -> Dictionary:
	var flowField := {}
	for tile in tiles:
		var tile_pos = map_to_world(tile)
		tile_pos.x += TILE_SIZE_HALF_X
		tile_pos.y += TILE_SIZE_HALF_Y
		var tile_id = astar.get_closest_point(tile_pos)
		var player_id = astar.get_closest_point(player.global_position)
		var path_to_player = astar.get_id_path(tile_id, player_id)
		var direction : = Vector2()
		if (path_to_player.size() > 1):
			direction = (astar.get_point_position(path_to_player[1]) - tile_pos).normalized()
		else:
			direction = (player.global_position - tile_pos).normalized()
			if (abs(direction.x) >= abs(direction.y)):
				direction.x = round(direction.x)
				direction.y = 0
			else:
				direction.x = 0
				direction.y = round(direction.y)
		flowField[tile] = direction
	return flowField
	
func _thread_function(_userdata) -> void:
	while true:
		semaphore.wait()
		
		var navigate_tiles := spawners + grass
		
		# Don't want to fill flow field if point is disabled
		mutex.lock()
		State.flowField = fill_flow_field(navigate_tiles)
		mutex.unlock()

func update_flow_field() -> void:
	if (!State.can_shop and State.started):
		semaphore.post()
