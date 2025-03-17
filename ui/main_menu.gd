extends CanvasLayer

func _ready():
	print("start menu")
	$Control/StartButton.pressed.connect(_on_start_button_pressed)
	$Control/QuitButton.pressed.connect(_on_quit_button_pressed)


func _on_start_button_pressed():
	GameManager.set_game_mode(GameManager.GAMEMODE.INITIALIZING)


func _on_quit_button_pressed():
	get_tree().quit()
