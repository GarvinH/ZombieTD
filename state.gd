extends Node

enum COLLISION_LAYER {
	player,
	tiles,
	ground_enemies,
	air_enemies,
	map_objects,
	bullets
}

enum MODE {
	building,
	fighting
}

var flowField := {}

var started := false #Has game started?
var can_spawn := false
var mode = MODE.fighting
var time_left := 60
var run_timer := false
var can_shop := false
