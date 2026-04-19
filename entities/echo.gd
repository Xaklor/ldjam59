extends Sprite2D

static var echo_scene = preload("res://entities/echo.tscn")
var time := 0.0

func _ready():
	# decouple different instances of shader effect
	material = material.duplicate()
	material.set_shader_parameter("time", time)

func _process(delta):
	time += delta
	material.set_shader_parameter("time", time)
	
static func spawn(tree, pos, col):
	for i in range(3):
		var echo = echo_scene.instantiate()
		tree.current_scene.add_child(echo)
		
		echo.global_position = pos
		echo.material.set_shader_parameter("color", col)

		await tree.create_timer(0.25).timeout
