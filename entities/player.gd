extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("tile_map")
@export var item_menu: PackedScene
signal ping

var grid_pos: Vector2i
var items: Array[Lib.Item]

func _ready():
	grid_pos = tile_map.local_to_map(position)
	items = [Lib.Item.new("banana", 0), Lib.Item.new("bananarang", 0), Lib.Item.new("dirk", 0, true, [Vector2i(1, 0)], 2), Lib.Item.new("dirk of cronus", 0, true, [Vector2i(1, 0)], 5)]
	
func _process(delta: float):
	pass

func _unhandled_input(event: InputEvent):
	var moved = false
	if event.is_action_pressed("move_down"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, 1)):
			position.y += tile_map.tile_set.tile_size.y
			grid_pos.y += 1
			moved = true
	if event.is_action_pressed("move_up"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, -1)):
			position.y -= tile_map.tile_set.tile_size.y
			grid_pos.y -= 1
			moved = true
	if event.is_action_pressed("move_left"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(-1, 0)):
			position.x -= tile_map.tile_set.tile_size.x
			grid_pos.x -= 1
			moved = true
	if event.is_action_pressed("move_right"):
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(1, 0)):
			position.x += tile_map.tile_set.tile_size.x
			grid_pos.x += 1
			moved = true
	if event.is_action_pressed("face_button_up"):
		ping.emit()
	if event.is_action_pressed("face_button_right"):
		var menu = item_menu.instantiate()
		menu.items = items
		main.add_child(menu)
		
	if moved and items.size() < 8 and tile_map.loot_map[grid_pos.x][grid_pos.y] != null:
		var loot = tile_map.loot_map[grid_pos.x][grid_pos.y]
		tile_map.loot_map[grid_pos.x][grid_pos.y] = null
		items.append(loot.item)
		loot.queue_free()

func take_damage(amount):
	pass
