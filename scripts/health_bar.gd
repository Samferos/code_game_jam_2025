extends ProgressBar

var MAX_HEALTH = 100
var CURRENT_HEALTH = MAX_HEALTH
@onready var timer: Timer = $FadeTimer

func _ready() -> void:
	visible = false
	value = MAX_HEALTH
	update_color()

func set_health(entity_max_health : int):
	MAX_HEALTH = entity_max_health
	CURRENT_HEALTH = MAX_HEALTH
	value = CURRENT_HEALTH

func update_health(new_health):
	CURRENT_HEALTH = new_health
	update_color()
	if CURRENT_HEALTH < 0:
		CURRENT_HEALTH = 0
		print("Entity died!")
	visible = true
	timer.start()
	value = CURRENT_HEALTH
		

func update_color():
	var health_percentage = float(CURRENT_HEALTH) / float(MAX_HEALTH)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1.0 - health_percentage, health_percentage, 0)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	add_theme_stylebox_override("fill", sb)
	
	
func _on_timer_timeout() -> void:
	visible = false
	timer.stop()
