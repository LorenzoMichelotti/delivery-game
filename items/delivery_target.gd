class_name DeliveryTargetItem
extends Item

var points = 10000
var ready_sign
var delivery_id: int

func on_pickup(item_scene: ItemScene):
	if EntityManager.can_deliver_item(delivery_id):
		print("delivering pickup")
		SfxManager.play_sfx(pickup_sfx, SfxManager.CHANNEL_CONFIG.VOICES)
		var tween: Tween = GameManager.get_tree().create_tween().bind_node(item_scene)
		VfxManager.display_number(str(points * PlayerManager.point_multiplier), item_scene.global_position)
		print("delivered")
		VfxManager.display_delivery_effect(item_scene.global_position)
		PlayerManager.inventory_complete_delivery(delivery_id)
		PlayerManager.add_points(points)
		EntityManager.deliver_item(delivery_id)
		print("pickup delivered")
		tween.tween_property(item_scene, "scale", Vector2.ZERO, .2)
		print("delivery complete")
		tween.finished.connect(item_scene.queue_free.call_deferred)

func on_delivery_item_picked_up(item_scene: ItemScene):
	item_scene.item_balloon.balloon_sprite.modulate = Color.GREEN_YELLOW
	item_scene.item_balloon.sprite_pivot.scale = Vector2.ONE * 1.2

func on_free():
	EntityManager.erase_delivery_item(delivery_id)
