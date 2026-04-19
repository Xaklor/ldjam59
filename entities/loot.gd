extends Sprite2D

@onready var main = get_tree().get_root().get_node("main")
@onready var player = main.get_node("player")
@onready var tile_map: TileMapLayer = main.get_node("tile_map")
var echo = preload("res://ui/echo.gd")
var item: Lib.Item

func _ready():
	player.ping.connect(on_player_ping)
	item = Lib.Item.new("fermented pineapple", 1)
	var grid_pos = tile_map.local_to_map(position)
	tile_map.loot_map[grid_pos.x][grid_pos.y] = self
	
func on_player_ping():
	echo.spawn(get_tree(), global_position, Color("#2a983d"))
