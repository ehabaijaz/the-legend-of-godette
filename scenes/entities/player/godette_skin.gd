extends Node3D
var attacking := false

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_state_machine = $AnimationTree.get("parameters/AttackStateMachine/playback")
@onready var extra_animation = $AnimationTree.get_tree_root().get_node('ExtraAnimation')
var squash_and_stretch := 1.0:
	set(value):
		squash_and_stretch = value
		scale = Vector3(1,squash_and_stretch,1)


func set_move_state(state_name : String)-> void:
	move_state_machine.travel(state_name)

func attack() -> void:
	if not attacking:
		attack_state_machine.travel('Slice' if $SecondAttackTimer.time_left else 'Chop')
		$AnimationTree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func attack_toggle(value: bool):
	attacking = value


func defend(forward: bool)-> void:
	var tween = create_tween()
	tween.tween_method(_defend_change, 1.0 - float(forward), float(forward), 0.25)
	
func _defend_change(value : float)-> void:
	$AnimationTree.set("parameters/ShieldBlend/blend_amount", value)

func switch_weapon(weapon_active: bool)-> void:
	if weapon_active:
		$Rig/Skeleton3D/RightHandSlot/sword_1handed2/sword_1handed.show()
		$Rig/Skeleton3D/RightHandSlot/wand2.hide()
	else:
		$Rig/Skeleton3D/RightHandSlot/sword_1handed2/sword_1handed.hide()
		$Rig/Skeleton3D/RightHandSlot/wand2.show()
		
func cast_spell()-> void:
	if not attacking:
		extra_animation.animation = 'Spellcast_Shoot'
		$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func hit()-> void:
	extra_animation.animation = 'Hit_A'
	$AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	$AnimationTree.set('parameters/AttackOneShot/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	attacking = false
