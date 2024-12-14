extends Control

signal found_server
signal server_removed

var broadcastTimer : Timer

var RoomInfo = {"name":"name", "playerCount": 0}

func _ready():
	broadcastTimer = $BroadcastTimer
	
func setUpBroadcast(name):
	RoomInfo.name = name

func _on_broadcast_timer_timeout() -> void:
	pass # Replace with function body.
