class_name MainMenu
extends Control



@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var options_button  = $MarginContainer/HBoxContainer/VBoxContainer/Options_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button

@onready var margin_container = $MarginContainer as MarginContainer

@export var start_level= preload("res://scenes/level1.tscn")
@export var main_menu= preload("res://scenes/MainMenu/main_menu.tscn")

@export var option_menu= preload("res://scenes/MainMenu/options_menu.tscn")

func _ready() : 
	handle_connecting_signals()
	
func on_start_down() -> void: 
	get_tree().change_scene_to_packed(start_level)
	
func on_exit_pressed() -> void : 
	get_tree().quit()
	
func on_options_pressed() -> void : 
	get_tree().change_scene_to_packed(option_menu)

	
	
func on_exit_options_menu() -> void : 
	get_tree().change_scene_to_packed(main_menu)

	
func handle_connecting_signals() -> void : 
	exit_button.button_down.connect(on_exit_pressed )
	start_button.button_down.connect(on_start_down)
	options_button.button_down.connect(on_options_pressed)

	
