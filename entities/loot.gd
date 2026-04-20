extends Node2D

@onready var main = get_tree().get_root().get_node("main")
@onready var player = main.get_node("player")
@onready var tile_map: TileMapLayer = main.get_node("dungeon").get_node("tile_map")
@export var item_name: String
@export var item_effect: int
var item_is_equipment: bool = false
var item_attack_area: Array[Vector2i] = []
var item_attack_damage: int = 0
var echo = preload("res://ui/echo.gd")
var ping_icon = preload("res://assets/orb.png")
var item: Lib.Item

func _ready():
	player.ping.connect(on_player_ping)
	item = Lib.Item.new(item_name, item_effect, item_is_equipment, item_attack_area, item_attack_damage)
	var grid_pos = tile_map.local_to_map(position)
	tile_map.loot_map[grid_pos.x][grid_pos.y] = self
	
func on_player_ping(pos, range):
	var grid_pos = tile_map.local_to_map(position)
	if abs(pos.x - grid_pos.x) + abs(pos.y - grid_pos.y) <= range:
		echo.spawn(get_tree(), global_position, Color("#2a983d"), ping_icon)
