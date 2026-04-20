extends CanvasLayer

var slot_num: int = 0

func _input(event: InputEvent):
	get_viewport().set_input_as_handled()
	if event.is_action_pressed("move_down"):
		if slot_num < 2:
			slot_num += 1
			$selector.position.y += 24
	if event.is_action_pressed("move_up"):
		if slot_num > 0:
			slot_num -= 1
			$selector.position.y -= 24
	if event.is_action_pressed("face_button_down"):
		match slot_num:
			0: queue_free()
			1: get_tree().change_scene_to_file("res://level/title_screen.tscn")
			2: get_tree().quit()
	
	
