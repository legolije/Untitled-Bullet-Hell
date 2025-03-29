extends Node2D


@export var levels: Array[PackedScene]
@export var boss_spawn_delay: float = 3

@onready var spawn_timer: Timer = $SpawnDelay

var current_level

func _ready() -> void:
	pick_level()

func _process(delta: float) -> void:
	pass

func pick_level() -> void:
	var level_scene: PackedScene = levels[randi_range(0, levels.size() - 1)]
	current_level = level_scene.instantiate()
	current_level.connect("boss_died", _on_boss_died)
	get_tree().root.get_node("Game").call_deferred("add_child", current_level)

func _meanie_spawn_timer() -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_ready_to_spawn_meanie)
	timer.name = "MeanieSpawnTimer"
	add_child(timer)
	return timer

func _on_boss_died() -> void:
	current_level.queue_free()
	var spawn_delay_timer = _meanie_spawn_timer()
	spawn_delay_timer.start(boss_spawn_delay)
	
func _on_ready_to_spawn_meanie() -> void:
	pick_level()
