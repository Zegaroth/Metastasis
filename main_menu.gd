extends Node2D

#var peer = ENetMultiplayerPeer.new()
#@export var playerscene: PackedScene 

var hosting = false

func _on_single_player_button_pressed() -> void:
	pass
	#get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_host_button_pressed() -> void:
	MainMenu.hosting = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	#var nextlevel = load("res://scenes/main.tscn").instance()
	

func _on_join_button_pressed() -> void:
	MainMenu.hosting = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	#var nextlevel = load("res://scenes/main.tscn").instance()
	
