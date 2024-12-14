extends Node2D

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

@export var playerscene: PackedScene 
@onready var main_node = $"."

@onready var spawnIndex: int = 0

func _ready():
	#print(MainMenu.hosting)
	if MainMenu.hosting:
		#main_node = get_tree().get_current_scene().get_node("Main")
		var server_peer = ENetMultiplayerPeer.new()
		server_peer.create_server(SERVER_PORT)
		#server_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.multiplayer_peer = server_peer
		multiplayer.peer_connected.connect(_add_player) #called on server plus clients
		#multiplayer.peer_disconnected.connect(   )#called on server plus clients
		#multiplayer.connected_to_server.connect(   )#called on clients only
		#multiplayer.connection_failed.connect(   )#called on clients only
		_add_player()
	else:
		var client_peer = ENetMultiplayerPeer.new()
		client_peer.create_client(SERVER_IP, SERVER_PORT)
		#client_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.multiplayer_peer = client_peer

func _add_player(id = 1):
	var player = playerscene.instantiate()
	player.player_id = id
	player.name = str(id)
	main_node.add_child(player, true)
	#call_deferred("add_child", player)
	for spawnpoint in get_tree().get_nodes_in_group("spawnpoint"):
		if spawnpoint.name == str(spawnIndex):
			player.global_position = spawnpoint.global_position
	spawnIndex += 1

#func exit_game(id):
#	multiplayer.peer_disconnected.connect(delete_player)
#	delete_player(id)

#func delete_player(id):
#	rpc('_delete_player', id)
	
#@rpc("any_peer", "call_local")
#func _delete_player(id):
#	get_node(str(id)).queue_free()
