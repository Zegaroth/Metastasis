extends Node

enum Message{
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	removeLobby,
	checkIn
}

var peer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}

var Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
@export var hostPort = 8915

func _ready():
	if "--server" in OS.get_cmdline_args():
		print("Hosting on: "+str(hostPort))
		peer.create_server(hostPort)
	peer.connect("peer_connected", peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)

func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_ascii()
			var data = JSON.parse_string(dataString)
			print(data)
			
			if data.message == Message.lobby:
				JoinLobby(data)
			
			if data.message == Message.offer || data.message == Message.answer || data.message == Message.candidate:
				print("source id is: "+str(data.orgPeer))
				sendToPlayer(data.peer, data)
			if data.message == Message.removeLobby:
				if lobbies.has(data.lobbyID):
					lobbies.erase(data.lobbyID)

func peer_connected(id):
	print("Peer connected: "+str(id))
	users[id] = {
		"id": id,
		"message": Message.id
	}
	var messageBytes = JSON.stringify(users[id]).to_ascii_buffer()
	peer.get_peer(id).put_packet(messageBytes)
	pass
func peer_disconnected(id):
	#users.erase(id)
	pass

func JoinLobby(user):
	if user.lobbyValue=="":
		user.lobbyValue = generateRandomString()
		lobbies[user.lobbyValue] = Lobby.new(user.id)
		print("lobby value: " + str(user.lobbyValue))
		$"../Client/LineEdit".text = user.lobbyValue
	var player = lobbies[user.lobbyValue].AddPlayer(user.id, user.name)
	
	for p in lobbies[user.lobbyValue].Players:
		
		var data = {
			"message": Message.userConnected,
			"id": user.id
		}
		sendToPlayer(p, data)
		var data2 = {
			"message": Message.userConnected,
			"id": p
		}
		sendToPlayer(user.id, data2)
		
		var lobbyInfo = {
			"message" : Message.lobby,
			"players" : JSON.stringify(lobbies[user.lobbyValue].Players),
			"host": lobbies[user.lobbyValue].HostID,
			"lobbyValue": user.lobbyValue
		}
		sendToPlayer(p, lobbyInfo)
		
	
	var data = {
		"message": Message.userConnected,
		"id": user.id,
		"host": lobbies[user.lobbyValue].HostID,
		"players": lobbies[user.lobbyValue].Players[user.id],
		"lobbyValue": user.lobbyValue
	}
	sendToPlayer(user.id, data)

func sendToPlayer(userid, data):
	var messageBytes = JSON.stringify(data).to_ascii_buffer()
	peer.get_peer(userid).put_packet(messageBytes)

func generateRandomString():
	var result = ""
	for i in range(32):
		var index = randi() % Characters.length()
		result += Characters[index]
		#print(result)
	return result

func startServer():
	peer.create_server(hostPort)
	print("Started server on port: + "+str(hostPort))

func _on_start_server_button_down() -> void:
	startServer()
	pass # Replace with function body.

func _on_send_server_test_packet_button_down() -> void:
	var message = {
		"message": Message.id,
		"data": "test"
	}
	var messageBytes = JSON.stringify(message).to_ascii_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.
