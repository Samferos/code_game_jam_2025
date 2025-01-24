extends Area2D

@export var damage = 0

func do_damage(target : Node2D):
	target.damage(damage)
