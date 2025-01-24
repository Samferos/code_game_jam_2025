class_name OptionsMenu
extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/Exit_Button2 as Button
@export var main_menu= preload("res://scenes/MainMenu/main_menu.tscn")
@onready var hslider = $MarginContainer/VBoxContainer/VBoxContainer/HSlider as HSlider

func _ready() : 
	hslider.value = db_to_linear(AudioServer.get_bus_volume_db(0))

	exit_button.pressed.connect(_on_exit_button_2_pressed)
	hslider.value_changed.connect(on_slider_value_changed)
	

func on_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_exit_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu)
