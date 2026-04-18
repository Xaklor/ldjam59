extends Node

@onready var player = get_node("player")

func _on_player_ping() -> void:
	print("ponging!")
