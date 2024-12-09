extends CharacterBody2D

class_name Player

@export var player_id := 1:
	set(id):
		player_id = id

@onready var health_system: Node2D = $HealthSystem as HealthSystem
@onready var player_ui: CanvasLayer = $PlayerUI as PlayerUI

@export var speed: int = 300 #used for reticle
@export var rightclickaccel: int = 7
#@export var rot_speed: int = 5 #used for rotating ships
@export var projectile_dmg: int = 1
@export var seconds_between_shots: float = .3
@export var spread: float = .025

var movement_dir: Vector2 = Vector2.ZERO 
var angle
@onready var retina: Sprite2D = $Retina
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var wasd_moving = false
var rightclick_moving = false
var walking = false
var rightclickpos
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var h_scale = true

@onready var camera_2d: Camera2D = $Camera2D

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready():
	player_ui.set_life_bar_max_value(health_system.base_health)
	player_ui.update_life_bar_value(health_system.current_health)
	if is_multiplayer_authority():
		$PlayerUI.visible = true
		$Retina.visible = true
		camera_2d.make_current()

#@rpc("any_peer", "call_local", "reliable")
func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
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
	angle = (get_global_mouse_position() - global_position).angle()
	if angle:
		retina.global_rotation = angle
		#below is used for ships
		#global_rotation = lerp_angle(global_rotation, angle, delta * rot_speed)
	if walking:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("default")
	if (get_global_mouse_position().x > global_position.x) and !h_scale:
		self.transform.x *= -1.0
		h_scale=true
	elif (get_global_mouse_position().x < global_position.x) and h_scale:
		self.transform.x *= -1.0
		h_scale=false
	#if str(self.transform.x.x) == "-0": self.transform.x.x=0
	#if str(self.transform.x.y) == "-0": self.transform.x.y=0
	#if str(self.transform.y.x) == "-0": self.transform.y.x=0
	#if str(self.transform.y.y) == "-0": self.transform.y.y=0
	
func _input(event):
	if !is_multiplayer_authority():
		return
	movement_dir = Vector2.ZERO
	walking = false
	if Input.is_action_just_pressed("rightclick"):
		wasd_moving = false
		rightclick_moving = true
		rightclickpos = get_global_mouse_position()
	
	if Input.is_action_pressed("up"):
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.UP
		walking = true
	if Input.is_action_pressed("down"):
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.DOWN
		walking = true
	if Input.is_action_pressed("left"):
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.LEFT
		walking = true
	if Input.is_action_pressed("right"):
		wasd_moving = true
		rightclick_moving = false
		movement_dir = movement_dir + Vector2.RIGHT
		walking = true
	if Input.is_action_pressed("esc"):
		$"../".exit_game(name.to_int())
		get_tree().quit()
	
	angle = (get_global_mouse_position() - global_position).angle()

#@rpc("any_peer", "call_local", "reliable")
func take_damage(damage: int):
	health_system.take_damage(damage)
	player_ui.update_life_bar_value(health_system.current_health)
