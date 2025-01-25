extends Character

class_name Player

@onready var SpriteSheet : AnimatedSprite2D = $sprite
var slash = preload("res://assets/fx/slash.tscn")
var State : CharacterStatus
var FacingDirection : CharacterDirection


@onready var health_bar: ProgressBar = $HUD/healthbar
@onready var cooldown_timer = $dashCooldown 
@onready var invisibility_cooldown: Timer = $invisibilityCooldown

var DashUnlocked = true

func _ready() -> void:
	health_bar.set_health(MAX_HEALTH)
	health_bar.visible = true
	
func _on_health_depleted():
	queue_free()
	get_tree().change_scene_to_file("res://scenes/MainMenu/main_menu.tscn")  # Load the main menu	
	

func take_damage(damage):
	if invisibility_cooldown.is_stopped():
		super.take_damage(damage)
		health_bar.update_health(CURRENT_HEALTH)
		
		
func take_knockback(kb):
	if invisibility_cooldown.is_stopped():
		super.take_knockback(kb)
		invisibility_cooldown.start()
func _physics_process(delta: float) -> void:
	
	var direction = Vector2(int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")), int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up")))
	Move(Vector2(direction.x,clampf(direction.y,0,1)))
	if Velocity.y > 0:
		State = CharacterStatus.FALLING
	
	if is_on_floor():
		State = CharacterStatus.ONGROUND
	if is_on_floor_only():
		if not is_zero_approx(direction.x):
			State = CharacterStatus.WALKING
			if direction.x > 0:
				FacingDirection = CharacterDirection.RIGHT
			elif direction.x < 0:
				FacingDirection = CharacterDirection.LEFT
	
	if Input.is_action_just_pressed("jump"):
		Jump()
		State = CharacterStatus.JUMPING
		
	if is_on_wall_only():
		State = CharacterStatus.SLIDING
		if get_wall_normal().x < 0:
			FacingDirection = CharacterDirection.LEFT
		else:
			FacingDirection = CharacterDirection.RIGHT

	if Input.is_action_just_pressed("dash"):
		Dash(direction.normalized())
	
	if Input.is_action_just_pressed("slash"):
		if $slashCooldown.is_stopped():
			attack()
			
	super._physics_process(delta)


func _process(_delta) -> void:
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
	

func Dash(direction : Vector2) -> void:
	if cooldown_timer.is_stopped() and DashUnlocked:
		cooldown_timer.start()
		Velocity = direction * SPEED * RATIO * DASH_SPEED
	
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

func _on_invisibility_cooldown_timeout() -> void:
	invisibility_cooldown.stop()

	


func _on_static_body_2d_5_body_exited(body: Node2D) -> void:
	if body is Player:
		print("player exited")
		_on_health_depleted()
