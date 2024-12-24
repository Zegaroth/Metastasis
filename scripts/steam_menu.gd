extends Node2D

@export var tellHostToStartGame: bool
var hostHasStartedGame = false

func _ready():
	tellHostToStartGame = false
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		GameManager.host()

func _on_host_pressed() -> void:
	GameManager.host()
	GameManager._add_player(1)
	$SteamMenu/Panel.hide()
	$SteamMenu/StartGame.show()

func _on_join_pressed() -> void:
	GameManager.join()
	$SteamMenu/Panel.hide()
	$SteamMenu/StartGame.show()
	

@rpc("any_peer", "call_local")
func startGame():
	var scene = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_start_game_pressed() -> void:
	if multiplayer.is_server():
		startGame.rpc()
	else:
		_setTellHostToStartGame.rpc()

func _process(delta: float) -> void:
	if tellHostToStartGame and !hostHasStartedGame:
		_on_start_game_pressed()
		hostHasStartedGame = true

@rpc("any_peer")
func _setTellHostToStartGame():
	tellHostToStartGame = true
