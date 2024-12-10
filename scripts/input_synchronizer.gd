extends MultiplayerSynchronizer

@onready var player = $".."

var isUp
var isDown
var isLeft
var isRight
var rightClicked
var esc

@export var angle := float(0)
@export var mouse_rel = Vector2.ZERO
@export var mouse_pos = Vector2.ZERO
@export var mouse_position = Vector2.ZERO
var screen = Vector2.ZERO  

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	screen = get_viewport().get_visible_rect().size
	screen = screen / 2
	
	isUp = Input.is_action_pressed("up")
	isDown = Input.is_action_pressed("down")
	isLeft = Input.is_action_pressed("left")
	isRight = Input.is_action_pressed("right")
	rightClicked = Input.is_action_pressed("rightclick")
	esc = Input.is_action_pressed("esc")
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = get_viewport().get_mouse_position()
		mouse_position -= (get_viewport().get_visible_rect().size/2) #adjust for screen size
		mouse_position /= $"../Camera2D".zoom.x #offset for camera zoom
		mouse_position += player.global_position #offset for position of player
		mouse_pos = Vector2(event.position)
		mouse_rel = mouse_pos - screen
		angle = atan2(mouse_rel.y, mouse_rel.x) # returns an angle

func _physics_process(delta: float) -> void:
	isUp = Input.is_action_pressed("up")
	isDown = Input.is_action_pressed("down")
	isLeft = Input.is_action_pressed("left")
	isRight = Input.is_action_pressed("right")
	rightClicked = Input.is_action_pressed("rightclick")
	esc = Input.is_action_pressed("esc")
	if esc:
		quitgame()
	

func quitgame():
	if multiplayer.is_server():
		multiplayer.peer_disconnected.connect(delete_player)
		delete_player(player.player_id)

func delete_player(id):
	_delete_player.rpc(id)
	
@rpc("any_peer", "call_local")
func _delete_player(id):
	get_node(str(id)).queue_free()

func _process(delta):
	pass
