extends Area2D

@export var speed: float = 750.00
var direction: Vector2

func shoot_towards(target_position: Vector2):
	direction = (target_position - global_position).normalized()

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	body.take_damage(5)
	queue_free()

