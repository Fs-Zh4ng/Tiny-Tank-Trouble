extends Control

@export var game_scene_path := "res://Scenes/Game.tscn"

var selected_tanks = {}  # peer_id -> tank data

func _ready():
	# Connect the tank selection buttons
	$HBoxContainer/Tank1/RedButton.pressed.connect(func(): _send_tank_selection("rouge", 300, 70, 100, 30, 3, 5.0, "5"))
	$HBoxContainer/Tank2/BlueButton.pressed.connect(func(): _send_tank_selection("blue", 350, 70, 90, 35, 3, 5.0, "5"))
	$HBoxContainer/Tank3/GreenButton.pressed.connect(func(): _send_tank_selection("green", 400, 70, 90, 30, 3, 5.0, "5"))
	$HBoxContainer/Tank4/GreenButton.pressed.connect(func(): _send_tank_selection("sand", 300, 70, 85, 40, 3, 5.0, "5"))
	$HBoxContainer/Tank5/GreenButton.pressed.connect(func(): _send_tank_selection("red", 250, 80, 120, 50, 4, 3.0, "2"))
	$HBoxContainer/Tank6/GreenButton.pressed.connect(func(): _send_tank_selection("dark", 225, 80, 140, 55, 4, 3.0, "4"))
	$HBoxContainer/Tank7/GreenButton.pressed.connect(func(): _send_tank_selection("big", 175, 100, 160, 65, 6, 1.5, "1"))

# Called by all players (including host) when selecting a tank
func _send_tank_selection(color: String, speed: int, sz: int, health: int, power: int, interval: int, rot: float, heavy: String):
	var data := {
		"id": multiplayer.get_unique_id(),
		"color": color,
		"speed": speed,
		"sz": sz,
		"health": health,
		"power": power,
		"interval": interval,
		"rot": rot,
		"heavy": heavy
	}
	
	var id = multiplayer.get_unique_id()
	
	$HBoxContainer.visible = false
	$Label.text = "Waiting for other players to pick..."


	if multiplayer.is_server():
		send_player_info(data, id)
		_receive_tank_selection(multiplayer.get_unique_id(), data)
		print(multiplayer.get_unique_id())
		
	else:
		send_player_info.rpc_id(1, data, id)
		rpc_id(1, "_receive_tank_selection", multiplayer.get_unique_id(), data)
		
		print("Sending tank to host ID 1 from peer", multiplayer.get_unique_id())
		print("Client sending tank:", data)

@rpc("any_peer")
func send_player_info(data, id):
	print("BANG")
	if !GameManager.players.has(id):
		GameManager.players[id] = data
	
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_info.rpc(GameManager.players[i], i)


@rpc("any_peer")
func _receive_tank_selection(peer_id: int, data: Dictionary):
	print("Received from", peer_id, data)
	selected_tanks[peer_id] = data
	var total_players = multiplayer.get_peers().size() + 1  # +1 for host
	print(total_players)
	print(selected_tanks)
	if selected_tanks.size() == total_players:
		start_multiplayer_game()

func start_multiplayer_game():
	for peer_id in multiplayer.get_peers():
		var data = selected_tanks.get(peer_id)
		if data:
			rpc_id(peer_id, "_start_game_for_player", data)

	var host_data = selected_tanks.get(multiplayer.get_unique_id())
	if host_data:
		_start_game_with_data(host_data)

@rpc("any_peer")
func _start_game_for_player(data: Dictionary):
	_start_game_with_data(data)


func _start_game_with_data(data: Dictionary):
	var game_scene = preload("res://Scenes/Game.tscn").instantiate()
	game_scene.set_tank(
		data["color"],
		data["speed"],
		data["sz"],
		data["health"],
		data["power"],
		data["interval"],
		data["rot"],
		data["heavy"]
	)
	get_tree().root.add_child(game_scene)
	queue_free()
