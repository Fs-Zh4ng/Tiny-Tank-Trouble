extends Node2D

@onready var host_button = $VBoxContainer/Button
@onready var join_button = $VBoxContainer/Button2
@onready var random_button = $VBoxContainer/Button3

const PORT = 8080
const MAX_PLAYERS = 4
const GAME_SCENE = preload("res://Scenes/Lobby.tscn")
var host_pass = ""
var verified_peers = []

func _ready():
	if OS.has_feature("dedicated server"):
		on_host_pressed()

func on_host_pressed():
	var addresses = IP.get_local_addresses()
	for ip in addresses:
		if ip.is_valid_ip_address() and ip.contains(".") and not ip.begins_with("127"):
			print("Host IP:", ip)
			break
	var server = ENetMultiplayerPeer.new()
	server.create_server(PORT, 4)
	multiplayer.multiplayer_peer = server
	print("Is Server: ", multiplayer.is_server())
	print(server)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	get_tree().change_scene_to_packed(GAME_SCENE)

func _on_peer_disconnected(id: int):
	print("Player %s disconnected" % id)

func on_join_pressed():
	var ip = await prompt_password("Enter host IP")
	if ip != null:
		print("Connecting")
		var peer = ENetMultiplayerPeer.new()
		peer.create_client(ip, PORT)
		multiplayer.multiplayer_peer = peer
		print("Is Server: ", multiplayer.is_server())
		print(peer)
		multiplayer.connected_to_server.connect(load_game_scene)
		multiplayer.connection_failed.connect(_on_connection_failed)
	

func on_random_pressed():
	var peer = ENetMultiplayerPeer.new()
	var random_ip = "127.0.0.1"
	peer.create_client(random_ip, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(load_game_scene)
	multiplayer.connection_failed.connect(_on_connection_failed)

func load_game_scene():
	get_tree().change_scene_to_packed(GAME_SCENE)

func _on_connection_failed():
	print("Failed to connect to server.")
	show_error("Could not join match.")

# Called only on host when a peer connects
func _on_peer_connected(peer_id):
	print("Peer %d connected" % peer_id)


@rpc("authority")
func _kick(reason: String):
	show_error(reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func prompt_password(prompt_text: String) -> String:
	var dialog := AcceptDialog.new()
	dialog.name = "PromptDialog"
	dialog.set_exclusive(true)
	dialog.size = Vector2(300, 50)
	var line_edit := LineEdit.new()
	line_edit.placeholder_text = prompt_text
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialog.add_child(line_edit)
	add_child(dialog)
	dialog.popup_centered()
	line_edit.grab_focus()
	await dialog.confirmed
	var input_text := line_edit.text
	dialog.queue_free()
	return input_text

func show_error(message: String):
	var dialog := AcceptDialog.new()
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()
