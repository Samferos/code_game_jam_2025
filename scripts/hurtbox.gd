extends Area2D

@export var damage = 25

func do_damage(target: Node2D):
	if is_in_group("player"):
		if target.is_in_group("enemy"):
			target.take_damage(damage)
			if target is Enemy:
				target.take_knockback(Vector2(target.DIRECTION * 10 * -50000, 0))
