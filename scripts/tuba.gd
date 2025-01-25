extends Character

var State = CharacterStatus
var FacingDirection
var shock = preload("res://assets/fx/shockwave.tscn")
@onready var SpriteSheet = $sprite



func _physics_process(delta: float) -> void:
	if is_on_floor():
		State  = CharacterStatus.ONGROUND
	
		
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
