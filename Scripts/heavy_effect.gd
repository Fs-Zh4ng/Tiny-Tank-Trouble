extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var explosion = $Explosion
	if explosion:
		explosion.play("explode")
	else:
		print("❌ Explosion node not found!")

func _on_timer_timeout() -> void:
	queue_free() # Replace with function body.
