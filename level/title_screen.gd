extends Node2D
var time: float = 0

func _process(delta: float) -> void:
	time += delta
	if int(time) % 2 == 0:
		$cursor.visible = true
	else:
		$cursor.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("face_button_down"):
		get_tree().change_scene_to_file("res://level/main.tscn")
