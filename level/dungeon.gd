extends Node2D

@onready  var tile_map = $TileMapLayer

const WIDTH = 80
const HEIGHT = 50

const ROOM_MIN = 5
const ROOM_MAX  = 10
const MIN_ROOMS = 15
const MAX_ROOMS = 30

const WALL = Vector2i(4, 0)
const FLOOR = Vector2i(4,1)

var grid = []
var rooms = []

func _ready():
	generate_dungeon()

func generate_dungeon():
	initialize_grid()
	for i in range(randi_range(MIN_ROOMS, MAX_ROOMS)):
		var retries = 1000
		var valid_room = generate_room()
		while (!valid_room and retries > 0):
			valid_room = generate_room()
			retries -= 1
	
	generate_corridors(rooms)
		
	for x in range(WIDTH):
		for y in range(HEIGHT):
			tile_map.set_cell(Vector2i(x, y), 1, grid[x][y])

func initialize_grid():
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
