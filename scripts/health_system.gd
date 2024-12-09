extends Node2D

class_name HealthSystem

signal died
signal damage_taken(current_health: int)

@export var base_health = 500
@export var current_health: int

func _ready():
	current_health = base_health
	
func take_damage(damage: int):
	current_health -= damage
	damage_taken.emit(current_health)
	if current_health <= 0:
		died.emit()
		
		
		
