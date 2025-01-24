extends CharacterBody2D


const SPEED = 3.0
const RATIO = 1_000
const RATIO_SQUARED = RATIO*RATIO
const AIR_CONTROL = 0.14
const JUMP_FORCE = 45
const AIR_DRAG_COEF = 0.95
const GROUND_RES_COEF = 0.25
const DASH_SPEED = 7

@onready var SpriteSheet : AnimatedSprite2D = $sprite
var slash = preload("res://assets/fx/slash.tscn")
var State : CharacterStatus
var FacingDirection : CharacterDirection
var Velocity : Vector2
var HoldingWall = false

var health : float

@onready var cooldown_timer = $dashCooldown 
var DashUnlocked = true

func damage(damage : float):
	health = health-damage

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
		Velocity += direction * SPEED * RATIO * AIR_CONTROL


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
<<<<<<< HEAD
	
=======
	if is_on_wall():
		Velocity.x = 0
		
>>>>>>> ab86b50581db35a3e4429d0ef273d0b3f554c02e
	if is_on_ceiling():
		Velocity.y=0
	
	if is_on_wall():
		Velocity.x = 0
	elif Velocity.y > 0:
		State = CharacterStatus.FALLING

func _process(_delta) -> void:
	if (is_on_floor()):
		State = CharacterStatus.ONGROUND
	var direction = Input.get_vector("left","right","up","down")
	Move(Vector2(direction.x,clampf(direction.y, 0, 1)))
	if Input.is_action_just_pressed("jump"):
		Jump()
	if Input.is_action_just_pressed("dash"):
		Dash(direction)
		
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
		var slash_instance : AnimatedSprite2D = slash.instantiate()
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
