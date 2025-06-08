extends CharacterBody2D

@export var tank_color: String = "red"
@export var tank_speed: int = 0
@export var tank_size: int = 0
@export var tank_health: int = 0
@export var tank_power: int = 0
@export var tank_intv: int = 0
@export var rotation_speed: float = 3.0  # Radians per second
var _cur_health := 0
@export var cur_health: int:
	get: return _cur_health
	set(value):
		if value != _cur_health:
			_cur_health = value
			on_health_changed(value)

var direction := Vector2.ZERO


func on_health_changed(new_value: int):
	print("💔 Health changed to:", new_value)
	update_health_bar(new_value)
	if new_value <= 0 and $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():	
		queue_free()
		
func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	cur_health = tank_health
	_apply_tank()
	update_health_bar(tank_health)
	
	
func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	_handle_controls(delta)
	move_and_slide()
	
func update_health_bar(newVal: int):
	$HealthBar.value = newVal


func _handle_controls(delta):
	# Rotate left/right
	if Input.is_action_pressed("ui_left"):
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("ui_right"):
		rotation += rotation_speed * delta

	# Move forward/backward in facing direction
	var move_direction := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		move_direction = -Vector2.UP.rotated(rotation)
	elif Input.is_action_pressed("ui_down"):
		move_direction = Vector2.UP.rotated(rotation)

	velocity = move_direction * tank_speed


func _apply_tank():
	var path = "res://Sprites/%s_tank.png" % tank_color
	if ResourceLoader.exists(path):
		$Sprite2D.texture = load(path)
	else:
		push_warning("Tank sprite not found: " + path)
	var collision_shape = CollisionShape2D.new()
	$HealthBar.max_value = tank_health
	$HealthBar.value = tank_health
	
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tank_size, tank_size+30)
	collision_shape.shape=shape
	add_child(collision_shape)
	
	print(tank_color, tank_health, tank_intv, tank_power, tank_size, tank_speed)
	
