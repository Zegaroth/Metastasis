extends CanvasLayer

class_name PlayerUI

@onready var life_bar: ProgressBar = $MarginContainer/LifeBar

func set_life_bar_max_value(max_value: int):
	life_bar.max_value = max_value
	
func update_life_bar_value(life: int):
	life_bar.value = life
