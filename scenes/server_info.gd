extends HBoxContainer

signal joinGame(ip)

func _on_button_button_down() -> void:
	joinGame.emit($IP.text)
	pass # Replace with function body.
