extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var player = main.get_node("player")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("tile_map")

# initialization
func _ready():
	pass
	
	
# per-frame processing
func _process(delta: float):
	pass

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("move_up") or
	   	event.is_action_pressed("move_down") or
	   	event.is_action_pressed("move_left") or
	   	event.is_action_pressed("move_right")):
		step()

# take a turn
func step():
	var curr_pos = tile_map.local_to_map(position)
	var player_pos = tile_map.local_to_map(player.position)
	
	var path = tile_map.astar.get_id_path(curr_pos, player_pos)
	if path.size() < 2:
		return
		
	var next_pos = tile_map.map_to_local(path[1])
	position = next_pos

# called when the player is in range and this enemy wants to attack them
func intend_to_attack():
	pass

# called when something causes this to take damage
func take_damage(amount):
	pass

# called when the player uses a ping
func on_player_ping():
	pass
