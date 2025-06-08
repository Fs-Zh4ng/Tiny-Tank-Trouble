extends Node2D  # Or Control, depending on your scene

@onready var player_list_container = $PlayerList
@onready var start_button = $Button

const GAME_SCENE = preload("res://Scenes/tank_select.tscn")

func _ready():
	var addresses = IP.get_local_addresses()
	var ip1 = ""
	for ip in addresses:
		if ip.is_valid_ip_address() and ip.contains(".") and not ip.begins_with("127"):
			print("Host IP:", ip)
			ip1 = ip
			break
	$Label.text = "Server IP: " + ip1
	# Only host can start the game
	start_button.visible = multiplayer.is_server()
	start_button.pressed.connect(on_start_game_pressed)

	# Populate initial player list
	update_player_list()

	# Connect peer updates
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func update_player_list():
	# Remove all existing children from the player list
	for child in player_list_container.get_children():
		player_list_container.remove_child(child)
		child.queue_free()

	# Add self
	var self_id = multiplayer.get_unique_id()
	add_player_entry("You (ID: %s)" % self_id)

	# Add other peers
	for id in multiplayer.get_peers():
		add_player_entry("Player %s" % id)

func add_player_entry(name: String):
	var label = Label.new()
	label.text = name
	var settings = LabelSettings.new()
	settings.font_size = 30  # 👈 Change this to desired size
	label.label_settings = settings
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.2, 0.2, 0.2)  # Background
	stylebox.border_color = Color.WHITE      # Border color
	stylebox.set_border_width(SIDE_LEFT, 2)
	stylebox.set_border_width(SIDE_RIGHT, 2)
	stylebox.set_border_width(SIDE_TOP, 2)
	stylebox.set_border_width(SIDE_BOTTOM, 2)
	stylebox.set_corner_radius_all(6)
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 5
	stylebox.content_margin_bottom = 5

	label.add_theme_stylebox_override("normal", stylebox)

	player_list_container.add_child(label)

func disconnected():
	var start = load("res://Scenes/StartPage.tscn")
	multiplayer.multiplayer_peer.close()
	update_player_list()
	get_tree().change_scene_to_packed(start)

func _on_peer_connected(id):
	print("Peer %d connected to lobby." % id)
	update_player_list()

func _on_peer_disconnected(id):
	print("Peer %d disconnected from lobby." % id)
	update_player_list()

func on_start_game_pressed():
	print("Starting game...")
	start_game.rpc()  # Tell all players to load the game
	get_tree().change_scene_to_packed(GAME_SCENE)

@rpc("authority", "reliable")
func start_game():
	get_tree().change_scene_to_packed(GAME_SCENE)
