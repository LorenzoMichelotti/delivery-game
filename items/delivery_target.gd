class_name DeliveryTargetItem
extends Item

var points = 10000
var ready_sign
var delivery_id: int

func on_pickup(item_scene: ItemScene):
	if GameManager.can_deliver_item(delivery_id):
		print("delivering pickup")
		var tween: Tween = GameManager.get_tree().create_tween().bind_node(item_scene)
		VfxManager.display_number(str(points), item_scene.global_position)
		VfxManager.display_pickup_effect(item_scene.global_position)
		SfxManager.play_sfx(pickup_sfx, SfxManager.CHANNEL_CONFIG.BASIC, true)
		PlayerManager.inventory_complete_delivery(delivery_id)
		GameManager.deliver_item(delivery_id)
		PlayerManager.add_points(points)
		print("pickup delivered")
		tween.tween_property(item_scene, "scale", Vector2.ZERO, .2)
		print("delivery complete")
		tween.finished.connect(item_scene.queue_free)

func on_delivery_item_picked_up(item_scene: ItemScene):
	item_scene.item_balloon.balloon_sprite.modulate = Color.GREEN_YELLOW
	item_scene.item_balloon.sprite_pivot.scale = Vector2.ONE * 1.2

func on_free():
	PlayerManager.inventory_complete_delivery(delivery_id)
	GameManager.deliveries.erase(delivery_id)
