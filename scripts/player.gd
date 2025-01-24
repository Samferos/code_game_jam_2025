extends CharacterBody2D


const SPEED = 5
const RATIO = 1_000
const RATIO_SQUARED = RATIO*RATIO
const AIR_CONTROL = 0.06
const JUMP_FORCE = 29.5
const AIR_DRAG_COEF = 0.35
const GROUND_RES_COEF = 0.25


var Velocity : Vector2
var HoldingWall = false


func Move(direction:Vector2) -> void:
	if is_on_floor():
		Velocity += direction * SPEED * RATIO
		$sprite.play("walk")
	elif is_on_wall() && direction.is_equal_approx(-get_wall_normal()):
		HoldingWall = true
	else:
		Velocity += direction * SPEED * RATIO * AIR_CONTROL

func Jump() -> void:
	if is_on_floor():
		Velocity.y = -JUMP_FORCE * RATIO
	elif is_on_wall():
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

	if is_on_wall():
		Velocity.x = 0

func _process(_delta) -> void:
	$sprite.play()
	var direction = Input.get_vector("left","right","up","down")
	Move(Vector2(direction.x,clampf(direction.y, 0, 1)))
	if Input.is_action_pressed("jump"):
		$sprite.play("jump")
		Jump()
	
