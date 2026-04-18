extends CanvasLayer

var slot_num: int = 0
var items: Array[Lib.Item] = []

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
	
func _input(event: InputEvent):
	if event.is_action_pressed("move_down"):
		if slot_num < items.size() - 1:
			slot_num += 1
			$selector.position.y += 36
	if event.is_action_pressed("move_up"):
		if slot_num > 0:
			slot_num -= 1
			$selector.position.y -= 36
	if event.is_action_pressed("face_button_down") and items.size() > 0:
		if items[slot_num].is_equipment:
			for idx in items.size():
				if items[idx].is_equipment and items[idx].is_equipped:
					items[idx].is_equipped = false
					$menu_list.get_child(idx).get_child(0).texture = load("res://assets/sword.png")
			items[slot_num].is_equipped = true
			$menu_list.get_child(slot_num).get_child(0).texture = load("res://assets/eq sword.png")
		else:
			items.pop_at(slot_num)
			$menu_list.get_child(slot_num).queue_free()
			if slot_num == items.size() and slot_num != 0:
				slot_num -= 1
				$selector.position.y -= 36
		
	if event.is_action_pressed("face_button_right"):
		queue_free()
	get_viewport().set_input_as_handled()
