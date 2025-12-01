extends Node

signal turn_finished
signal action_accepted
signal action_denied

@export var ship_cursor_scene : PackedScene
@export var player_1 : Player
@export var player_2 : Player
@export var HUD : Control

var cursor_holder : Marker2D

var current_cursor: Cursor
var current_player : Player
var game_paused : bool = true

func _ready():
	player_1.missile_fired.connect(_on_player_1_missile_fired)
	player_2.missile_fired.connect(_on_player_2_missile_fired)
	turn_finished.connect(_on_turn_finished) 
	cursor_holder = get_node("ShipCursorHolder")
	current_player = player_1
	current_player.enemy.pause()
	
	game_init()

func game_init():
	HUD.change_text("PLAYER ONE: Get ready!")
	player_set_ship_positions()
	await turn_finished
	await HUD.next_turn_button_pressed
	
	HUD.change_text("PLAYER TWO: Get ready!")
	current_player.attack_cursor.pause()
	
	player_set_ship_positions()
	await turn_finished


func _on_action_accepted():
	get_node("SFX/UIAccepted").play()

func _on_action_denied():
	get_node("SFX/UIDenied").play()

func _on_player_bombed_objective():
	HUD.animate_damage()
	get_node("SFX/Explosion").play()
	current_player.add_score()

func _on_player_missed_objective():
	HUD.animate_water_splash()
	get_node("SFX/Missed").play()

func _on_player_1_missile_fired(cursor_pos : Vector2i):
	if not current_cursor.is_overlapping_other_tile(current_player):
		
		current_player.add_green_token(cursor_pos)
		current_cursor.pause()
		get_node("SFX/MissileLaunch").play()
		await get_node("SFX/MissileLaunch").finished
		
		if current_player.enemy.is_ocean_tile_occupied(cursor_pos):
			current_player.bombed_objective.emit()
			current_player.add_red_token(cursor_pos)
			current_player.enemy.add_bombed_token(cursor_pos)
			current_cursor.unpause()
		else:
			current_player.missed_objective.emit()
			current_player.enemy.add_water_token(cursor_pos)
			turn_finished.emit()
		
		action_accepted.emit()
	else:
		action_denied.emit()

func _on_player_2_missile_fired(cursor_pos : Vector2i):
	_on_player_1_missile_fired(cursor_pos)

func _on_ship_cursor_ship_position_set(ship_origin : Vector2i, type_and_direction : int):
	if not current_cursor.is_overlapping_other_tile(current_player):
		current_player.set_ship_pattern(type_and_direction, ship_origin)
		action_accepted.emit()
	else:
		action_denied.emit()

func player_set_ship_positions():
	for ship in range(Global.SHIP_TYPES):
		# Add new ship cursor
		cursor_holder.add_child(ship_cursor_scene.instantiate())
		
		# Get last added child 
		current_cursor = cursor_holder.get_child(0)
		current_cursor.ship_position_set.connect(_on_ship_cursor_ship_position_set)
		current_cursor.unpause()
		current_cursor.init_ship(ship)
		
		await action_accepted
		current_cursor.remove_cursor()
		cursor_holder.remove_child(current_cursor)
	turn_finished.emit()

func next_turn():
	change_current_player()

func change_current_player():
	HUD.next_turn_screen()
	await HUD.next_turn_button_pressed
	
	current_player.pause()
	if current_player == player_1:
		current_player = player_2
		HUD.change_text("PLAYER TWO: Time to Attack!")
	else:
		current_player = player_1
		HUD.change_text("PLAYER ONE: Time to Attack!")
	current_player.unpause()
	current_cursor = current_player.attack_cursor

func _on_turn_finished():
	if player_1.get_score() >= 17:
		HUD.change_text("PLAYER ONE HAS WON!!!!")
	elif player_2.get_score() >= 17:
		HUD.change_text("PLAYER TWO HAS WON!!!!")
	else:
		next_turn()
