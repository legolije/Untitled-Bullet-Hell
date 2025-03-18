extends Camera2D


@onready var player = get_node("../Duck")  # Adjust the path to your character node
var following_player = true

func _process(delta):
	if following_player:
		global_position = player.global_position
