extends Character

var DIRECTION = 0.1
var DAMAGE = 10

var player : Player = null
var player_inside = null
var item_scene := preload("res://scenes/item.tscn")
@onready  var main  =  get_node(".")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $AnimatedSprite2D/ProgressBar


func _ready() -> void:
	animated_sprite.flip_h = true
	health_bar.set_health(MAX_HEALTH)

func _process(delta: float) -> void:
	if CURRENT_HEALTH <= 0:
		drop_item()
		queue_free()
	patrol(delta)
	
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


func take_damage(damage):
	super.take_damage(damage)
	health_bar.update_health(CURRENT_HEALTH)

func take_knockback(kb):
	super.take_knockback(kb)
