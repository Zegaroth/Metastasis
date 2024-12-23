extends Marker2D

class_name ShootingSystem

signal shot
@export var shooting = false
@export var seconds_between_shots: float
@export var spread: float

@onready var projectile_scene = preload("res://scenes/projectile.tscn")


func _ready():
	seconds_between_shots = owner.seconds_between_shots
	spread = owner.spread

func _physics_process(delta: float) -> void:
	if $"../../InputSynchronizer".leftClicked:
		shooting = true
	if !$"../../InputSynchronizer".leftClicked:
		shooting = false
	#if shooting and multiplayer.is_server():
	if shooting:
		wait(seconds_between_shots)
		shoot()
		#shoot.rpc()
		

#@rpc("any_peer", "call_local", "reliable")
#@rpc("call_local")
#@rpc("any_peer", "call_local" )
func shoot():
	#if !owner.is_multiplayer_authority():
	#	return
	#var spawner = get_node("/root/Main/MultiplayerSpawner")
	var projectile = projectile_scene.instantiate() as Projectile
	projectile.name = "Bullet_" + str(Time.get_ticks_msec())  # Unique name based on time
	#projectile.spawner = get_tree().get_first_node_in_group("spawner")
	projectile.set_projectile_owner(owner)
	#rpc('projectile.set_projectile_owner', owner)
	projectile.damage = owner.projectile_dmg
	#get_tree().root.add_child(projectile)
	get_node("/root/Main").add_child(projectile, true)
	#get_tree().get_first_node_in_group("spawner").add_spawnable_scene(projectile)
	#get_tree().get_first_node_in_group("spawner").spawn(projectile)
	#$"../..".add_child(projectile)
	#get_node("/root/Main").add_child(projectile, true)
	#projectile.set_network_master(get_tree().get_network_unique_id())
	
	var move_direction = ($"../../InputSynchronizer".mouse_position - global_position).normalized()
	var deviation_angle = PI * spread
	projectile.move_direction = move_direction
	projectile.global_position = global_position
	projectile.rotation = move_direction.angle()
	projectile.move_direction.x += randf_range(-deviation_angle, deviation_angle)
	projectile.move_direction.y += randf_range(-deviation_angle, deviation_angle)
	
	shot.emit()
	
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	
