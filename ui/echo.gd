extends Sprite2D

static var echo_scene = preload("res://ui/echo.tscn")
var time := 0.0
var steps_remaining = 3

func _ready():
	# decouple different instances of shader effect
	material = material.duplicate()
	material.set_shader_parameter("time", time)

func _process(delta):
	time += delta
	material.set_shader_parameter("time", time)
	
func step():
	if steps_remaining > 0:
		var test: Color
		$icon.modulate.a /= 2
		steps_remaining -= 1
	else:
		queue_free()
	
static func spawn(tree, pos, col, sprite: Texture2D = null):
	for i in range(3):
		var echo = echo_scene.instantiate()
		tree.current_scene.add_child(echo)
		
		echo.global_position = pos
		echo.material.set_shader_parameter("color", col)
		if sprite != null:
			echo.get_child(0).texture = sprite

		await tree.create_timer(0.25).timeout
