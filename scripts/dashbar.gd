extends ProgressBar

@onready var dashTimer = $"../../dashCooldown"

func _process(delta: float) -> void:
	max_value = dashTimer.wait_time
	value = max_value - dashTimer.time_left 
