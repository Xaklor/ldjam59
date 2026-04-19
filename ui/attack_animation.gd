extends AnimatedSprite2D

static var attack_scene = preload("res://ui/attack_animation.tscn")

func _ready():
	play("default")
	
func _on_animation_finished():
	queue_free()

static func spawn(tree, pos):
	var attack = attack_scene.instantiate()
	tree.current_scene.add_child(attack)
	attack.global_position = pos
