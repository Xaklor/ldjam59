extends Node

var hp: int = 20
var max_hp: int = 20
var items: Array[Lib.Item] = [
	Lib.Item.new("repair kit", 0), 
	Lib.Item.new("signal booster", 1),
	Lib.Item.new("charm bracelet", 8),
	Lib.Item.new("dirk", 0, true, [Vector2i(1, 0)], 2), 
	Lib.Item.new("dirk of cronus", 0, true, [Vector2i(1, 0), Vector2i(2, 0)], 5)
]
var sight_turns: int = 0
var facing: int = 0

func reset():
	hp = 20
	max_hp = 20
	items = [
		Lib.Item.new("repair kit", 0), 
		Lib.Item.new("signal booster", 1),
		Lib.Item.new("charm bracelet", 8),
		Lib.Item.new("dirk", 0, true, [Vector2i(1, 0)], 2), 
		Lib.Item.new("dirk of cronus", 0, true, [Vector2i(1, 0), Vector2i(2, 0)], 5)
	]
	sight_turns = 0
	facing = 0
