class_name ItemScene
extends Node2D

@export var color: Color = Color.WHITE
@export var item: Item:
	set(new_item):
		item = new_item
		$SpritePivot/Sprite2D.texture = item.texture
		if item.is_animated_sprite:
			$SpritePivot/Sprite2D.hframes = item.h_animation_grid_size
			$SpritePivot/Sprite2D.vframes = item.v_animation_grid_size
			$SpritePivot/Sprite2D.frame = item.animation_frame
		else:
			$SpritePivot/Sprite2D.hframes = 1
			$SpritePivot/Sprite2D.vframes = 1
			scale = Vector2(item.sprite_size, item.sprite_size)
		
@onready var area2d: Area2D = $Area2D
@onready var sprite_pivot := $SpritePivot
@onready var sprite := $SpritePivot/Sprite2D
@onready var item_balloon := $ItemBalloon

const ITEM = preload("res://items/item.tscn")

var player_in_range = false
var can_be_picked_up: bool = true

func _ready():
	if not can_be_picked_up:
		set_cant_be_picked_up()
	$AnimationPlayer.play("idle")
	sprite.modulate = color
	area2d.connect("body_entered", _on_area_2d_body_entered)
	area2d.connect("body_exited", _on_area_2d_body_entered)
	
	if item is DeliveryTargetItem:
		item_balloon.update_item_balloon.call_deferred(false, EntityManager.deliveries[item.delivery_id].item.item.animation_frame, EntityManager.deliveries[item.delivery_id].item.item.texture, EntityManager.deliveries[item.delivery_id].item.item.is_animated_sprite)

func _process(delta):
	if player_in_range:
		item.on_pickup(self)

func set_cant_be_picked_up():
	can_be_picked_up = false
	if is_instance_valid(area2d):
		area2d.set_deferred("monitoring", false)
		area2d.set_deferred("monitorable", false)
	
	var tween = create_tween()
	await tween.tween_property(self, "scale", Vector2.ZERO, 0.3).finished
	tween.kill()
	hide()
	return

func set_can_be_picked_up():
	can_be_picked_up = true
	if is_instance_valid(area2d):
		area2d.set_deferred("monitoring", true)
		area2d.set_deferred("monitorable", true)
		
	show()
	var tween = create_tween()
	await tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.3).finished
	tween.kill()
	scale = Vector2.ONE * 1.2
	
	for area in area2d.get_overlapping_areas():
		if area.is_in_group("hit_box") and area.get_parent().actor.is_in_group("player"):
			item.on_pickup(self)
	
	return

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_in_range = true
	
func _on_area_2d_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_in_range = false

#region constructors

static func new_delivery_target(resource: Item, position: Vector2, delivery_id: int) -> ItemScene:
	var new_item: ItemScene = ITEM.instantiate()
	new_item.item = resource.duplicate()
	new_item.item.delivery_id = delivery_id
	new_item.item = new_item.item
	new_item.global_position = position
	new_item.color = LevelManager.current_completion_requirements.client.color
	return new_item


static func new_delivery_pickupable(resource: Item, position: Vector2, delivery_id: int, target: ItemScene) -> ItemScene:
	var new_item: ItemScene = ITEM.instantiate()
	new_item.item = resource.duplicate()
	new_item.item.texture = LevelManager.current_completion_requirements.client.objects.pick_random()
	new_item.item.delivery_id = delivery_id
	new_item.item = new_item.item
	new_item.item.picked_up.connect(target.item.on_delivery_item_picked_up.bind(target))
	new_item.global_position = position
	return new_item

#endregion
