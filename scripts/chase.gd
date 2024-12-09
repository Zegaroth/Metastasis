extends State

const DISTANCE_TO_STOP_CHASING = 250
const CHANCE_TO_STOP_CHASING = .5
@onready var navigation_agent_2d: NavigationAgent2D = $"../../NavigationAgent2D" as NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D" as AnimatedSprite2D
@onready var chase_timer: RandomTimer = $ChaseTimer as RandomTimer

func enter(msg = {}) -> void:
	if owner.is_queued_for_deletion():
		return
	
	animated_sprite_2d.play("walk")
	owner.current_speed = owner.chasing_speed
	navigation_agent_2d.target_position = owner.global_position #stop wandering
	start_chasing()
	
func physics_update(delta: float):
	if navigation_agent_2d.is_navigation_finished():
		if try_to_stop_chasing():
			return
		set_next_chasing_point()
		
	var next_pos = navigation_agent_2d.get_next_path_position()
	(owner as AI).move_to_position(next_pos)
	
func try_to_stop_chasing() -> bool:
	var player = state_machine.player_chasing
	if player == null:
		return true
	var player_pos = player.global_position
	var distance_to_player = (owner as AI).global_position.distance_to(player_pos)
	if distance_to_player > DISTANCE_TO_STOP_CHASING && randf() < CHANCE_TO_STOP_CHASING:
		stop_chasing()
		return true
	return false
	
func stop_chasing():
	var new_state = ["Idle", "Wandering"].pick_random()
	state_machine.transition_to(new_state)
	
func exit():
	chase_timer.stop()
	animated_sprite_2d.play("default")
	owner.current_speed = owner.wandering_speed

func _on_chase_timer_timeout() -> void:
	if try_to_stop_chasing():
		return
	start_chasing()

func start_chasing():
	set_next_chasing_point()
	chase_timer.setup()
	
func set_next_chasing_point():
	animated_sprite_2d.play("walk")
	var player = state_machine.player_chasing
	if player == null:
		return true
	var player_pos = player.global_position
	var nav_point = NavigationServer2D.map_get_closest_point(navigation_agent_2d.get_navigation_map(), player_pos)
	navigation_agent_2d.target_position = nav_point


func _on_attack_area_body_entered(body: Node2D) -> void:
	if !body.is_in_group("players"):
		return
	state_machine.transition_to("Attack")
