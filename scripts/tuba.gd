extends Character

var State = CharacterStatus
var FacingDirection
var shock = preload("res://assets/fx/shockwave.tscn")
var speed = 120
@onready var SpriteSheet = $sprite

var markers = []
var current_marker_index = 0

func _ready():
	# Populate the markers array with marker positions
	markers = [
		$Marker3.global_position,
		$Marker1.global_position,
		$Marker2.global_position
	]
	# Optionally, move the character to the first marker initially
	global_position = markers[0]

func _physics_process(delta: float) -> void:
	if is_on_floor():
		State  = CharacterStatus.ONGROUND
	if current_marker_index < markers.size():
		# Get the target position
		var target = markers[current_marker_index]
		# Calculate direction to target
		var direction = (target - global_position).normalized()
		# Move towards the target
		if $shocktimer.is_stopped():
			velocity = direction * speed
			move_and_slide()

		# Check if we reached the target
		if global_position.distance_to(target) < 5:  # Tolerance for stopping
			current_marker_index = (current_marker_index+1)%3
		
	
		
func _process(_delta) -> void:
	if CURRENT_HEALTH <= 0:
		queue_free()
		
	match State:

		CharacterStatus.ATTACK:
			SpriteSheet.play("attack")
		CharacterStatus.ONGROUND,_:
			SpriteSheet.play("idle")
			
	if FacingDirection == CharacterDirection.LEFT:
		SpriteSheet.flip_h = true
	else:
		SpriteSheet.flip_h = false
	

func attack():
	$shocktimer.start()
	var shock_instance : AnimatedSprite2D = shock.instance()
	
	
	add_child(shock_instance)
	shock_instance.animation_finished.connect(
		func(): shock_instance.queue_free()
		)
	



enum CharacterStatus{
	ONGROUND,
	ATTACK
}

enum CharacterDirection{
	RIGHT,
	LEFT
}
