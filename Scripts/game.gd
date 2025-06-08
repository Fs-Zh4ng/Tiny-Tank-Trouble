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
var done := false

		
func _process(delta):

	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	if Input.is_action_pressed("shoot") and can_shoot:
		spawn_bullet.rpc(selected_color, tank.rotation, tank.global_position, multiplayer.get_unique_id())
		can_shoot = false
		shot_timer = 0.0
	
	if Input.is_action_pressed("heavy") and can_h:
		print("Type", heavyType)
		spawn_heavy.rpc(heavyType, tank.rotation, tank.global_position, speed, power, multiplayer.get_unique_id())
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
	
	if tank.cur_health <= 0:
		$Label.visible = true
		$Label2.visible = true
		remove_peer.rpc(multiplayer.get_unique_id())
		remove_child(tank)
		
		
	if GameManager.players.size()==1:
		var id
		for i in GameManager.players:
			id = GameManager.players[i].id
		$Label.text = "Player " + str(id) + " Won!"
		$Label.visible = true
		$Label2.visible = false
		$Button.visible = true
	

func disconnected(id):
	get_tree().change_scene_to_file("res://Scenes/StartPage.tscn")
	queue_free()

func return_home():
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			multiplayer.multiplayer_peer.disconnect_peer(peer)
		multiplayer.multiplayer_peer.close()
		get_tree().change_scene_to_file("res://Scenes/StartPage.tscn")
		queue_free()
	else:
		multiplayer.multiplayer_peer.close()
		get_tree().change_scene_to_file("res://Scenes/StartPage.tscn")
		queue_free()

@rpc("any_peer", "call_local")
func remove_peer(id):
	GameManager.players.erase(id)
	

@rpc("any_peer", "call_local")
func spawn_bullet(color, rot, pos, id):
	bullet = preload("res://Scenes/bullet.tscn").instantiate()
	bullet.bullet_colour = color
	bullet.rot = rot
	bullet.id = id
	add_child(bullet)
	var offset = Vector2.UP.rotated(rot + PI) * 30
	var off = Vector2(0, +30).rotated(rot)
	bullet.global_position = pos + offset + off
	bullet.rotation = rot + PI

@rpc("any_peer", "call_local")
func spawn_heavy(heavy1, rot, pos, speed1, power1, id):
	print("type ", heavy1)
	print(id)
	h = preload("res://Scenes/heavyShot.tscn").instantiate()
	h.bullet_name = heavy1
	h.bullet_speed = speed1
	h.bullet_power = power1
	h.id = id
	h.rot = rot
	add_child(h)
	var offset = Vector2.UP.rotated(rot + PI) * 30
	var off = Vector2(0, +30).rotated(rot)
	h.global_position = pos + offset + off
	h.rotation = rot + PI

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
	multiplayer.peer_disconnected.connect(disconnected)
	print(GameManager.players.size())
	$Label.visible = false
	$Label2.visible = false
	var id = multiplayer.get_unique_id()
	set_multiplayer_authority(id)
	print("ID", get_multiplayer_authority())
	print("Id2:", multiplayer.get_unique_id())
	selected_color = GameManager.players[id].color
	health = GameManager.players[id].health
	power = GameManager.players[id].power
	size = GameManager.players[id].sz
	interval = GameManager.players[id].interval
	rotate = GameManager.players[id].rot
	var index = 0
	for i in GameManager.players:
		var tank1 = preload("res://Scenes/tank.tscn").instantiate()
		tank1.tank_color = GameManager.players[i].color
		tank1.tank_health = GameManager.players[i].health
		tank1.tank_speed = GameManager.players[i].speed
		tank1.tank_size = GameManager.players[i].sz
		tank1.tank_power = GameManager.players[i].power
		tank1.tank_intv = GameManager.players[i].interval
		tank1.rotation_speed = GameManager.players[i].rot
		tank1.name = str(GameManager.players[i].id)
		add_child(tank1)
		if i == id:
			tank = tank1
			heavyType = GameManager.players[i].heavy
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				tank1.global_position = spawn.global_position
		index += 1
		
	
