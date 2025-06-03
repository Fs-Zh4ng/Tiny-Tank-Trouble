extends Node2D

var selected_color: String = "red"
var speed: int = 0
var size: int = 0
var health: int = 0
var power: int = 0
var interval: int = 0
var rotate: float = 0
var tank
var bullet
var h
var can_shoot := true
var shot_timer := 0.0
var heavyType : String = ""
var can_h := true
var shot2Time := 0.0


		
func _process(delta):
	if Input.is_action_pressed("shoot") and can_shoot:
		bullet = preload("res://Scenes/bullet.tscn").instantiate()
		bullet.bullet_colour = selected_color
		bullet.rot = tank.rotation
		add_child(bullet)
		var offset = Vector2.UP.rotated(tank.rotation + PI) * 30
		var off = Vector2(0, +30).rotated(tank.rotation)
		bullet.global_position = tank.global_position + offset + off
		bullet.rotation = tank.rotation + PI
		can_shoot = false
		shot_timer = 0.0
	
	if Input.is_action_pressed("heavy") and can_h:
		h = preload("res://Scenes/heavyShot.tscn").instantiate()
		h.bullet_name = heavyType
		h.bullet_speed = speed-100
		h.bullet_power = power
		h.rot = tank.rotation
		add_child(h)
		var offset = Vector2.UP.rotated(tank.rotation + PI) * 30
		var off = Vector2(0, +30).rotated(tank.rotation)
		h.global_position = tank.global_position + offset + off
		h.rotation = tank.rotation + PI
		can_h = false
		shot2Time = 0.0

	if not can_shoot:
		shot_timer += delta
		if shot_timer >= 0.3:
			can_shoot = true
	if not can_h:
		shot2Time += delta
		if shot2Time >= interval:
			can_h = true

func set_tank(color: String, sp: int, sz: int, hp: int, pw: int, intv: int, rot: float, heavy: String):
	selected_color = color
	speed = sp
	size = sz
	health = hp
	power = pw
	interval = intv
	rotate = rot
	heavyType = heavy

func _ready():
	tank = preload("res://Scenes/tank.tscn").instantiate()
	tank.tank_color = selected_color
	tank.tank_speed = speed
	tank.tank_size = size
	tank.tank_health = health
	tank.tank_power = power
	tank.tank_intv = interval
	tank.rotation_speed = rotate
	add_child(tank)
	tank.position = Vector2(randi_range(50, 2200), randi_range(50, 1200))  # Start position
