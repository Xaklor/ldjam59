extends Node

@onready var player = get_node("player")

func _on_player_ping() -> void:
	print("ponging!")

func _on_player_end_turn() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("step"):
			enemy.step()
