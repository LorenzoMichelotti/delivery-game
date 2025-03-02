extends Sprite2D

@onready var anim_player = $AnimationPlayer
@onready var item_sprite = $ItemSprite

func _ready():
	modulate.a = 0

func update_item_balloon(hide: bool, animation_frame: int = 0, texture: Texture2D = null, is_animated: bool = true):
	if hide:
		anim_player.play("dissappear")
		return
	anim_player.play("appear")
	item_sprite.texture = texture
	if is_animated:
		item_sprite.hframes = 8
		item_sprite.vframes = 8
		item_sprite.frame = animation_frame
	else:
		item_sprite.hframes = 1
		item_sprite.vframes = 1
