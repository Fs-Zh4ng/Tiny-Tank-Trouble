extends Area2D

@export var bullet_speed: int = 400
@export var bullet_colour: String = ""
@export var bullet_power: int = 1
@export var rot: float = 0.0
var lifetime := 20.0
var velocity := Vector2.ZERO
var timer := 0.0
@export var id := 0

var pbulletEffect := preload("res://Scenes/bulletEffect.tscn")

func _ready():
	rotation = rot
	velocity = -Vector2.UP.rotated(rotation) * bullet_speed
	apply_bullet()
	
	# Connect the Area2D's body_entered signal
	connect("body_entered", Callable(self, "_on_body_entered"))

func apply_bullet():
	var path = "res://Sprites/bullet%s.png" % bullet_colour
	if ResourceLoader.exists(path):
		$Sprite2D.texture = load(path)
	else:
		print("❌ Bullet sprite not found")
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(25, 35)
	
	if not $CollisionShape2D:
		var collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		add_child(collision_shape)
	$CollisionShape2D.shape = shape

func _process(delta):
	# Move the bullet manually
	position += velocity * delta

	# Countdown for lifetime
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_body_entered(body):
	var hit = false
	for i in GameManager.players:
		if body.name == str(GameManager.players[i].id) and body.name != str(id):
			hit = true
			break
	if hit:
		print("hit")
		body.cur_health -= 1
		body.cur_health = max(body.cur_health, 0)
		explode()
		queue_free()
	elif body.name != str(id):
		explode()
		queue_free()

func explode():
	$Sprite2D.visible = false  # Hide the bullet
	var bEffect := pbulletEffect.instantiate()
	bEffect.position = position
	get_parent().add_child(bEffect)

	await get_tree().create_timer(0.5).timeout  # Let animation play
	queue_free()
	# You can add particle or sound effect here
