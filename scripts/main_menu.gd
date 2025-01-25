class_name MainMenu
extends Control


@onready var animation: AnimationPlayer = $AnimationPlayer

@export var start_level = preload("res://scenes/level1.tscn")
@export var main_menu = preload("res://scenes/MainMenu/main_menu.tscn")
@export var option_menu = preload("res://scenes/MainMenu/options_menu.tscn")
	
func on_start_down() -> void:
	animation.play("intro")
	await animation.animation_finished
	get_tree().change_scene_to_packed(start_level)
	
func on_exit_pressed() -> void:
	get_tree().quit()
	
func on_options_pressed() -> void:
	get_tree().change_scene_to_packed(option_menu)

	
func on_exit_options_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu/main_menu.tscn")
