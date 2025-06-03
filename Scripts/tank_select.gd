extends Control

func _ready():
	# Connect the button signals
	$HBoxContainer/Tank1/RedButton.pressed.connect(func(): _start_game_with("rouge", 300, 70, 100, 30, 10, 5.0, "5"))
	$HBoxContainer/Tank2/BlueButton.pressed.connect(func(): _start_game_with("blue", 350, 70, 90, 35, 10, 5.0, "5"))
	$HBoxContainer/Tank3/GreenButton.pressed.connect(func(): _start_game_with("green", 400, 70, 90, 30, 10, 5.0, "5"))
	$HBoxContainer/Tank4/GreenButton.pressed.connect(func(): _start_game_with("sand", 300, 70, 85, 40, 10, 5.0, "5"))
	$HBoxContainer/Tank5/GreenButton.pressed.connect(func(): _start_game_with("red", 250, 80, 120, 50, 15, 3.0, "2"))
	$HBoxContainer/Tank6/GreenButton.pressed.connect(func(): _start_game_with("dark", 225, 80, 140, 55, 20, 3.0, "4"))
	$HBoxContainer/Tank7/GreenButton.pressed.connect(func(): _start_game_with("big", 175, 100, 160, 65, 25, 1.5, "1"))


func _start_game_with(color: String, speed: int, sz: int, health: int, power: int, interval: int, rot: float, heavy: String):
	var game_scene = preload("res://Scenes/Game.tscn").instantiate()
	game_scene.set_tank(color, speed, sz, health, power, interval, rot, heavy)
	get_tree().root.add_child(game_scene)
	queue_free()  # Close the selection screen
