extends Node2D

func _ready():
	# Hide the system cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	# Update position to follow mouse
	position = get_global_mouse_position()
