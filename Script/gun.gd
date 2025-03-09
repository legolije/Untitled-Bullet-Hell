extends Node2D

@onready var gun_animation: AnimatedSprite2D = $GunAnimation
@onready var attached_to: Node2D = $".."

@export var orbit_radius: float = 30.0  # Distance from player center
@export var gun_offset: Vector2 = Vector2(0, 0)  # Offset from orbit position

func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var player_position = attached_to.global_position

	# Calculate direction to mouse
	var direction = (mouse_position - player_position).normalized()

	# Reset rotation first (important!)
	rotation = 0

	# Determine if we need to flip based on mouse position
	var flip = mouse_position.x < player_position.x
	gun_animation.flip_v = flip

	# Position gun on circle around player with offset
	position = direction * orbit_radius

	# Apply the gun offset (adjustable in inspector)
	position += gun_offset

	# Make gun look at mouse
	look_at(mouse_position)
