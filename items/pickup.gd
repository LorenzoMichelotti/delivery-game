class_name PickupItem
extends Item

var delivery_id: int
var was_picked_up = false
signal picked_up

func on_pickup(item_scene: ItemScene):
	if was_picked_up:
		return
	was_picked_up = true
	EntityManager.pickup_delivery_item(delivery_id)
	SfxManager.play_sfx(pickup_sfx, SfxManager.CHANNEL_CONFIG.BASIC)
	print("pickedup")
	VfxManager.display_pickup_effect(item_scene.global_position)
	PlayerManager.inventory_hold_delivery(delivery_id)
	picked_up.emit()
	var tween: Tween = GameManager.get_tree().create_tween().bind_node(item_scene)
	tween.tween_property(item_scene.sprite_pivot, "scale", Vector2.ZERO, .2)
	tween.finished.connect(item_scene.queue_free.call_deferred)
