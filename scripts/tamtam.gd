extends Node2D
class_name Enemy

const MAX_HEALTH = 100
var CURRENT_HEALTH = MAX_HEALTH
const SPEED = 40
var DIRECTION = 1
var DAMAGE = 10

var player = null
var player_inside = null

@onready var ray_cast_left: RayCast2D = $Area2D/RayCastLeft
@onready var ray_cast_right: RayCast2D = $Area2D/RayCastRight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $AnimatedSprite2D/ProgressBar
@onready var timer: Timer = $TimerDamage
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	animated_sprite.flip_h = true
	health_bar.set_health(MAX_HEALTH)

func _process(delta: float) -> void:
	if CURRENT_HEALTH <= 0:
		queue_free()
	if player:
		move_toward_player(delta)
	else:
		patrol(delta)

func patrol(delta: float) -> void:
	if ray_cast_left.is_colliding():
		animated_sprite.flip_h = true
		DIRECTION = 1
	if ray_cast_right.is_colliding():
		animated_sprite.flip_h = false
		DIRECTION = -1
	position.x += delta * SPEED * DIRECTION

func move_toward_player(delta: float) -> void:
	if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
		patrol(delta)
	if player.global_position.x < global_position.x:
		DIRECTION = -1 
		animated_sprite.flip_h = false
	else:
		DIRECTION = 1
		animated_sprite.flip_h = true
	position.x += delta * SPEED * DIRECTION


func take_damage(damage):
	CURRENT_HEALTH -= damage
	health_bar.update_health(CURRENT_HEALTH)


func _on_agro_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body


func _on_agro_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and body.has_method("take_damage") and timer.is_stopped():
		body.take_damage(DAMAGE)
		player_inside = true
		timer.start()
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false

func _on_timer_timeout() -> void:
	if player_inside:
		if player and player.has_method("take_damage"):
			player.take_damage(DAMAGE)
	else:
		timer.stop()
