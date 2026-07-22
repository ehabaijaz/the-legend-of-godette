extends Node3D

func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * 0.005)

		
func rotate_from_vector(v: Vector2):
	if v.length() == 0: return
	rotation.y += v.x
	rotation.x -= v.y
	rotation.x = clamp(rotation.x, -0.1, 0.1)
	
