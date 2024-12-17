extends Control

signal found_server(ip,port,roomInfo)
signal update_server(ip,port,roomInfo)
signal server_removed
signal joinGame(ip)
var broadcastTimer : Timer

var RoomInfo = {"name":"name", "playerCount": 0}
var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP
@export var listenPort : int = 8911
@export var broadcastPort : int = 8912
@export var broadcastAddress : String = '192.168.1.255'

@export var serverInfo : PackedScene

func _ready():
	broadcastTimer = $BroadcastTimer
	setup()
	
func setup():
	listener = PacketPeerUDP.new()
	var ok = listener.bind(listenPort)
	if ok == OK:
		print("Bound to listen port: "+str(listenPort)+" Successful!")
		$Label2.text = "Bound to listen port: True"
	else:
		print("Failed to bind to listen port!")
		$Label2.text = "Bound to listen port: False"
	
func setUpBroadcast(name):
	RoomInfo.name = name
	RoomInfo.playerCount = GameManager.players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)
	
	var ok = broadcaster.bind(broadcastPort)
	if ok == OK:
		print("Bound to broadcast port: "+str(broadcastPort)+" Successful!")
	else:
		print("Failed to bind to broadcast port!")
		
	broadcastTimer.start()

func _process(delta):
	if listener.get_available_packet_count() > 0:
		var serverip = listener.get_packet_ip()
		var serverport = listener.get_packet_port()
		var bytes = listener.get_packet()
		var data = bytes.get_string_from_ascii()
		var roomInfo = JSON.parse_string(data)
		print("ServerIP:"+serverip+"ServerPort:"+str(serverport)+"RoomInfo:"+str(roomInfo))
		
		for i in $Panel/VBoxContainer.get_children():
			if i.name == roomInfo.name:
				update_server.emit(serverip,serverport,roomInfo)
				i.get_node("IP").text = serverip
				i.get_node("PlayerCount").text = str(roomInfo.playerCount)
				return
				
		var currentInfo = serverInfo.instantiate()
		currentInfo.name = roomInfo.name
		currentInfo.get_node("Name").text = roomInfo.name
		currentInfo.get_node("IP").text = serverip
		currentInfo.get_node("PlayerCount").text = str(roomInfo.playerCount)
		$Panel/VBoxContainer.add_child(currentInfo)
		currentInfo.joinGame.connect(joinbyIP)
		found_server.emit(serverip,serverport,roomInfo)

func _on_broadcast_timer_timeout() -> void:
	print("Broadcasting Game!")
	RoomInfo.playerCount = GameManager.players.size()
	var data = JSON.stringify(RoomInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)
	
func cleanup():
	listener.close()
	broadcastTimer.stop()
	if broadcaster != null:
		broadcaster.close()
		
func _exit_tree() -> void:
	cleanup()

func joinbyIP(ip):
	joinGame.emit(ip)
