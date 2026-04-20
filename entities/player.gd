extends Area2D

@onready var main = get_tree().get_root().get_node("main")
@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("tile_map")
@export var item_menu: PackedScene
@export var pause_menu: PackedScene
@onready var hurt_sound = $DamageSound
@onready var atk_sound = $AttackSound
@onready var echo_sound = $EchoSound
@onready var death_sound = $DeathSound
const PING_RANGE: int = 8


var echo = preload("res://ui/echo.gd")
var atk = preload("res://ui/attack_animation.gd")
signal ping
signal end_turn
signal toggle_visibility

var grid_pos: Vector2i
# right, down, left, up
var facing: int = 0
var items: Array[Lib.Item]
var hp: int = 20
var max_hp: int = 20
var sight_turns: int = 0

func _ready():
	grid_pos = tile_map.local_to_map(position)
	items = [Lib.Item.new("repair kit", 0), 
	Lib.Item.new("signal booster", 1),
	Lib.Item.new("charm bracelet", 8),
	Lib.Item.new("dirk", 0, true, [Vector2i(1, 0)], 2), 
	Lib.Item.new("dirk of cronus", 0, true, [Vector2i(1, 0), Vector2i(2, 0)], 5)]
	update_hud()
	
func _process(delta: float):
	pass

func _unhandled_input(event: InputEvent):
	var moved = false
	var acted = false
	if event.is_action_pressed("move_down"):
		facing = 1
		update_facing()
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, 1)):
			position.y += tile_map.tile_set.tile_size.y
			grid_pos.y += 1
			moved = true
	if event.is_action_pressed("move_up"):
		facing = 3
		update_facing()
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(0, -1)):
			position.y -= tile_map.tile_set.tile_size.y
			grid_pos.y -= 1
			moved = true
	if event.is_action_pressed("move_left"):
		facing = 2
		update_facing()
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(-1, 0)):
			position.x -= tile_map.tile_set.tile_size.x
			grid_pos.x -= 1
			moved = true
	if event.is_action_pressed("move_right"):
		facing = 0
		update_facing()
		if !tile_map.astar.is_point_solid(grid_pos + Vector2i(1, 0)):
			position.x += tile_map.tile_set.tile_size.x
			grid_pos.x += 1
			moved = true
	if event.is_action_pressed("face_button_left"):
		echo_sound.play()
		ping.emit(grid_pos, PING_RANGE)
		echo.spawn(get_tree(), global_position, Color.html("#89d9fc"))
		acted = true
	if event.is_action_pressed("face_button_up"):
		var menu = item_menu.instantiate()
		menu.items = items
		menu.player = self
		main.add_child(menu)
	if event.is_action_pressed("pause"):
		var menu = pause_menu.instantiate()
		main.add_child(menu)
	if event.is_action_pressed("face_button_down"):
		acted = true
		var area = [Vector2i(1, 0)]
		var damage = 1
		for item in items:
			if item.is_equipped:
				area = item.attack_area
				damage = item.attack_damage
				
		var transform: Transform2D
		match facing:
			0: transform = Transform2D(Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 0))
			1: transform = Transform2D(Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, 0))
			2: transform = Transform2D(Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 0))
			3: transform = Transform2D(Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 0))
		
		for point in area:
			point = Vector2i(transform * Vector2(point))
			atk.spawn(get_tree(), (Vector2(grid_pos + point) + Vector2(0.5, 0.5)) * tile_map.astar.cell_size)
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if grid_pos + point == enemy.grid_pos:
					enemy.take_damage(damage)
		atk_sound.play()
		
	if moved and items.size() < 8 and tile_map.loot_map[grid_pos.x][grid_pos.y] != null:
		var loot = tile_map.loot_map[grid_pos.x][grid_pos.y]
		tile_map.loot_map[grid_pos.x][grid_pos.y] = null
		items.append(loot.item)
		loot.queue_free()
		
	if moved or acted:
		if sight_turns > 0:
			sight_turns -= 1
			if sight_turns == 0:
				toggle_visibility.emit(false)
				
		end_turn.emit()

func take_damage(amount):
	hp -= amount
	update_hud()
	hurt_sound.play()
	if hp <= 0:
		var saved = false
		for idx in items.size():
			if items[idx].effect == 3:
				hp = max_hp
				update_hud()
				items.pop_at(idx)
				saved = true
				print("the mysterious totem has saved you!")
				break
		
		if not saved:
			get_tree().change_scene_to_file("res://level/lose.tscn")
	
func update_hud():
	$Camera2D/Hud.find_child("hp_bar").value = (float(hp) / max_hp) * 100
	
func update_facing():
	for indicator in $facing_indicators.get_children():
		indicator.visible = false
	$facing_indicators.get_child(facing).visible = true
	
func use_item(effect):
	match effect:
		0:
			# repair kit
			hp = max_hp
			update_hud()
		1: 
			sight_turns = 20
			toggle_visibility.emit(true)
		2:
			pass # reveals map
		4:
			# plating kit
			max_hp += 5
			hp += 5
			update_hud()
		5: 
			# unnamed bomb thing (attacks enemy in front)
			var point: Vector2i
			match facing:
				0: point = Vector2i(1, 0)
				1: point = Vector2i(0, 1)
				2: point = Vector2i(-1, 0)
				3: point = Vector2i(0, -1)
				
			atk.spawn(get_tree(), (Vector2(grid_pos + point) + Vector2(0.5, 0.5)) * tile_map.astar.cell_size)
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if grid_pos + point == enemy.grid_pos:
					enemy.take_damage(20)
#		6:
#			var point: Vector2i
#			match facing:
#				0: point = Vector2i(1, 0)
#				1: point = Vector2i(0, 1)
#				2: point = Vector2i(-1, 0)
#				3: point = Vector2i(0, -1)
#				
#			for enemy in get_tree().get_nodes_in_group("enemies"):
#				if grid_pos + point == enemy.grid_pos:
#					var dest: Vector2i = Vector2i(-1, -1)
#					while dest == Vector2i(-1, -1):
#						var temp = Vector2i(randi() % tile_map.astar.region.end.x, randi() % tile_map.astar.region.end.y)
#						if !tile_map.astar.is_point_solid(temp):
#							dest = temp
#							
#					tile_map.astar.set_point_solid(enemy.grid_pos, false)
#					tile_map.astar.set_point_solid(dest, true)
#					enemy.grid_pos = dest
#					enemy.position = (Vector2(grid_pos + point) + Vector2(0.5, 0.5)) * tile_map.astar.cell_size
		7: 
			pass # damage all enemies in room
	
	end_turn.emit()
	
