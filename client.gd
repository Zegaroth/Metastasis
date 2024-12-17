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
	checkIn
}

var peer = WebSocketMultiplayerPeer.new()
var id = 0

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
				print("My id is "+str(id))
			if data.message == Message.userConnected:
				#GameManager.players[data.id] = data.player
				createPeer(data.id)
			if data.message == Message.lobby:
				GameManager.players = JSON.parse_string(data.players)
	pass

#webrtc connection stuff
func createPeer(id):
	pass

func connectToServer(ip):
	peer.create_client("ws://127.0.0.1:8915")
	print("Started client!")


func _on_start_client_button_down() -> void:
	connectToServer("")
	pass # Replace with function body.


func _on_send_test_packet_button_down() -> void:
	var message = {
		"message": Message.join,
		"data": "test"
	}
	var messageBytes = JSON.stringify(message).to_ascii_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.


func _on_join_lobby_button_down() -> void:
	var message = {
		"id": id,
		"message": Message.lobby,
		"name" : "",
		"lobbyValue": $LineEdit.text
	}
	peer.put_packet(JSON.stringify(message).to_ascii_buffer())
	pass # Replace with function body.
