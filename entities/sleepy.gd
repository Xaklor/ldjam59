extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var player = main.get_node("player")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main")..get_node("dungeon").get_node("tile_map")
@onready var wake_up_sound = $AudioStreamPlayer
@onready var death_sound = $DeathSound
@onready var animation = $icon

var echo = preload("res://ui/echo.gd")
var atk = preload("res://ui/attack_animation.gd")
var sleep_ping_icon = preload("res://assets/sleeper-inactive.png")
var awake_ping_icon = preload("res://assets/sleeper-active.png")

var asleep: bool = true
var grid_pos: Vector2i
var hp = 10
var attack = 10
var pinged = false
var ready_to_attack = false

# initialization
func _ready():
	player.ping.connect(on_player_ping)
	grid_pos = tile_map.local_to_map(position)
	animation.play("asleep")

# per-frame processing
func _process(delta: float):
	pass
	
# take a turn
func step():
	if hp <= 0:
		play_death_sound()
		tile_map.astar.set_point_solid(grid_pos, false)
		queue_free()
		return
	# sleepy is strong but passive until pinged
	if !asleep:
		var curr_pos = tile_map.local_to_map(position)
		var player_pos = tile_map.local_to_map(player.position)
		
		tile_map.astar.set_point_solid(grid_pos, false)
		var path = tile_map.astar.get_id_path(curr_pos, player_pos)
		if path.size() > 2 and not ready_to_attack:
			var next_pos = tile_map.map_to_local(path[1])
			grid_pos = path[1]
			position = next_pos
			ready_to_attack = false
		elif path.size() <= 2 and ready_to_attack:
			atk.spawn(get_tree(), player.global_position)
			player.take_damage(attack)
			ready_to_attack = false
		elif not ready_to_attack:
			echo.spawn(get_tree(), global_position, Color.RED, awake_ping_icon)
			ready_to_attack = true
		else:
			ready_to_attack = false
	
	tile_map.astar.set_point_solid(grid_pos, true)
	if pinged:
		pinged = false
		if asleep:
			wake_up_sound.play()
			asleep = false
			animation.play("awake")
			echo.spawn(get_tree(), global_position, Color.RED, sleep_ping_icon)
		else:
			echo.spawn(get_tree(), global_position, Color.RED, awake_ping_icon)

# called when the player is in range and this enemy wants to attack them
func intend_to_attack():
	pass

# called when something causes them to take damage
func take_damage(amount):
	hp -= amount
	asleep = false
	
func play_death_sound():
	remove_child(death_sound)
	main.add_child(death_sound)
	death_sound.play()
	death_sound.finished.connect(death_sound.queue_free)
	
# called when the player uses a ping
func on_player_ping(pos, range):
	if abs(pos.x - grid_pos.x) + abs(pos.y - grid_pos.y) <= range:
		pinged = true
		
		
