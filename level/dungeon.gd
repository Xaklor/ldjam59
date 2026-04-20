extends Node2D

@onready var main = get_tree().get_root().get_node("main")
@onready var tile_map = $tile_map
@onready var player = main.get_node("player")

var stabby = preload("res://entities/stabby.tscn")
var sleepy = preload("res://entities/sleepy.tscn")
@export var loot_scene: PackedScene

const WIDTH = 40
const HEIGHT = 25

const ROOM_MIN = 5
const ROOM_MAX  = 10
const MIN_ROOMS = 4
const MAX_ROOMS = 7

const WALL = Vector2i(4, 0)
const FLOOR = Vector2i(4,1)
const STAIRS = Vector2i(4, 2)

var grid = []
var rooms = []
var stairs_pos: Vector2i
var curr_floor: int

func _ready():
	curr_floor = 1
	next_floor()

func next_floor():
	if curr_floor >= 5:
		get_tree().change_scene_to_file("res://level/win.tscn")
		return
		
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	
	for item in get_tree().get_nodes_in_group("items"):
		print(item)
		item.queue_free()
		
	generate_dungeon()
	tile_map.initialize()
	var start = rooms[0].get_center()
	var start_pos = tile_map.map_to_local(start)
	player.global_position = start_pos
	player.grid_pos = start
	generate_entities.call_deferred()
	
	curr_floor += 1
	
	for y in tile_map.astar.region.end.y:
		var out = ""
		for x in tile_map.astar.region.end.x:
			if tile_map.astar.is_point_solid(Vector2i(x, y)):
				out += "#"
			else:
				out += "."
		print(out)
		
func _input(event):
	if player.grid_pos == stairs_pos:
		next_floor()

func generate_dungeon():
	initialize_grid()
	for i in range(randi_range(MIN_ROOMS, MAX_ROOMS)):
		var retries = 1000
		var valid_room = generate_room()
		while (!valid_room and retries > 0):
			valid_room = generate_room()
			retries -= 1
			
	generate_corridors(rooms)
	generate_walls()
	
	stairs_pos = rooms[rooms.size() - 1].get_center()
	grid[stairs_pos.x][stairs_pos.y] = STAIRS
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			tile_map.set_cell(Vector2i(x, y), 1, grid[x][y])

func generate_entities():
	for room in rooms.slice(1, rooms.size()):
		var num_enemies = randi() % 3
		var num_items = randi() % 3
		var used_pos = []
		for c in num_enemies:
			var spawn_pos = rand_point(room)
			while (spawn_pos in used_pos):
				spawn_pos = rand_point(room)
			spawn_enemy(spawn_pos)
			used_pos.append(spawn_pos)
			
		for c in num_items:
			var spawn_pos = rand_point(room)
			while (spawn_pos in used_pos):
				spawn_pos = rand_point(room)
			spawn_item(spawn_pos)
			used_pos.append(spawn_pos)

func rand_point(room):
	var x = randi_range(room.position.x, room.end.x - 1)
	var y = randi_range(room.position.y, room.end.y - 1)
	return Vector2i(x, y)

func spawn_enemy(pos):
	var enemy
	if randi() % 2 == 0:
		enemy = stabby.instantiate()
	else:
		enemy = sleepy.instantiate()
	enemy.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_map.astar.cell_size
	main.add_child(enemy)
	
func spawn_item(pos):
	var loot = loot_scene.instantiate()
	match randi() % 9:
		0:
			loot.item_name = "repair kit"
			loot.item_effect = 0
		1:
			loot.item_name = "signal booster"
			loot.item_effect = 1
		2:
			loot.item_name = "mysterious totem"
			loot.item_effect = 3
		3:
			loot.item_name = "plating kit"
			loot.item_effect = 4
		4:
			loot.item_name = "glass dust"
			loot.item_effect = 5
		5:
			loot.item_name = "dirk"
			loot.item_is_equipment = true
			var temp: Array[Vector2i] = [Vector2i(1, 0)]
			loot.item_attack_area = temp
			loot.item_attack_damage = 2
		6:
			loot.item_name = "wide sword"
			loot.item_is_equipment = true
			var temp: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, -1), Vector2i(1, 1)]
			loot.item_attack_area = temp
			loot.item_attack_damage = 4
		7:
			loot.item_name = "long sword"
			loot.item_is_equipment = true
			var temp: Array[Vector2i] = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
			loot.item_attack_area = temp
			loot.item_attack_damage = 4
		8:
			loot.item_name = "gilded dirk"
			loot.item_is_equipment = true
			var temp: Array[Vector2i] = [Vector2i(1, 0)]
			loot.item_attack_area = temp
			loot.item_attack_damage = 6
	
	loot.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_map.astar.cell_size
	main.add_child(loot)
	
func initialize_grid():
	grid.clear()
	rooms.clear()
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(WALL)

func generate_room():
	var room_width = randi_range(ROOM_MIN, ROOM_MAX)
	var room_height = randi_range(ROOM_MIN, ROOM_MAX)
	var room_x = randi_range(1, WIDTH - room_width - 1)
	var room_y = randi_range(1, HEIGHT - room_height - 1)
	var room = Rect2i(room_x, room_y, room_width, room_height)
	
	if !room_fits(room):
		return false
	
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = FLOOR
					
	rooms.append(room)
	return true
	
func generate_corridors(rooms):
	var connections = room_mst(rooms)
	for connection in connections:
		var start = rooms[connection.start].get_center()
		var end = rooms[connection.end].get_center()
		
		var x = start.x
		var y = start.y 
		var dx = 1 if start.x < end.x else -1
		var dy = 1 if start.y < end.y else -1
		
		for i in range(abs(start.x - end.x)):
			x += dx 
			grid[x][start.y] = FLOOR 
		
		for i in range(abs(start.y - end.y)):
			y += dy 
			grid[x][y] = FLOOR
	

# super inefficient kruskal's algorithm
func room_mst(rooms):
	var centers = []
	for room in rooms:
		centers.append(room.get_center())
	
	var room_dists = sorted_dist(centers)
	var n = room_dists.size()
	var mst = []
	var groups = range(n)
	for dist in room_dists:
		var start_group = groups[dist.start]
		var end_group = groups[dist.end]
		if start_group == end_group:
			continue
		
		mst.append(dist)
		for i in range(n):
			if groups[i] == start_group:
				groups[i] = end_group
	
	return mst
				
func sorted_dist(coords):
	var n = coords.size()
	var dists = []
	for i in range(n):
		for j in range(i + 1, n):
			dists.append({
				"start": i,    
				"end": j,    
				"d": coords[i].distance_to(coords[j])
			})
		
	dists.sort_custom(func(a, b):
		return a.d < b.d
	)
	
	return dists

func room_fits(new_room):
	if (new_room.end.x > WIDTH - 2 or 
		new_room.end.y > HEIGHT - 2 or 
		new_room.position.x < 2 or
		new_room.position.y < 2):
		return false
		
	for room in rooms:
		if room.intersects(new_room.grow(2)):
			return false
	return true
	
func generate_walls():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if grid[x][y] == WALL:
				grid[x][y] = determine_wall_type(x, y)

func determine_wall_type(x, y):
	var neighbors = {
		"NW": false,
		"N": false,
		"NE": false,
		"W": false,
		"E": false,
		"SW": false,
		"S": false,
		"SE": false
	}
	
	neighbors.NW = valid_tile(x - 1, y - 1) and grid[x - 1][y - 1] == FLOOR
	neighbors.N = valid_tile(x, y - 1) and grid[x][y - 1] == FLOOR
	neighbors.NE = valid_tile(x + 1, y - 1) and grid[x + 1][y - 1] == FLOOR
	neighbors.W = valid_tile(x - 1, y) and grid[x - 1][y] == FLOOR
	neighbors.E = valid_tile(x + 1, y) and grid[x + 1][y] == FLOOR
	neighbors.SW = valid_tile(x - 1, y + 1) and grid[x - 1][y + 1] == FLOOR
	neighbors.S = valid_tile(x, y + 1) and grid[x][y + 1] == FLOOR
	neighbors.SE = valid_tile(x + 1, y + 1) and grid[x + 1][y + 1] == FLOOR

	
	if neighbors.N and neighbors.E and neighbors.S and neighbors.W:
		return Vector2i(2, 0) # all sides
	if neighbors.N and neighbors.W and neighbors.S:
		return Vector2i(0, 1) # top left bot
	if neighbors.N and neighbors.E and neighbors.S:
		return Vector2i(2, 1) # top right bot
	if neighbors.N and neighbors.E and neighbors.W:
		return Vector2i(1, 1) # top left right
	if neighbors.E and neighbors.S and neighbors.W:
		return Vector2i(3, 1) # left right bot
	if neighbors.N and neighbors.S:
		return Vector2i(0, 0) # top bot
	if neighbors.E and neighbors.W:
		return Vector2i(1, 0) # left right
	if neighbors.N and neighbors.E:
		return Vector2i(0, 2) # top right
	if neighbors.N and neighbors.W:
		return Vector2i(1, 2) # top left
	if neighbors.S and neighbors.E:
		return Vector2i(3, 2) # bot right
	if neighbors.S and neighbors.W:
		return Vector2i(2, 2) # bot left
	if neighbors.NW and neighbors.NE and neighbors.SW and neighbors.SE:
		return Vector2i(3, 0) # four corners 
	if neighbors.N:
		return Vector2i(0, 4)
	if neighbors.E:
		return Vector2i(3, 4)
	if neighbors.S:
		return Vector2i(2, 4)
	if neighbors.W:
		return Vector2i(1, 4)
	if neighbors.NW:
		return Vector2i(1, 3)
	if neighbors.NE:
		return Vector2i(0, 3)
	if neighbors.SW:
		return Vector2i(2, 3)
	if neighbors.SE:
		return Vector2i(3, 3)
	return WALL

func valid_tile(x, y):
	return x > 0 and y > 0 and x < WIDTH and y < HEIGHT
