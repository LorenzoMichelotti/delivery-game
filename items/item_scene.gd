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
		
@onready var area2d := $Area2D
@onready var sprite_pivot := $SpritePivot
@onready var sprite := $SpritePivot/Sprite2D
@onready var item_balloon := $SpritePivot/ItemBalloon


var tile_position: Vector2i
var road: TileMapLayer

func _ready():
	$AnimationPlayer.play("idle")
	sprite.modulate = color
	area2d.connect("body_entered", _on_area_2d_body_entered)
	
	if item is DeliveryTargetItem:
		item_balloon.update_item_balloon(false, GameManager.deliveries[item.delivery_id].item.item.animation_frame, GameManager.deliveries[item.delivery_id].item.item.texture, GameManager.deliveries[item.delivery_id].item.item.is_animated_sprite)

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		item.on_pickup(self)

func _exit_tree():
	road.get_cell_tile_data(tile_position).set_custom_data("occupied", false)
