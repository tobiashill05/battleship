extends Cursor

signal ship_rotated
signal ship_position_set

var is_horizontal : bool
var is_v_flipped : bool
var ship_type : int

var SPRITES: Array[Rect2] = [Rect2(0, 0, 32, 64), Rect2(64, 0, 32, 96), Rect2(128, 0, 32, 96), Rect2(192, 0, 32, 128), Rect2(256, 0, 32, 160)]

const DESTROYER = 0
const SUBMARINE = 1
const CRUISER = 2 
const BATTLESHIP = 3 
const CARRIER = 4

const UP = 0
const DOWN = 1
const LEFT = 2
const RIGHT = 3

func rotate_ship():
	if sprite.rotation == 0:
		sprite.rotate(PI / 2 * -1)
		sprite.position += Vector2(0, Global.tile_pixel_size)
	else:
		sprite.rotation = 0
		sprite.position -= Vector2(0, Global.tile_pixel_size) 
		sprite.flip_v = not sprite.flip_v
	
	dimensions = swapped_vector2i(dimensions)
	
	var offset = tiles_off_grid() - Vector2i(1, 1)
	if not fits_down():
		position.y -= offset.y * Global.tile_pixel_size
	if not fits_to_the_right():
		position.x -= offset.x * Global.tile_pixel_size
	
	is_horizontal = sprite.rotation != 0
	is_v_flipped = sprite.flip_v
	
	ship_rotated.emit()

func get_forward_direction():
	if is_horizontal:
		if is_v_flipped:
			return LEFT
		else:
			return RIGHT
	else:
		if is_v_flipped:
			return UP
		else:
			return DOWN

func get_dimensions():
	dimensions = Vector2i( floori(sprite.texture.region.size.x / Global.sprite_pixel_size), floori(sprite.texture.region.size.y / Global.sprite_pixel_size))

func init_ship(ship : int):
	sprite.texture.region = SPRITES[ship]
	ship_type = ship
	get_dimensions()
	#update_position_on_game_grid()

func swapped_vector2i(vector : Vector2i):
	return Vector2i(vector.y, vector.x)

func remove_cursor():
	queue_free()

func emit_enter_action():
	if Input.is_key_pressed(KEY_ENTER):
		ship_position_set.emit(position_on_game_grid, (ship_type * 4) + get_forward_direction())

func emit_space_action():
	rotate_ship()

func is_overlapping_other_tile(player : Player):
	for y in dimensions.y:
		for x in dimensions.x:
			if player.is_ocean_tile_occupied(position_on_game_grid + Vector2i(x, y)):
				return true
	return false
