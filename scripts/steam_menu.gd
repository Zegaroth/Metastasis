extends Node2D

func _on_host_pressed() -> void:
	GameManager.host()
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
	startGame.rpc()
