extends CharacterBody2D

enum BossState {
	IDLE,
	CHASE,
	RETREAT
}

@onready var hit_animation = $Sprite/FlashAnimation
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health_bar: ProgressBar = $Sprite/HealthBar
@onready var gun_audio_player: AudioStreamPlayer2D = $ShootSound
@onready var death_audio_player: AudioStreamPlayer2D = $ShootSound

@export var bullet: PackedScene = preload("res://Scenes/Bullet.tscn")
@export_range(0, 20) var fire_rate: float = 1
@export_range(1, 1000) var health: float = 510
@export var speed: float = 75.0 # Make speed adjustable in editor

var current_state = BossState.IDLE
var player_ref: CharacterBody2D
var safe_distance = 300.0
var timer: Timer
var can_shoot = true

signal boss_died

func _ready():
	# Direct node reference - adjust the path to match Duck scene structure
	player_ref = get_tree().root.get_node("Game/Duck")

	if !player_ref:
		print("Player not found - check the node path!")
		# Try group as fallback
		player_ref = get_tree().get_first_node_in_group("Duck")

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.5
	timer.timeout.connect(_on_timer_timeout)
	timer.name = "MeanineSwitchStateTimer"
	timer.start()
	
	var cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = fire_rate
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	cooldown_timer.name = "CooldownTimer"
	
	$CooldownTimer.start(fire_rate) # stop fire as soon as scene loads


func _physics_process(delta: float) -> void:
	if !player_ref:
		return

	shoot()
	
	match current_state:
		BossState.IDLE:
			pass
			
		BossState.CHASE:
			# Calculate direction to player
			var direction = (player_ref.global_position - global_position).normalized()
			sprite.play("Walk")
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
				sprite.play("Walk")
			else:
				velocity = Vector2.ZERO
	
func _on_timer_timeout():
	current_state = randi() % BossState.size()
	print("switched to " + BossState.keys()[current_state])

func take_damage(amount: int):
	hit_animation.play("flash")
	health -= amount
	health_bar.value = health
	if health <= 0:
		print(health)
		print("emit signal")
		#queue_free()
		#get_tree().reload_current_scene()
		death_audio_player.play()
		emit_signal("boss_died")

func shoot(): 
	if can_shoot:
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = global_position
		new_bullet.shoot_towards(player_ref.global_position)
		new_bullet.collision_layer = utils.collision_values([4])
		new_bullet.collision_mask = utils.collision_values([2])
		get_tree().root.call_deferred("add_child", new_bullet)
		gun_audio_player.play()
		
		can_shoot = false
		$CooldownTimer.start(fire_rate)
	
	
func _on_cooldown_timer_timeout():
	can_shoot = true
