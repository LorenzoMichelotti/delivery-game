extends Actor

@export var texture = preload("res://assets/cars/police_car.png"):
	set(t):
		texture = t
		$SpritePivot/Sprite2D.texture = t

@onready var random_movement_module = $RandomMovementModule
@onready var item_balloon = $ItemBalloon

var delivery_id: int = -1
signal inventory_delivery_ids_changed(hide: bool, animation_frame: int, texture: Texture2D, is_animated: bool)

func _ready():
	if delivery_id != -1:
		item_balloon.update_item_balloon(false, GameManager.level_deliveries[delivery_id].item.item.animation_frame, GameManager.level_deliveries[delivery_id].item.item.texture, GameManager.level_deliveries[delivery_id].item.item.is_animated_sprite)
		alive_module.died.connect(_on_death)

func _on_death():
	print("npc died, dropping the delivery_id -> ", delivery_id)
	

func _process(delta):
	update_animation(velocity.normalized())

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
