extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var balloon_sprite = $SpritePivot/BalloonSprite
@onready var sprite_pivot = $SpritePivot
@onready var nine_rect_balloon = $SpritePivot/BalloonSprite/NineRectBalloon

@onready var item_sprites = [
	$SpritePivot/ItemContainer/ItemSprite,
	$SpritePivot/ItemContainer/ItemSprite2,
	$SpritePivot/ItemContainer/ItemSprite4
]

func _ready():
	hide()

const base_nine_rect_x_width = 10
var item_textures = []

func update_item_balloon(should_hide: bool, animation_frame: int = 0, texture: Texture2D = null, is_animated: bool = true):
	if should_hide:
		item_textures.clear()
		for item_sprite in item_sprites:
			item_sprite.texture = null
		anim_player.play("dissappear")
		return
		
	nine_rect_balloon.size.x = base_nine_rect_x_width + ((8 * (item_textures.size() - 1)) if item_textures.size() > 1 else 0)
	item_textures.append(texture)
	
	for i in range(item_textures.size()):
		item_sprites[i].texture = item_textures[i]
	
	anim_player.play("appear")
