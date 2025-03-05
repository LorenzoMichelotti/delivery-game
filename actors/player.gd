extends Actor

@export var player_lose_life_stream_sfx : AudioStreamWAV = preload("res://assets/sounds/Life_Lose.wav")
@export var player_die_stream_sfx : AudioStreamWAV = preload("res://assets/sounds/Player_Died.wav")
@onready var item_balloon = $ItemBalloon
@onready var controller: PlayerControllerModule = $PlayerControllerModule

func _ready():
	PlayerManager.inventory_delivery_ids_changed.connect(item_balloon.update_item_balloon)

func _on_take_damage():
	CameraManager.apply_quick_zoom()
	SfxManager.play_sfx(player_lose_life_stream_sfx, SfxManager.CHANNEL_CONFIG.VOICES, false, 0.4)

func _on_die():
	SfxManager.play_sfx(player_die_stream_sfx, SfxManager.CHANNEL_CONFIG.VOICES, false, 0.4)
