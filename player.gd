extends CharacterBody2D

@onready var sprite = $SpritePivot/Sprite2D
@onready var item_balloon = $ItemBalloon
@onready var controller: PlayerControllerModule = $PlayerControllerModule

func _ready():
	PlayerManager.inventory_delivery_ids_changed.connect(item_balloon.update_item_balloon)
