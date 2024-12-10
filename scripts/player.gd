extends CharacterBody2D

class_name Player

@export var player_id := 1:
	set(id):
		player_id = id
		$InputSynchronizer.set_multiplayer_authority(id)

@onready var health_system: Node2D = $HealthSystem as HealthSystem
@onready var player_ui: CanvasLayer = $PlayerUI as PlayerUI
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer


@export var speed: int = 300 #used for reticle
@export var rightclickaccel: int = 7
#@export var rot_speed: int = 5 #used for rotating ships
@export var projectile_dmg: int = 1
@export var seconds_between_shots: float = .3
@export var spread: float = .025

@export var movement_dir: Vector2 = Vector2.ZERO 
@export var angle = (global_position).angle()
@onready var retina: Sprite2D = $Retina
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var wasd_moving = false
@export var rightclick_moving = false
@export var walking = false
@export var rightclickpos = global_position
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@export var h_scale = true

@onready var camera_2d: Camera2D = $Camera2D

#func _enter_tree() -> void:
	#set_multiplayer_authority(name.to_int())

func _ready():
	player_ui.set_life_bar_max_value(health_system.base_health)
	player_ui.update_life_bar_value(health_system.current_health)
	if multiplayer.get_unique_id() == player_id:
		$PlayerUI.visible = true
		$Retina.visible = true
		camera_2d.make_current()
	else:
		camera_2d.enabled = false

func _apply_animations(delta):
	if walking:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("default")
	if (input_synchronizer.mouse_rel.x > global_position.x) and !h_scale:
		self.transform.x *= -1.0
		h_scale=true
	elif (input_synchronizer.mouse_rel.x < global_position.x) and h_scale:
		self.transform.x *= -1.0
		h_scale=false
	
func _apply_movement_from_input(delta):
	#if !is_multiplayer_authority():
	#	return
	movement_dir = Vector2.ZERO
	walking = false
	if $InputSynchronizer.rightClicked:
		wasd_moving = false
		rightclick_moving = true
		rightclickpos = input_synchronizer.mouse_rel
	
	if $InputSynchronizer.isUp:
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.UP
		walking = true
	if $InputSynchronizer.isDown:
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.DOWN
		walking = true
	if $InputSynchronizer.isLeft:
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.LEFT
		walking = true
	if $InputSynchronizer.isRight:
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.RIGHT
		walking = true
	#if $InputSynchronizer.esc:
	#	$"../".exit_game(name.to_int())
	#	get_tree().quit()
	
	angle = input_synchronizer.angle
	
	#set up nav for right click
	if rightclick_moving:
		var navdir = Vector2()
		nav.target_position  = rightclickpos
		navdir = nav.get_next_path_position() - global_position
		navdir = navdir.normalized()
		velocity = velocity.lerp(navdir * speed, rightclickaccel * delta)
		walking = true
		if nav.is_navigation_finished():#prevents jitter on reach end
			walking = false
			wasd_moving = true
			rightclick_moving = false
	#wasd velocity
	if wasd_moving:
		velocity = movement_dir * speed
	#angle isn't decided by move mode
	move_and_slide()
	angle = input_synchronizer.angle
	if angle:
		retina.global_rotation = angle

#@rpc("any_peer", "call_local", "reliable")
func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_apply_movement_from_input(delta)
	if not multiplayer.is_server() || MainMenu.hosting:
		_apply_animations(delta)
func _input(event):
	pass

#@rpc("any_peer", "call_local", "reliable")
func take_damage(damage: int):
	health_system.take_damage(damage)
	player_ui.update_life_bar_value(health_system.current_health)
