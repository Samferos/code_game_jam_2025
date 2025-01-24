extends Node2D

signal switchToggled
signal toggledOn
signal toggledOff

@onready var onState = $On
@onready var offState = $Off

var isOn: bool = false

func _ready():
	setStates()

func setStates():
	onState.visible = isOn
	offState.visible = !isOn

func switchToggle():
	isOn = !isOn
	setStates()
	switchToggled.emit()
	if isOn:
		toggledOn.emit()
	else:
		toggledOff.emit()