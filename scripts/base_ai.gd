extends CharacterBody2D

class_name AI

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var vision_ray_cast_2d: RayCast2D = $RayCastHolder/VisionRayCast2D as RayCast2D
@onready var state_machine: StateMachine = $StateMachine as StateMachine
@onready var health_system: HealthSystem = $HealthSystem

@export_group("Locomotion")
@export var rot_speed: float = 5 
@export var wandering_speed = 150
@export var nav_target: Node2D
@export var chasing_speed = 200
var h_scale = true
var locked_in_attack = false

@export_group("Scanning for player")
@export var angle_cone_of_vision = 90
@export var max_vision_distance = 250
@export var angle_between_rays = 30

@export_group("Attack")
@export_range(0.1, 1) var attack_speed: float = 1
@export_range(1, 10) var attack_damage: float = 50

var current_speed

func _ready():
	current_speed = wandering_speed
	
	health_system.died.connect(on_died)
	
func _process(delta):
	$RayCastHolder.rotate(.5)
	search_for_player_with_raycast()

func move_to_position(target_position: Vector2):
	var motion = position.direction_to(target_position) * current_speed
	navigation_agent_2d.set_velocity(motion)
	#$RayCastHolder.look_at(target_position)
	if (target_position.x > global_position.x) and !h_scale:
		self.transform.x *= -1.0
		$LifeBar.scale.x *= -1.0
		$LifeBar.pivot_offset.x -= 20
		h_scale=true
	elif (target_position.x < global_position.x) and h_scale:
		self.transform.x *= -1.0
		$LifeBar.scale.x *= -1.0
		$LifeBar.pivot_offset.x += 20
		h_scale=false
	if str(self.transform.x.x) == "-0": self.transform.x.x=0
	if str(self.transform.x.y) == "-0": self.transform.x.y=0
	if str(self.transform.y.x) == "-0": self.transform.y.x=0
	if str(self.transform.y.y) == "-0": self.transform.y.y=0
	velocity = motion
	move_and_slide()

func search_for_player_with_raycast():
	if state_machine.state_name != "Idle" and state_machine.state_name != "Wandering":
		return
	var cast_count = int(angle_cone_of_vision/angle_between_rays)+1
	
	for index in cast_count:
		var cast_vector = max_vision_distance * Vector2.UP.rotated(rad_to_deg(angle_between_rays)*(index-cast_count)/2.0)
		vision_ray_cast_2d.target_position = cast_vector
		vision_ray_cast_2d.force_raycast_update()
	
	#currently attacks all players, should be changed after new player types and teams are added
	if vision_ray_cast_2d.is_colliding() and vision_ray_cast_2d.get_collider().is_in_group("players") :
		state_machine.transition_to("Chase")
		state_machine.player_chasing = vision_ray_cast_2d.get_collider()
	
func take_damage(damage: int):
	health_system.take_damage(damage)
func on_died():
	queue_free()
