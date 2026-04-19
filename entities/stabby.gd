extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var player = main.get_node("player")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("tile_map")
var grid_pos: Vector2i
var hp: int

# initialization
func _ready():
	grid_pos = tile_map.local_to_map(position)
	hp = 5
	
# per-frame processing
func _process(delta: float):
	pass

# take a turn
func step():
	if hp <= 0:
		tile_map.astar.set_point_solid(grid_pos, false)
		queue_free()
	var curr_pos = tile_map.local_to_map(position)
	var player_pos = tile_map.local_to_map(player.position)
	
	var path = tile_map.astar.get_id_path(curr_pos, player_pos)
	if path.size() < 3:
		return
		
	var next_pos = tile_map.map_to_local(path[1])
	tile_map.astar.set_point_solid(grid_pos, false)
	tile_map.astar.set_point_solid(path[1], true)
	grid_pos = path[1]
	position = next_pos

# called when the player is in range and this enemy wants to attack them
func intend_to_attack():
	pass

# called when something causes this to take damage
func take_damage(amount):
	hp -= amount

# called when the player uses a ping
func on_player_ping():
	pass
