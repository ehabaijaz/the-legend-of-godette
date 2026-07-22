extends CharacterBody3D

# jump section
@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3
@onready var jump_velocity : float = ((2.0 * jump_height) /jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) /(jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) /(jump_time_to_descent * jump_time_to_descent)) * -1.0



@export var base_speed := 4.0
@onready var camera = $CameraController/Camera3D

var movement_input := Vector2.ZERO

func _physics_process(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "back").rotated(-camera.global_rotation.y)
	velocity = Vector3(movement_input.x, 0, movement_input.y) * base_speed
	jump_logic(delta)
	
	move_and_slide( )
 
func jump_logic(delta)->void:
	if Input.is_action_just_pressed('jump'):
		velocity.y = 40
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta
	
