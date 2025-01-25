extends Character
class_name Enemy

var DIRECTION = 0.1
var DAMAGE = 10

var player : Player = null
var player_inside = null

@onready var ray_cast_left: RayCast2D = $Area2D/RayCastLeft
@onready var ray_cast_right: RayCast2D = $Area2D/RayCastRight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $AnimatedSprite2D/ProgressBar
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
	if player_inside:
		_on_area_2d_body_entered(player)

func patrol(delta: float) -> void:
	if ray_cast_left.is_colliding():
		animated_sprite.flip_h = true
		DIRECTION = 0.1
	if ray_cast_right.is_colliding():
		animated_sprite.flip_h = false
		DIRECTION = -0.1
	Move(Vector2(DIRECTION,0))

func move_toward_player(delta: float) -> void:
	if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
		patrol(delta)
	if player.global_position.x < global_position.x:
		DIRECTION = -0.1 
		animated_sprite.flip_h = false
	else:
		DIRECTION = 0.1
		animated_sprite.flip_h = true
	Move(Vector2(DIRECTION,0))


func take_damage(damage):
	super.take_damage(damage)
	health_bar.update_health(CURRENT_HEALTH)

func take_knockback(kb):
	super.take_knockback(kb)

func _on_agro_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body

func _on_agro_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
		body.take_knockback(position.move_toward(body.position, 1.0) * 2000 * DIRECTION)
		player_inside = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_inside = false

	
