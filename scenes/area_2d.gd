extends Area2D

@export var boss: Node2D

func _on_body_entered(body: Node2D) -> void:
	print("a")
	boss.process_mode = Node.PROCESS_MODE_INHERIT
