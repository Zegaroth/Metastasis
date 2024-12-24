extends Node

var hostButtonPressed = false
var players = {}
var index = 1

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

func host():
	print("Starting host!")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_delete_player)
	_add_player(1)

func join():
	print("Joining game!")
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	
func _add_player(id: int):
	print("Player %s joined the game!" % id)
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": "default",
			"id": id,
			"index": index
		}
		index += index
	#if multiplayer.is_server():
	#	for i in GameManager.players:
	#		sendPlayerInfo.rpc(GameManager.players[i].name, i)
func _delete_player(id: int):
	print("Player %s left the game!" % id)
	pass
