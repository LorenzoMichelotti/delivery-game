extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var item_sprite = $SpritePivot/ItemSprite
@onready var balloon_sprite = $SpritePivot/BalloonSprite
@onready var sprite_pivot = $SpritePivot

func _ready():
	hide()

func update_item_balloon(hide: bool, animation_frame: int = 0, texture: Texture2D = null, is_animated: bool = true):
	if hide:
		anim_player.play("dissappear")
		return
	item_sprite.texture = texture
	anim_player.play("appear")
	if is_animated:
		item_sprite.hframes = 8
		item_sprite.vframes = 8
		item_sprite.frame = animation_frame
	else:
		item_sprite.hframes = 1
		item_sprite.vframes = 1
