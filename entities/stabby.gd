extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var player = main.get_node("player")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("dungeon").get_node("tile_map")
@onready var death_sound = $DeathSound
var grid_pos: Vector2i
var hp: int = 5
var attack: int = 5
var echo = preload("res://ui/echo.gd")
var atk = preload("res://ui/attack_animation.gd")
var ping_icon = preload("res://assets/stabby.png")
var pinged = false
var ready_to_attack = false

# initialization
func _ready():
	player.ping.connect(on_player_ping)
	grid_pos = tile_map.local_to_map(position)
	
# per-frame processing
func _process(delta: float):
	pass

# take a turn
func step():
	if not is_inside_tree():
		return
	if hp <= 0:
		play_death_sound()
		tile_map.astar.set_point_solid(grid_pos, false)
		queue_free()
		return
	var curr_pos = tile_map.local_to_map(position)
	var player_pos = tile_map.local_to_map(player.position)
	
	tile_map.astar.set_point_solid(grid_pos, false)
	var path = tile_map.astar.get_id_path(curr_pos, player_pos)
	# player is not adjacent to this enemy
	if path.size() > 2 and path.size() != 0 and path.size() <= 10 and not ready_to_attack:
		var next_pos = tile_map.map_to_local(path[1])
		grid_pos = path[1]
		position = next_pos
		ready_to_attack = false
	 # player IS adjacent to this enemy
	elif path.size() <= 2 and path.size() != 0 and ready_to_attack:
		atk.spawn(get_tree(), player.global_position)
		player.take_damage(attack)
		ready_to_attack = false
	elif not ready_to_attack and path.size() != 0 and path.size() <= 10:
		echo.spawn(get_tree(), global_position, Color.RED, ping_icon)
		ready_to_attack = true
	else:
		ready_to_attack = false

	tile_map.astar.set_point_solid(grid_pos, true)
	if pinged:
		echo.spawn(get_tree(), global_position, Color.RED, ping_icon)
		pinged = false

# called when the player is in range and this enemy wants to attack them
func intend_to_attack():
	pass
	
func play_death_sound():
	remove_child(death_sound)
	main.add_child(death_sound)
	death_sound.play()
	death_sound.finished.connect(death_sound.queue_free)

# called when something causes this to take damage
func take_damage(amount):
	hp -= amount

# called when the player uses a ping
func on_player_ping(pos, range):
	if abs(pos.x - grid_pos.x) + abs(pos.y - grid_pos.y) <= range:
		pinged = true
