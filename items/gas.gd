class_name FuelItem
extends Item

@export var gas_amount = 20

func on_pickup(item_scene: ItemScene):
	PlayerManager.add_gas(gas_amount)
	VfxManager.display_pickup_effect(item_scene.global_position)
	var tween: Tween = GameManager.get_tree().create_tween().bind_node(item_scene)
	tween.tween_property(item_scene.sprite_pivot, "scale", Vector2.ZERO, .2)
	tween.finished.connect(item_scene.queue_free)
