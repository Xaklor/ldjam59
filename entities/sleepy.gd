extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var player = main.get_node("player")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("tile_map")
@onready var wake_up_sound = $AudioStreamPlayer

var echo = preload("res://entities/echo.gd")

var asleep: bool = true
var grid_pos: Vector2i
var hp = 10

# initialization
func _ready():
	player.ping.connect(on_player_ping)
	grid_pos = tile_map.local_to_map(position)

# per-frame processing
func _process(delta: float):
	pass
	
# take a turn
func step():
	if hp <= 0:
		tile_map.astar.set_point_solid(grid_pos, false)
		queue_free()
	# sleepy is strong but passive until pinged
	if asleep:
		return
	
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

# called when something causes them to take damage
func take_damage(amount):
	hp -= amount
	asleep = false
	
# called when the player uses a ping
func on_player_ping():
	wake_up_sound.play()
	echo.spawn(get_tree(), global_position, Color.BROWN)
	
	asleep = false
