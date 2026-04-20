extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("tile_map")
@export var item_menu: PackedScene
const PING_RANGE: int = 8

var echo = preload("res://ui/echo.gd")
var atk = preload("res://ui/attack_animation.gd")
signal ping
signal end_turn

var grid_pos: Vector2i
# right, down, left, up
var facing: int = 0
var items: Array[Lib.Item]
var hp: int = 20
var max_hp: int = 20

func _ready():
	grid_pos = tile_map.local_to_map(position)
	items = [Lib.Item.new("banana", 0), Lib.Item.new("bananarang", 0), Lib.Item.new("dirk", 0, true, [Vector2i(1, 0)], 2), Lib.Item.new("dirk of cronus", 0, true, [Vector2i(1, 0), Vector2i(2, 0)], 5)]
	update_hud()
	
func _process(delta: float):
	pass

func _unhandled_input(event: InputEvent):
	var moved = false
	var acted = false
	if event.is_action_pressed("move_down"):
		facing = 1
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, 1)):
			position.y += tile_map.tile_set.tile_size.y
			grid_pos.y += 1
			moved = true
	if event.is_action_pressed("move_up"):
		facing = 3
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, -1)):
			position.y -= tile_map.tile_set.tile_size.y
			grid_pos.y -= 1
			moved = true
	if event.is_action_pressed("move_left"):
		facing = 2
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(-1, 0)):
			position.x -= tile_map.tile_set.tile_size.x
			grid_pos.x -= 1
			moved = true
	if event.is_action_pressed("move_right"):
		facing = 0
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(1, 0)):
			position.x += tile_map.tile_set.tile_size.x
			grid_pos.x += 1
			moved = true
	if event.is_action_pressed("face_button_left"):
		ping.emit(grid_pos, PING_RANGE)
		echo.spawn(get_tree(), global_position, Color.html("#89d9fc"))
		acted = true
	if event.is_action_pressed("face_button_up"):
		var menu = item_menu.instantiate()
		menu.items = items
		main.add_child(menu)
	if event.is_action_pressed("face_button_down"):
		acted = true
		var area = [Vector2i(1, 0)]
		var damage = 1
		for item in items:
			if item.is_equipped:
				area = item.attack_area
				damage = item.attack_damage
				
		var transform: Transform2D
		match facing:
			0:
				transform = Transform2D(Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 0))
			1:
				transform = Transform2D(Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, 0))
			2:
				transform = Transform2D(Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 0))
			3:
				transform = Transform2D(Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 0))
		
		for point in area:
			point = Vector2i(transform * Vector2(point))
			atk.spawn(get_tree(), (Vector2(grid_pos + point) + Vector2(0.5, 0.5)) * tile_map.astar.cell_size)
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if grid_pos + point == enemy.grid_pos:
					enemy.take_damage(damage)
		
	if moved and items.size() < 8 and tile_map.loot_map[grid_pos.x][grid_pos.y] != null:
		var loot = tile_map.loot_map[grid_pos.x][grid_pos.y]
		tile_map.loot_map[grid_pos.x][grid_pos.y] = null
		items.append(loot.item)
		loot.queue_free()
		
	if moved or acted:
		end_turn.emit()

func take_damage(amount):
	hp -= amount
	update_hud()
	if hp <= 0:
		print("owie owie ow I've died")
	
func update_hud():
	$Camera2D/Hud.find_child("hp_bar").value = (float(hp) / max_hp) * 100
