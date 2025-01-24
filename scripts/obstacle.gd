extends Node2D

## Sent when the obstacle starts opening
signal opening
## Sent when the obstacle has finished opening
signal opened

## Sent when the obstacle starts opening
signal closing
## Sent when the obstacle has finished opening
signal closed

@onready var initial_position: Vector2 = position

func open() -> void:
	opening.emit()

	var points = $Path.curve.get_baked_points()
	for point in points:
		position = point + initial_position
		await get_tree().create_timer(0.03).timeout

	opened.emit()

func close() -> void:
	closing.emit()

	var points = $Path.curve.get_baked_points()
	points.reverse()
	for point in points:
		position = point + initial_position
		await get_tree().create_timer(0.03).timeout

	closed.emit()
