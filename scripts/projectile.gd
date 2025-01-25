extends Area2D

var velocity: Vector2

func _enter_tree() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()

func _physics_process(delta):
	translate(velocity * delta)
