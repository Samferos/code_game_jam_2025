extends Node2D

const MAX_HEALTH = 100
var CURRENT_HEALTH = MAX_HEALTH
const SPEED = 40
var DIRECTION = 1

@onready var ray_cast_left: RayCast2D = $Area2D/RayCastLeft
@onready var ray_cast_right: RayCast2D = $Area2D/RayCastRight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $AnimatedSprite2D/ProgressBar

func _ready() -> void:
	animated_sprite.flip_h = true
	health_bar.set_health(MAX_HEALTH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_left.is_colliding():
		animated_sprite.flip_h = true
		DIRECTION = 1
	if ray_cast_right.is_colliding():
		animated_sprite.flip_h = false
		DIRECTION = -1
	position.x += delta * SPEED * DIRECTION

func take_damage(damage):
	CURRENT_HEALTH -= damage
	health_bar.update_health(CURRENT_HEALTH)
