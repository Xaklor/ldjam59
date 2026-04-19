extends Node

@onready var player = get_node("player")

func _on_player_ping() -> void:
	print("ponging!")

func _on_player_end_turn() -> void:
	for child in get_children():
		if child.has_method("step"):
			child.step()
