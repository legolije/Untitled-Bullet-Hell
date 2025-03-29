extends CharacterBody2D

@onready var hit_animation = $Sprite/FlashAnimation
@onready var sprite: AnimatedSprite2D = $Sprite
@export var bullet: PackedScene = preload("res://Scenes/Bullet.tscn")
@export_range(0, 20) var fire_rate: float = 0.3
@export_range(1, 1000) var health: float = 100
@onready var health_bar: ProgressBar = $HealthBar
@onready var gun: Node2D = $Gun
@onready var game_over: CanvasLayer = $"../YouDied!"
@onready var level_spawner: Node2D = %LevelSpawner
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


var SPEED = 150
var direction = Vector2()
var can_shoot = true

func _ready():
	# Create a timer for the cooldown
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.name = "CooldownTimer"


func _physics_process(_delta):
	var mov_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	direction = Vector2(mov_x, mov_y)
	
	velocity = direction * SPEED
	
	if Input.is_action_pressed("Click") and can_shoot:
		shoot()
	
	
	if Input.is_action_pressed("left"):
		sprite.play("Walk")
		sprite.flip_h = true
	else:
		if Input.is_action_pressed("right"):
			sprite.play("Walk")
			sprite.flip_h = false
		else:
				if Input.is_action_pressed("up"):
					sprite.play("Walk")
				else:
					if Input.is_action_pressed("down"):
						sprite.play("Walk")
					else:
						sprite.play("Duck")
	move_and_slide()

func take_damage(amount: int):
	hit_animation.play("flash")
	health -= amount
	health_bar.value = health
	if health <= 0:
		game_over._game_over()

func shoot():
	var new_bullet = bullet.instantiate()
	get_tree().root.call_deferred("add_child", new_bullet)
	new_bullet.global_position = global_position
	new_bullet.shoot_towards(get_global_mouse_position())
	new_bullet.collision_layer = utils.collision_values([4])
	new_bullet.collision_mask = utils.collision_values([3])
	audio_player.play()

	can_shoot = false
	$CooldownTimer.start(fire_rate)
	
	
func _on_timer_timeout():
	can_shoot = true
