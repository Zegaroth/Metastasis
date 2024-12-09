extends State

@onready var idle_timer = $IdleTimer as RandomTimer
@onready var rot_timer = $RotationTimer as RandomTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"


var rot_speed: float
var is_rotating = false
var rot_degrees = 0
var allow_rotation = true

func enter(msg = {}) -> void:
	(owner as AI).velocity = Vector2.ZERO
	rot_speed = (owner as AI).rot_speed
	idle_timer.setup()
	allow_rotation = true
	rot_timer.setup()
	animated_sprite_2d.play("default")

func exit():
	is_rotating = false
	allow_rotation = false
	rot_timer.stop()
	idle_timer.stop()

func physics_update(delta):
	if !is_rotating:
		return
	rotate_while_idle(delta)
	
func rotate_while_idle(delta: float):
	if is_rotating && allow_rotation:
		var rot_angle = lerp_angle(deg_to_rad(owner.rotation_degrees), deg_to_rad(rot_degrees), delta * rot_speed)
		owner.rotation = rot_angle
	
	if absf(owner.rotation_degrees - rot_degrees) < 1.0:
		is_rotating = false
		rot_timer.setup()

func _on_idle_timer_timeout() -> void:
	state_machine.transition_to("Wandering")
	

func _on_rotation_timer_timeout() -> void:#disabled if not a ship
	#try_rotating() #disabled if not a ship
	pass

func try_rotating():
	if !allow_rotation or is_rotating:
		return
	
	start_rotating()
	
func start_rotating():
	rot_degrees = owner.rotation_degrees + randf_range(45, 300)
	is_rotating = true
