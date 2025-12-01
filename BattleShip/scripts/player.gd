class_name Player extends Control

signal missile_fired
signal bombed_objective
signal missed_objective

@export var radar_grid : TileMap
@export var ocean_grid : TileMap

@export var enemy : Player
@export var attack_cursor : Cursor

var score : int

var ship_layer : int = 0
var ship_source_id : int = 0

var token_layer : int = 1
var token_source_id : int = 1

const WATER_TOKEN_COORD : Vector2i = Vector2i(2, 0)
const BOMBED_TOKEN_COORD : Vector2i = Vector2i(3, 0)
const GREEN_TOKEN_COORD : Vector2i = Vector2i(0, 0)
const RED_TOKEN_COORD : Vector2i = Vector2i(1, 0)

func _ready():
	attack_cursor.pressed.connect(_on_attack_cursor_pressed)

func add_green_token(new_token_position: Vector2i):
	radar_grid.set_cell(token_layer, new_token_position, token_source_id, GREEN_TOKEN_COORD)

func add_red_token(new_token_position: Vector2i):
	radar_grid.set_cell(token_layer, new_token_position, token_source_id, RED_TOKEN_COORD)

func add_water_token(new_token_position: Vector2i):
	ocean_grid.set_cell(token_layer, new_token_position, token_source_id, WATER_TOKEN_COORD)

func add_bombed_token(new_token_position: Vector2i):
	ocean_grid.set_cell(token_layer, new_token_position, token_source_id, BOMBED_TOKEN_COORD)

func set_ship_pattern(ship_pattern_id : int, dst_coords : Vector2i):
	#sdst_coords += Vector2i($OceanTexture.position)
	ocean_grid.set_pattern(ship_layer, dst_coords, radar_grid.tile_set.get_pattern(ship_pattern_id))

func is_radar_tile_occupied(tile_pos : Vector2i):
	return not radar_grid.get_cell_source_id(token_layer, tile_pos) == -1

func is_ocean_tile_occupied(tile_pos : Vector2i):
	return not ocean_grid.get_cell_source_id(ship_layer, tile_pos) == -1

func add_score():
	score += 1

func get_score():
	return score

func pause():
	attack_cursor.pause()
	hide()

func unpause():
	attack_cursor.unpause()
	show()

func _on_attack_cursor_pressed(cursor_pos : Vector2i):
	missile_fired.emit(cursor_pos)
