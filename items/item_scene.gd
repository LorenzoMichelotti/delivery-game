class_name ItemScene
extends Node2D

@export var item: Item:
	set(new_item):
		item = new_item
		$SpritePivot/Sprite2D.frame = item.animation_frame
		
@onready var area2d := $Area2D
@onready var sprite_pivot := $SpritePivot
@onready var sprite := $SpritePivot/Sprite2D

var tile_position: Vector2i
var road: TileMapLayer

func _ready():
	area2d.connect("body_entered", _on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		item.on_pickup(self)

func _exit_tree():
	road.get_cell_tile_data(tile_position).set_custom_data("occupied", false)
