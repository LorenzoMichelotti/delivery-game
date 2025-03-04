extends CharacterBody2D

@onready var sprite = $SpritePivot/Sprite2D
@onready var sprite_pivot = $SpritePivot
@onready var item_balloon = $ItemBalloon
@onready var controller: PlayerControllerModule = $PlayerControllerModule
@onready var alive_module: AliveModule = $AliveModule

func _ready():
	PlayerManager.inventory_delivery_ids_changed.connect(item_balloon.update_item_balloon)
