extends Actor
class_name Npc

@export var texture = preload("res://assets/cars/police_car.png"):
	set(t):
		texture = t
		$SpritePivot/Sprite2D.texture = t

@onready var random_movement_module = $RandomMovementModule
@onready var item_balloon = $ItemBalloon

var delivery_id: int = -1:
	set(new_delivery_id):
		if new_delivery_id != -1:
			delivery_id = new_delivery_id
			item_balloon.update_item_balloon.call_deferred(false, EntityManager.deliveries[delivery_id].item.item.animation_frame, EntityManager.deliveries[delivery_id].item.item.texture, EntityManager.deliveries[delivery_id].item.item.is_animated_sprite)
			alive_module.died.connect(_on_death)
signal inventory_delivery_ids_changed(hide: bool, animation_frame: int, texture: Texture2D, is_animated: bool)

func _ready():
	if delivery_id != -1:
		item_balloon.update_item_balloon.call_deferred(false, EntityManager.deliveries[delivery_id].item.item.animation_frame, EntityManager.deliveries[delivery_id].item.item.texture, EntityManager.deliveries[delivery_id].item.item.is_animated_sprite)
		alive_module.died.connect(_on_death)

func _on_death():
	print("npc died, dropping the delivery_id -> ", delivery_id)
	item_balloon.update_item_balloon.call_deferred(true)
	EntityManager.deliveries[delivery_id].item.set_can_be_picked_up()

func _process(delta):
	update_animation(velocity.normalized())
	if delivery_id != -1 and EntityManager.deliveries.has(delivery_id) and is_instance_valid(EntityManager.deliveries[delivery_id].item):
		EntityManager.deliveries[delivery_id].item.global_position = global_position

func update_animation(dir: Vector2):
	if abs(dir.x) > 0.5:
		sprite.flip_h = dir.x < 0
		sprite.frame = 0
		shadow.rotation_degrees = 0
		shadow.position.y = 0
	elif dir.y > 0.5:
		sprite.frame = 2
		shadow.rotation_degrees = 90
		shadow.position.y = -1
	else:
		sprite.frame = 1
		shadow.rotation_degrees = 90
		shadow.position.y = -1

	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(sprite, "scale", Vector2(1.2 if abs(dir.x) > 0.5 else 1, 1.2 if abs(dir.y) > 0.5 else 1), 0.1)
	tween.finished.connect(tween.kill)
