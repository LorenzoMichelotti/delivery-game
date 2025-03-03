class_name Item
extends Resource

@export var consumable: bool = false
@export var animation_frame: int
@export var h_animation_grid_size: int = 8
@export var v_animation_grid_size: int = 8
@export var sprite_size: float = 1
@export var is_animated_sprite: bool = true
@export var texture: Texture2D = preload("res://assets/city_tileset_8x8.png")
@export var pickup_sfx: AudioStreamWAV = preload("res://assets/sounds/Pickup.wav")

func on_pickup(item_scene: ItemScene):
	pass

func on_free():
	pass
