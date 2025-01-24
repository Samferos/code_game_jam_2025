extends CharacterBody2D
class_name Player

const MAX_HEALTH = 100
var CURRENT_HEALTH = MAX_HEALTH

const SPEED = 5.0
const RATIO = 1_000
const RATIO_SQUARED = RATIO*RATIO
const AIR_CONTROL = 0.14
const JUMP_FORCE = 29.5
const AIR_DRAG_COEF = 0.42
const GROUND_RES_COEF = 0.25
const DASH_SPEED = 5

@onready var SpriteSheet : AnimatedSprite2D = $sprite
var slash = preload("res://assets/fx/slash.tscn")
var State : CharacterStatus
var FacingDirection : CharacterDirection
var Velocity : Vector2
var HoldingWall = false

@onready var health_bar: ProgressBar = $HUD/healthbar
@onready var cooldown_timer = $dashCooldown 
var DashUnlocked = true

func _ready() -> void:
	health_bar.set_health(MAX_HEALTH)
	health_bar.visible = true
	
func _on_health_depleted():
	collision_layer = 0
	collision_mask = 0
	
func take_damage(damage : float):
	CURRENT_HEALTH -= damage
	print(CURRENT_HEALTH)
	health_bar.update_health(CURRENT_HEALTH)

func Move(direction:Vector2) -> void:
	
	if is_on_floor():
		Velocity += direction * SPEED * RATIO
		if direction.x > 0:
			FacingDirection = CharacterDirection.RIGHT
			State = CharacterStatus.WALKING
		if direction.x<0:
			FacingDirection = CharacterDirection.LEFT
			State = CharacterStatus.WALKING
	elif is_on_wall() && direction.is_equal_approx(-get_wall_normal()):
		if direction.x > 0:
			FacingDirection = CharacterDirection.LEFT
		else:
			FacingDirection = CharacterDirection.RIGHT
		State = CharacterStatus.SLIDING
		HoldingWall = true
	else:
		var desired_air_control = direction * SPEED * RATIO * AIR_CONTROL
		if Velocity.length() + desired_air_control.length() < 20.0 * RATIO:
			Velocity += desired_air_control


func Jump() -> void:
	if is_on_floor():
		State = CharacterStatus.JUMPING
		Velocity.y = -JUMP_FORCE * RATIO
	elif is_on_wall_only():
		Velocity = (get_wall_normal() + up_direction * 0.9).normalized() * JUMP_FORCE * RATIO
		if get_wall_normal().x < 0:
			FacingDirection = CharacterDirection.LEFT
		else:
			FacingDirection = CharacterDirection.RIGHT
		
func Dash(direction : Vector2) -> void:
	if cooldown_timer.is_stopped() and DashUnlocked:
		cooldown_timer.start()
		Velocity = direction * SPEED * RATIO * DASH_SPEED


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		Velocity += get_gravity() 
		var dragForce : Vector2
		if not HoldingWall:
			var fluidRelativeVelocity : float = Velocity.length_squared() / RATIO_SQUARED
			dragForce = Velocity.normalized() * 0.5 * AIR_DRAG_COEF * fluidRelativeVelocity
		else:
			dragForce = Velocity * GROUND_RES_COEF * 2.0;
			HoldingWall = false;
			
		Velocity -= dragForce
	else:
		var resistance : Vector2 = Velocity * GROUND_RES_COEF
		Velocity -= resistance
	velocity = Velocity * delta
	move_and_slide()

	if is_on_ceiling():
		Velocity.y=0


	if is_on_wall():
		Velocity.x = 0
	elif Velocity.y > 0:
		State = CharacterStatus.FALLING

func _process(_delta) -> void:
	if (is_on_floor()):
		State = CharacterStatus.ONGROUND
	var direction = Vector2(int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")), int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")))
	Move(Vector2(direction.x,clampf(direction.y, 0, 1)))
	if Input.is_action_just_pressed("jump"):
		Jump()
	if Input.is_action_just_pressed("dash"):
		Dash(direction)
	if CURRENT_HEALTH <= 0:
		_on_health_depleted()
	health_bar.visible = true
	
		
	match State:
		CharacterStatus.FALLING:
			if SpriteSheet.animation!="fall":
				if not SpriteSheet.is_playing():
					SpriteSheet.play("fall")
				else:
					SpriteSheet.play("start_fall")
		CharacterStatus.JUMPING:
			SpriteSheet.play("jump")
		CharacterStatus.WALKING:
			SpriteSheet.play("walk")
		CharacterStatus.SLIDING:
			SpriteSheet.play("slide")
		CharacterStatus.ONGROUND,_:
			SpriteSheet.play("idle")
			
	if FacingDirection == CharacterDirection.LEFT:
		SpriteSheet.flip_h = true
	else:
		SpriteSheet.flip_h = false
	
	if Input.is_action_just_pressed("slash"):
		if $slashCooldown.is_stopped():
			attack()
			
	health_bar.visible = true


func attack():
	$slashCooldown.start()
	var slash_instance : AnimatedSprite2D = slash.instantiate()
	if FacingDirection == CharacterDirection.RIGHT:
		slash_instance.flip_h = false
		slash_instance.translate(Vector2(15,0))
	else:
		slash_instance.flip_h = true
		slash_instance.translate(Vector2(-15,0))
	add_child(slash_instance)
	slash_instance.animation_finished.connect(
		func(): slash_instance.queue_free()
		)


enum CharacterStatus{
	ONGROUND,
	WALKING,
	JUMPING,
	FALLING,
	ONWALL,
	SLIDING
}

enum CharacterDirection{
	RIGHT,
	LEFT
}
