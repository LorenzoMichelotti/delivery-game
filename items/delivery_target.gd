class_name DeliveryTargetItem
extends Item

var points = 1000
var ready_sign
var delivery_id: int

func _init():
	animation_frame = 19

func on_pickup(item_scene: ItemScene):
	if GameManager.can_deliver_item(delivery_id):
		var tween: Tween = GameManager.get_tree().create_tween().bind_node(item_scene)
		VfxManager.display_number("1000", item_scene.global_position)
		PlayerManager.inventory_delivery_ids.erase(delivery_id)
		PlayerManager.add_points(points)
		tween.tween_property(item_scene, "scale", Vector2.ZERO, .2)
		tween.finished.connect(item_scene.queue_free)

func on_delivery_item_picked_up(item_scene: ItemScene):
	if ready_sign:
		return
	ready_sign = preload("res://ui/ready_sign.tscn").instantiate()
	ready_sign.position.y -= 8
	item_scene.add_child.call_deferred(ready_sign)
	
