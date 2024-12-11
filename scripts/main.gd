extends Node2D

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

@export var playerscene: PackedScene 
@onready var main_node = $"."

func _ready():
	#print(MainMenu.hosting)
	if MainMenu.hosting:
		#main_node = get_tree().get_current_scene().get_node("Main")
		var server_peer = ENetMultiplayerPeer.new()
		server_peer.create_server(SERVER_PORT)
		multiplayer.multiplayer_peer = server_peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player()
	else:
		var client_peer = ENetMultiplayerPeer.new()
		client_peer.create_client(SERVER_IP, SERVER_PORT)

		multiplayer.multiplayer_peer = client_peer

func _add_player(id = 1):
	var player = playerscene.instantiate()
	player.player_id = id
	player.name = str(id)
	main_node.add_child(player, true)
	#call_deferred("add_child", player)

#func exit_game(id):
#	multiplayer.peer_disconnected.connect(delete_player)
#	delete_player(id)

#func delete_player(id):
#	rpc('_delete_player', id)
	
#@rpc("any_peer", "call_local")
#func _delete_player(id):
#	get_node(str(id)).queue_free()
