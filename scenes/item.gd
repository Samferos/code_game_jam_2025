extends Area2D

var item_type  : int 

var coffee = preload("res://assets/sprites/coffee_mug.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = coffee


func _on_body_entered(body: Node2D) -> void:
	print("Coffee")
	queue_free()

#func _on_tamtam_hidden() -> void:
	
