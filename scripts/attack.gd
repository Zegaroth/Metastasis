extends State
#set up telegraphattack, then after timer followthrough attack and activate hurtbox
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"

var attack_speed
var attack_damage
var time_elapsed: float = 0
var time_between_attacks
var player_is_in_hitbox

func _ready():
	attack_damage = (owner as AI).attack_damage
	attack_speed = (owner as AI).attack_speed
	time_between_attacks = 0.3 + 1/attack_speed
	player_is_in_hitbox = false
	owner.locked_in_attack = false
	
func enter(msg = {}):
	attack()
	
func physics_update(delta):
	time_elapsed += delta
	if time_elapsed >= time_between_attacks and player_is_in_hitbox:
		attack()
		time_elapsed = 0 
	
func attack():
	owner.locked_in_attack = true
	animated_sprite_2d.play("telegraph")
	var speed = owner.current_speed
	owner.current_speed = 0
	
	await get_tree().create_timer(.5).timeout
	animated_sprite_2d.play("attack")
	var player = state_machine.player_chasing
	if player_is_in_hitbox and player and player.has_method("take_damage"):
		player.take_damage(attack_damage)
		
	await get_tree().create_timer(.1).timeout
	animated_sprite_2d.play("default")
	owner.current_speed = speed
	owner.locked_in_attack = false
	if(!player_is_in_hitbox):
		state_machine.transition_to("Chase")
func exit():
	time_elapsed = 0
	

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body == state_machine.player_chasing:
		player_is_in_hitbox = true

func _on_attack_hitbox_body_exited(body: Node2D) -> void:
	if body == state_machine.player_chasing:
		player_is_in_hitbox = false
	if owner:
		if body == state_machine.player_chasing and !owner.locked_in_attack:
			state_machine.transition_to("Chase")
