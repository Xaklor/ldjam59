extends Node

@onready var player = get_node("player")

func _on_player_ping() -> void:
	print("ponging!")

func _on_player_end_turn() -> void:
	for child in get_children():
		if child.has_method("step"):
			child.step()

func _on_player_toggle_visibility(vis: bool) -> void:
	for node in get_tree().get_nodes_in_group("sight toggleable"):
		node.find_child("icon").visible = vis
