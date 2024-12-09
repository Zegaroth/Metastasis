extends Area2D

@onready var destination: Node2D = $Destination

func _on_body_entered(body: Node2D) -> void:
	print_debug("body entered")
	body.global_position = destination.global_position
