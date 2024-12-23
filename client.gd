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
var id = 0
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var hostID : int
var lobbyValue = ""

func _ready():
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)

func RTCServerConnected():
	print("RTC Server Connected!")
func RTCPeerConnected(id):
	print("RTC Peer Connected: "+str(id))
func RTCPeerDisconnected(id):
	print("RTC Peer Disconnected: "+str(id))

func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_ascii()
			var data = JSON.parse_string(dataString)
			print(data)
			if data.message == Message.id:
				id = data.id
				connected(id)
				#print("My id is "+str(id))
			if data.message == Message.userConnected:
				#GameManager.players[data.id] = data.player
				createPeer(data.id)
			if data.message == Message.lobby:
				GameManager.players = JSON.parse_string(data.players)
				hostID = data.host
				lobbyValue = data.lobbyValue
			if data.message == Message.candidate:
				if rtcPeer.has_peer(data.orgPeer):
					print("Got Candidate: "+str(data.orgPeer)+ " my id is "+str(id))
					rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid, data.index, data.sdp)
			if data.message == Message.offer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
			if data.message == Message.answer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("answer", data.data)
					


func connected(id):
	rtcPeer.create_mesh(id)
	multiplayer.multiplayer_peer = rtcPeer
	
#webrtc connection stuff
func createPeer(id):
	if id != self.id:
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{ "urls" : ["stun:stun.l.google.com:19302"]}]
		})
		print("binding id "+str(id)+" my id is "+str(self.id))
		peer.session_description_created.connect(self.offerCreated.bind(id))
		peer.ice_candidate_created.connect(self.iceCandidateCreated.bind(id))
		rtcPeer.add_peer(peer, id)
		if !hostID == self.id:
			peer.create_offer()
	pass
func offerCreated(type, data, id):
	if !rtcPeer.has_peer(id):
		return
	rtcPeer.get_peer(id).connection.set_local_description(type, data)
	if type == "offer":
		sendOffer(id, data)
	else:
		sendAnswer(id, data)
func sendOffer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" : Message.offer,
		"data" : data,
		"Lobby" : lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_ascii_buffer())
func sendAnswer(id, data):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" : Message.answer,
		"data" : data,
		"Lobby" : lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_ascii_buffer())
func iceCandidateCreated(midName, indexName, sdpName, id):
	var message = {
		"peer" : id,
		"orgPeer" : self.id,
		"message" : Message.candidate,
		"mid" : midName,
		"index" : indexName,
		"sdp" : sdpName,
		"Lobby" : lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_ascii_buffer())
	
func connectToServer(ip):
	peer.create_client("ws://192.168.1.137:8915")
	print("Started client!")


func _on_start_client_button_down() -> void:
	connectToServer("")
	pass # Replace with function body.

func _on_send_test_packet_button_down() -> void:
	StartGame.rpc()
	pass # Replace with function body.
@rpc("any_peer", "call_local")
func StartGame():
	var message = {
		"message" : Message.removeLobby,
		"lobbyID" : lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_ascii_buffer())
	print("Starting game with ID: "+str(multiplayer.get_unique_id()))
	var scene = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	#self.hide()

func _on_join_lobby_button_down() -> void:
	var message = {
		"id": id,
		"message": Message.lobby,
		"name" : "",
		"lobbyValue": $LineEdit.text
	}
	peer.put_packet(JSON.stringify(message).to_ascii_buffer())
	pass # Replace with function body.
