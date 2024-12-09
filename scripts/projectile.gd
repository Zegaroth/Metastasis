extends Area2D

class_name Projectile
@export var projectile_owner: Node2D
var speed = 1000
@export var move_direction: Vector2 = Vector2.ZERO
@export var damage: int 

#@rpc("any_peer", "call_local", "reliable")
func set_projectile_owner(myOwner: Node2D) -> void:
	projectile_owner = myOwner

func _process(delta):
	global_position += move_direction * delta * speed
	
	
#@rpc("any_peer", "call_local", "reliable")
#@rpc("any_peer")
func _on_body_entered(body: Node2D) -> void:
	if projectile_owner == body:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		#rpc('shoot')
		
	if is_multiplayer_authority():
		queue_free()



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if  is_multiplayer_authority():
		queue_free()
