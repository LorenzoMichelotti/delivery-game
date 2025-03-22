extends CanvasLayer

func _ready():
	update_money_label(0)
	PlayerManager.money_changed.connect(update_money_label)
	update_money_label(PlayerManager.money)

func update_money_label(new_money):
	$Panel/MoneyLabel.text = "$" + str(new_money).pad_zeros(9)

func _on_menu_button_pressed():
	hide()
	GameManager.set_game_mode(GameManager.GAMEMODE.MENU)


func _on_new_run_button_2_pressed():
	hide()
	LevelManager.new_run()
