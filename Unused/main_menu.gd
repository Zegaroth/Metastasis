extends Node2D

#var peer = ENetMultiplayerPeer.new()
#@export var playerscene: PackedScene 
const SERVER_PORT = 8910
const SERVER_IP = "127.0.0.1"

@export var tellHostToStartGame: bool
var hostHasStartedGame = false

var server_peer
var client_peer

func _ready():
	tellHostToStartGame = false
	multiplayer.peer_connected.connect(_peer_connected) #called on server plus clients
	multiplayer.peer_disconnected.connect(_disconnected_from_server)#called on server plus clients
	multiplayer.connected_to_server.connect(_connected_to_server)#called on clients only
	multiplayer.connection_failed.connect(_connected_failed)#called on clients only
	#used for non-player application as server
	if "--server" in OS.get_cmdline_args():
		hostgame()
	$ServerBrowser.joinGame.connect(JoinByIP)

func _peer_connected(id):#called on server and clients
	print("Player connected: " + str(id) + ":>")
	#$MainMenuSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
	#$".".set_multiplayer_authority(multiplayer.get_unique_id())
	#_setAuth.rpc()
func _disconnected_from_server(id):#called on server and clients
	print("Player disconnected: " + str(id) + ":>")
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
func _connected_to_server():#called on clients
	print("Connected to server!")
	sendPlayerInfo.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
func _connected_failed():#called on clients
	print("Could not connect to server!")

#@rpc("any_peer")
#func _setAuth():
#	$MainMenuSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
#	$".".set_multiplayer_authority(multiplayer.get_unique_id())

@rpc("any_peer")
func sendPlayerInfo(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id,
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			sendPlayerInfo.rpc(GameManager.players[i].name, i)
	
func hostgame():
	server_peer = ENetMultiplayerPeer.new()
	var error = server_peer.create_server(SERVER_PORT)
	if error != OK:
		print("Cannot host: " + str(error))
		return
	server_peer.get_host().compress(ENetConnection.COMPRESS_ZLIB)
	multiplayer.set_multiplayer_peer(server_peer)
	print("Waiting for players...")

@rpc("any_peer", "call_local")
func startGame():
	var scene = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_button_button_down() -> void:
	GameManager.hostButtonPressed = true
	hostgame()
	sendPlayerInfo($LineEdit.text, multiplayer.get_unique_id())
	$ServerBrowser.setUpBroadcast($LineEdit.text+"'s server")

func _on_join_button_button_down() -> void:
	JoinByIP(SERVER_IP)

func JoinByIP(ip):
	client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(ip, SERVER_PORT)
	client_peer.get_host().compress(ENetConnection.COMPRESS_ZLIB)
	multiplayer.set_multiplayer_peer(client_peer)

func _process(delta: float) -> void:
	#print(is_multiplayer_authority())
	#if(GameManager.hostButtonPressed):
	#	print("Host:"+str(tellHostToStartGame))
	#else:
	#	print("Peer:"+str(tellHostToStartGame))
	if tellHostToStartGame and !hostHasStartedGame:
		_on_start_game_button_button_down()
		hostHasStartedGame = true
		

func _on_start_game_button_button_down() -> void:
	if multiplayer.is_server():
		startGame.rpc()
	else:
		#tellHostToStartGame = true
		_setTellHostToStartGame.rpc()

@rpc("any_peer")
func _setTellHostToStartGame():
	tellHostToStartGame = true
