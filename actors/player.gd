extends Actor

@export var player_lose_life_stream_sfx : AudioStreamWAV = preload("res://assets/sounds/Life_Lose.wav")
@export var player_die_stream_sfx : AudioStreamWAV = preload("res://assets/sounds/Player_Died.wav")
@onready var item_balloon = $ItemBalloon
@onready var controller: PlayerPathfindingControllerModule = $PlayerControllerModule

func _ready():
	PlayerManager.set_pawn(self)
	PlayerManager.inventory_delivery_ids_changed.connect(item_balloon.update_item_balloon)

func _on_take_damage():
	CameraManager.apply_quick_zoom()
	SfxManager.play_sfx(player_lose_life_stream_sfx, SfxManager.CHANNEL_CONFIG.VOICES, false, 0.4)
	PlayerManager.end_combo()

func _on_die():
	SfxManager.play_sfx(player_die_stream_sfx, SfxManager.CHANNEL_CONFIG.VOICES, false, 0.4)

func _process(delta):
	_update_animation(velocity.normalized())

func _update_animation(direction):
	if direction.x > 0.5 or direction.x < -0.5 :
		sprite.flip_h = direction.x < 0
		sprite.frame = 3
		shadow.rotation_degrees = 0
		shadow.position.y = 0
	elif direction.y > 0.5:
		sprite.frame = 5
		shadow.rotation_degrees = 90
		shadow.position.y = -1
	elif direction.y < -0.5:
		sprite.frame = 4
		shadow.rotation_degrees = 90
		shadow.position.y = -1
	var tween: Tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "scale", Vector2(1.2 if abs(direction.x) > 0.5 else 1, 1.2 if abs(direction.y) > 0.5 else 1), 0.1)
	tween.finished.connect(tween.kill)
