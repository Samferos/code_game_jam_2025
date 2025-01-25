extends Character

var DIRECTION = 0.1
var DAMAGE = 50

var player : Player = null
var player_inside = null
var item_scene := preload("res://scenes/item.tscn")
var waveshock := preload("res://assets/fx/shockwave.tscn")
@onready  var main  =  get_node(".")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $AnimatedSprite2D/ProgressBar
@onready var area_2d: Area2D = $Area2D
var State : EntityStatus
@onready var attack_timer: Timer = $AttackTimer



func _ready() -> void:
	animated_sprite.flip_h = true
	health_bar.set_health(MAX_HEALTH)
	State = EntityStatus.WALK


func _process(delta: float) -> void:
	if CURRENT_HEALTH <= 0:
		drop_item()
		queue_free()
	if player_inside:
		_on_area_2d_body_entered(player)
	match State:
		EntityStatus.WALK:
			animated_sprite.play("walk")
			if player:
				move_toward_player(delta)
			else:
				patrol(delta)
		EntityStatus.ATTACK:
			animated_sprite.play("attack")
			if attack_timer.is_stopped():
				attack_timer.start()
	
func drop_item():
	var item = item_scene.instantiate()
	item.position = position
	item.item_type = 1
	main.get_parent().add_child(item)
	print(main.get_parent().get_tree_string_pretty())
	item.add_to_group("item")
	

func patrol(delta: float) -> void:
	if is_on_wall():
		animated_sprite.flip_h = !animated_sprite.flip_h
		DIRECTION *= -1
	Move(Vector2(DIRECTION,0))

func move_toward_player(delta: float) -> void:
	if is_on_wall():
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
		State = EntityStatus.ATTACK
		player_inside = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		State = EntityStatus.WALK
		player_inside = false
		attack_timer.stop()

enum EntityStatus{
	WALK,
	ATTACK
}
	

func _on_attack_timer_timeout() -> void:
	if player:
		var wave_instance = waveshock.instantiate()
		wave_instance.velocity = (player.position - position).normalized() * 350
		wave_instance.position = position	
		get_tree().root.add_child(wave_instance)
		player.take_damage(DAMAGE)
		player.take_knockback(position.move_toward(player.position, 1.0) * 1000 * DIRECTION)
	if !player_inside:
		State =  EntityStatus.WALK
