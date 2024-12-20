extends Node2D

@export var playerscene: PackedScene 
@onready var main: Node2D = $"."

func _ready():
	#if !multiplayer.is_server():
	#	return
	var index = 1
	for i in GameManager.players:
		print(GameManager.players[i])
		var currentPlayer =  playerscene.instantiate()
		currentPlayer.player_id = GameManager.players[i].id
		currentPlayer.name = str(GameManager.players[i].id)# + str(Time.get_ticks_msec())  # Unique name based on time
		main.add_child(currentPlayer)
		for spawnpoint in get_tree().get_nodes_in_group("spawnpoint"):
			if spawnpoint.name == str(GameManager.players[i].index):
				currentPlayer.foundSpawn = true
				currentPlayer.global_position = spawnpoint.global_position
		if currentPlayer.foundSpawn == false:
			currentPlayer.global_position = $SpawnLocations/DefaultSpawn.global_position
		index += 1
			
