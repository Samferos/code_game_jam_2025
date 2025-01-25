extends Character




func _physics_process(delta: float) -> void:
	if is_on_floor():
		CharacterStatus = 
	
	



enum CharacterStatus{
	ONGROUND,
	ATTACK
}

enum CharacterDirection{
	RIGHT,
	LEFT
}
