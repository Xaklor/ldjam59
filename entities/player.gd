extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("tile_map")
signal ping

var grid_pos: Vector2i

func _ready():
	grid_pos = tile_map.local_to_map(position)
	
func _process(delta: float):
	pass

func _input(event: InputEvent):
	if event.is_action_pressed("move_down"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, 1)):
			position.y += tile_map.tile_set.tile_size.y
			grid_pos.y += 1
	if event.is_action_pressed("move_up"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, -1)):
			position.y -= tile_map.tile_set.tile_size.y
			grid_pos.y -= 1
	if event.is_action_pressed("move_left"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(-1, 0)):
			position.x -= tile_map.tile_set.tile_size.x
			grid_pos.x -= 1
	if event.is_action_pressed("move_right"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(1, 0)):
			position.x += tile_map.tile_set.tile_size.x
			grid_pos.x += 1
	if event.is_action_pressed("face_button_up"):
		ping.emit()

func take_damage(amount):
	pass
