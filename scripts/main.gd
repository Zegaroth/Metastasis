extends Node2D

@export var playerscene: PackedScene 
@onready var main: Node2D = $"."

func _ready():
	if !multiplayer.is_server():
		return
	var index = 0
	for i in GameManager.players:
		print(index)
		var currentPlayer =  playerscene.instantiate()
		currentPlayer.player_id = GameManager.players[i].id
		currentPlayer.name = str(GameManager.players[i].id) 
		main.add_child(currentPlayer)
		for spawnpoint in get_tree().get_nodes_in_group("spawnpoint"):
			if spawnpoint.name == str(index):
				currentPlayer.foundSpawn = true
				currentPlayer.global_position = spawnpoint.global_position
		if currentPlayer.foundSpawn == false:
			currentPlayer.global_position = $SpawnLocations/DefaultSpawn.global_position
		index += 1
			
