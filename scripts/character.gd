extends CharacterBody2D
class_name Character

var MAX_HEALTH = 100
var CURRENT_HEALTH = MAX_HEALTH

const SPEED = 5.0
const RATIO = 1_000
const RATIO_SQUARED = RATIO*RATIO
const AIR_CONTROL = 0.14
const JUMP_FORCE = 29.5
const AIR_DRAG_COEF = 0.42
const GROUND_RES_COEF = 0.25
const DASH_SPEED = 5

var Velocity : Vector2
var HoldingWall = false

func take_damage(damage : float):
	CURRENT_HEALTH -= damage
	
func take_knockback(kb : Vector2):
	Velocity.x = kb.x

func Move(direction:Vector2) -> void:
	
	if is_on_floor():
		Velocity += direction * SPEED * RATIO

	elif is_on_wall() && direction.is_equal_approx(-get_wall_normal()):
		HoldingWall = true
	else:
		var desired_air_control = direction * SPEED * RATIO * AIR_CONTROL
		if Velocity.length() + desired_air_control.length() < 20.0 * RATIO:
			Velocity += desired_air_control


func Jump() -> void:
	if is_on_floor():
		Velocity.y = -JUMP_FORCE * RATIO
	elif is_on_wall_only():
		Velocity = (get_wall_normal() + up_direction * 0.9).normalized() * JUMP_FORCE * RATIO
		
		
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
