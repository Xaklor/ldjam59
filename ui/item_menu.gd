extends CanvasLayer

@onready var tile_map: TileMapLayer = get_tree().get_root().get_node("main").get_node("dungeon").get_node("tile_map")
@export var loot_scene: PackedScene	
var slot_num: int = 0
var items: Array[Lib.Item] = []
var player

func _ready():
	for item in items:
		var entry = HBoxContainer.new()
		var icon = TextureRect.new()
		var label = Label.new()
		if item.is_equipment:
			if item.is_equipped:
				icon.texture = load("res://assets/eq sword.png")
			else:
				icon.texture = load("res://assets/sword.png")
		else:
			icon.texture = load("res://assets/orb.png")
		label.text = item.name
		entry.add_theme_constant_override("separation", 10)
		entry.add_child(icon)
		entry.add_child(label)
		$menu_list.add_child(entry)
		update_tooltip()
	
func _input(event: InputEvent):
	if event.is_action_pressed("move_down"):
		if slot_num < items.size() - 1:
			slot_num += 1
			$selector.position.y += 36
			update_tooltip()
	if event.is_action_pressed("move_up"):
		if slot_num > 0:
			slot_num -= 1
			$selector.position.y -= 36
			update_tooltip()
	if event.is_action_pressed("face_button_down") and items.size() > 0:
		if items[slot_num].is_equipment:
			for idx in items.size():
				if items[idx].is_equipment and items[idx].is_equipped:
					items[idx].is_equipped = false
					$menu_list.get_child(idx).get_child(0).texture = load("res://assets/sword.png")
			items[slot_num].is_equipped = true
			$menu_list.get_child(slot_num).get_child(0).texture = load("res://assets/eq sword.png")
		else:
			if items[slot_num].effect != 3 and items[slot_num].effect != 8:
				var effect = items[slot_num].effect
				items.pop_at(slot_num)
				$menu_list.get_child(slot_num).queue_free()
				player.use_item(effect)
				queue_free()
	if event.is_action_pressed("face_button_left") and items.size() > 0 and tile_map.loot_map[player.grid_pos.x][player.grid_pos.y] == null:
		var item = items[slot_num]
		var loot = loot_scene.instantiate()
		loot.item_name = item.name
		loot.item_effect = item.effect
		loot.item_is_equipment = item.is_equipment
		loot.item_attack_area = item.attack_area
		loot.item_attack_damage = item.attack_damage
		loot.position = player.position
		get_tree().get_root().add_child(loot)
		items.pop_at(slot_num)
		queue_free()
		
	if event.is_action_pressed("face_button_up"):
		queue_free()
	get_viewport().set_input_as_handled()
	
func update_tooltip():
	if items.size() > 0:
		var item = items[slot_num]
		if item.is_equipment:
			match item.name:
				"dirk": $tooltip.text = "a dirk. does 2 damage."
				"dirk of cronus": $tooltip.text = "the cooler dirk. does 5 damage."
				_: $tooltip.text = "moooooom! atlas got into the tooltips again!"
		else:
			match items[slot_num].effect:
				0: $tooltip.text = "fully restores lost HP."
				1: $tooltip.text = "restores sight for 20 turns, allowing you to directly see enemies and items."
				2: $tooltip.text = "cheater."
				3: $tooltip.text = "unusable. restores you to full HP upon death once."
				4: $tooltip.text = "permanently increases max HP by 5."
				5: $tooltip.text = "inflicts 20 damage on the enemy you are currently facing."
				7: $tooltip.text = "inflicts 10 damage on all enemies within 10 spaces."
				8: $tooltip.text = "unusable. a good luck charm."
				_: $tooltip.text = "bananarama_atlas"
