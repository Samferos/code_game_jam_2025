extends Character

var State = CharacterStatus
var FacingDirection
var shock = preload("res://assets/fx/shockwave.tscn")
var speed = 120
@onready var SpriteSheet = $sprite

## The spots where the tubaman will jump to.
@export var JumpSpots: Array

## The target
@onready var target: Node2D = %player

var timer = Timer.new()
var current_activity = activities.values().pick_random()
var jump_point

var attack_cd = Timer.new()

enum activities {
	CHASING,
	SHOOTING,
	JUMPING
}

func take_damage(dmg):
	$hurtSound.play()
	super.take_damage(dmg)
	modulate = Color.RED
	await get_tree().create_timer(0.3).timeout
	modulate = Color.WHITE

func _enter_tree() -> void:
	timer.wait_time = (randi() % 3) + 2
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(
		func():
			current_activity = activities.values().pick_random()
			if (current_activity == activities.JUMPING):
				jump_point = get_node(JumpSpots.pick_random())
	)
	attack_cd.wait_time = 1
	attack_cd.autostart = false
	attack_cd.one_shot = true
	add_child(attack_cd)

func _physics_process(delta: float) -> void:
	match current_activity:
		activities.CHASING:
			Move((target.position - position).normalized())
		activities.JUMPING:
			$jumpSound.play()
			Jump()
			if jump_point:
				Move((jump_point.position - position).normalized())
		activities.SHOOTING:
			if (attack_cd.is_stopped()):
				var shockwave_instance = shock.instantiate()
				shockwave_instance.velocity = (target.position - position).normalized() * 98
				shockwave_instance.position = position
				get_tree().root.add_child(shockwave_instance)
				attack_cd.start()
		_:
			pass
	super._physics_process(delta)
	
func _process(_delta) -> void:
	if CURRENT_HEALTH <= 0:
		died.emit()
		$deathSound.play()
		queue_free()

	if current_activity == activities.SHOOTING:
		State = CharacterStatus.ATTACK
	elif is_on_floor():
		State = CharacterStatus.ONGROUND
			
	if FacingDirection == CharacterDirection.LEFT:
		SpriteSheet.flip_h = true
	else:
		SpriteSheet.flip_h = false

	match State:

		CharacterStatus.ATTACK:
			SpriteSheet.play("attack")
		CharacterStatus.ONGROUND, _:
			SpriteSheet.play("idle")

	
func attack():
	$shocktimer.start()
	var shock_instance: AnimatedSprite2D = shock.instance()
	
	
	add_child(shock_instance)
	shock_instance.animation_finished.connect(
		func(): shock_instance.queue_free()
		)
	

enum CharacterStatus {
	ONGROUND,
	ATTACK
}

enum CharacterDirection {
	RIGHT,
	LEFT
}
