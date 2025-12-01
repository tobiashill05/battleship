class_name Cursor extends Node2D

signal pressed

@export var sprite : Sprite2D

var paused : bool = true
var dimensions: Vector2i
var movement_incremental : float = Global.tile_pixel_size
var position_on_game_grid : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	pause()
	update_position_on_game_grid()
	dimensions = Vector2i(1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not paused:
		if Input.is_action_just_pressed("ui_up") and fits_up():
			position.y -= Global.tile_pixel_size
		elif Input.is_action_just_pressed("ui_down") and fits_down():
			position.y += Global.tile_pixel_size
		elif Input.is_action_just_pressed("ui_right") and fits_to_the_right():
			position.x += Global.tile_pixel_size
		elif Input.is_action_just_pressed("ui_left") and fits_to_the_left():
			position.x -= Global.tile_pixel_size
		
		if Input.is_action_just_pressed("ui_accept"):
			emit_enter_action()
		
		if Input.is_action_just_pressed("ui_select"): 
			emit_space_action()
		
		update_position_on_game_grid()

func get_position_on_game_grid():
	return position_on_game_grid

func update_position_on_game_grid():
	position_on_game_grid = Vector2i( floori( (position.x / movement_incremental) + 1) , floori( (position.y / movement_incremental) + 1) )

func start_cursor():
	position = Vector2.ZERO
	show()

func fits_to_the_right():
	return tiles_off_grid().x <= 0

func fits_to_the_left():
	return position_on_game_grid.x > 1

func fits_up():
	return position_on_game_grid.y > 1

func fits_down():
	return tiles_off_grid().y <= 0

func tiles_off_grid():
	return (dimensions + position_on_game_grid) - Vector2i(Global.grid_size, Global.grid_size)

func emit_enter_action():
	pressed.emit(position_on_game_grid)
	await get_tree().create_timer(0.1).timeout

func emit_space_action():
	pass

func is_overlapping_other_tile(player : Player):
	if player.is_radar_tile_occupied(position_on_game_grid):
		return true
	return false

func pause():
	paused = true
	hide()

func unpause():
	paused = false
	show()
