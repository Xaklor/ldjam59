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
	
# take a turn
func step():
	# stabby is weak but always aggressive
	pass

# called when the player is in range and this enemy wants to attack them
func intend_to_attack():
	pass

# called when something causes this to take damage
func take_damage(amount):
	pass

# called when the player uses a ping
func on_player_ping():
	pass
