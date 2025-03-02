class_name Item
extends Resource

@export var consumable: bool = false
@export var animation_frame: int

func on_pickup(item_scene: ItemScene):
	pass

func on_free():
	pass
