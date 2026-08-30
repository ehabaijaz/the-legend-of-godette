extends CharacterBody3D

# jump section
@export var defend_speed := 2.0 
@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3
@onready var jump_velocity : float = ((2.0 * jump_height) /jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) /(jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) /(jump_time_to_descent * jump_time_to_descent)) * -1.0
var defend := false:
	set(value):
		if not defend and value:
			skin.defend(true)
		if defend and not value:
			skin.defend(false)
		defend = value
var speed_modifier := 1.0
var weapon_active := false
@onready var skin = $GodetteSkin

@export var base_speed := 4.0
@onready var camera = $CameraController/Camera3D
@export var run_speed := 12.0
var movement_input := Vector2.ZERO

func _physics_process(delta: float) -> void:
	move_logic(delta)
	jump_logic(delta)
	ability_logic()
	if Input.is_action_just_pressed('ui_accept'):
		hit()
	move_and_slide( )
 
func move_logic(delta) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "back").rotated(-camera.global_rotation.y)
	var vel2d = Vector2(velocity.x, velocity.z)
	var is_running : bool = Input.is_action_pressed('run')
	if movement_input != Vector2.ZERO: 
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		vel2d += movement_input * speed * delta
		vel2d = vel2d.limit_length(speed) * speed_modifier
		velocity.x = vel2d.x 
		velocity.z = vel2d.y
		skin.set_move_state("Running")
		var target_angle = -movement_input.angle() + PI/2
		skin.rotation.y = rotate_toward(skin.rotation.y ,target_angle, 6.0 * delta)
			
	else:
		vel2d = vel2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		velocity.x = vel2d.x
		velocity.z = vel2d.y
		skin.set_move_state('Idle')
	
func jump_logic(delta)->void:
	if is_on_floor():
		if Input.is_action_just_pressed('jump'):
			velocity.y = -jump_velocity
	else:
		skin.set_move_state('Jump')
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta
	
func ability_logic()-> void:
	 #attack
	if Input.is_action_just_pressed('ability'):
		if weapon_active:
			skin.attack()
		else:
			skin.cast_spell()
			stop_movement(0.3,0.8)
	#defend
	defend = Input.is_action_pressed('block')
	#magic
	if Input.is_action_just_pressed('switch weapon') and not skin.attacking:
		weapon_active = not weapon_active
		skin.switch_weapon(weapon_active)
	

func stop_movement(start_duration : float, end_duration : float):
	var tween=create_tween()
	tween.tween_property(self,'speed_modifier',0.0, start_duration)
	tween.tween_property(self,'speed_modifier',1.0, end_duration)
	
func hit():
	skin.hit()
	stop_movement(0.3,0.3)
