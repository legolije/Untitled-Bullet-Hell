extends CharacterBody2D

enum BossState {
	IDLE,
	CHASE,
	RETREAT
}

@export var speed: float = 75.0  # Make speed adjustable in editor
var current_state = BossState.IDLE
var player_ref: CharacterBody2D
var circle_angle = 360.0
var safe_distance = 300.0

var timer: Timer


func _ready():
	# Direct node reference - adjust the path to match Duck scene structure
	player_ref = get_tree().root.get_node("Game/Duck")

	if !player_ref:
		print("Player not found - check the node path!")
		# Try group as fallback
		player_ref = get_tree().get_first_node_in_group("Duck")

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 5
	timer.timeout.connect(_on_timer_timeout)
	timer.name = "MeanineSwitchStateTimer"
	timer.start()


func _physics_process(delta: float) -> void:
	if !player_ref:
		return

	# Debug print to check if the function is running
	#print("Distance to player: ", global_position.distance_to(player_ref.global_position))

	match current_state:
		BossState.IDLE:
			pass
			
		BossState.CHASE:			
			# Calculate direction to player
			var direction = (player_ref.global_position - global_position).normalized()
			# Set velocity
			velocity = direction * speed
			# Actually move the character
			move_and_slide()

		BossState.RETREAT:
			var distance = global_position.distance_to(player_ref.global_position)
			if distance < safe_distance:
				var direction = (global_position - player_ref.global_position).normalized()
				velocity = direction * speed
				move_and_slide()
			else:
				velocity = Vector2.ZERO

func execute_attack_pattern():
	pass
	
	
func _on_timer_timeout():
	current_state = randi() % BossState.size()
	print("switched to " + BossState.keys()[current_state])
