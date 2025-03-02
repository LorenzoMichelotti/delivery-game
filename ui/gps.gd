extends Node2D

@export var cross_hair_activation_distance = 50
@export var enabled = true
@onready var animation_tree = $AnimationTree
@onready var distance_label = $Label
@onready var sprite = $Pivot/Sprite2D

var arrow_frame = 54
var cross_hair_frame = 58

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enabled: use_gps_arrow()
	distance_label.global_position = Vector2(sprite.global_position.x -2, sprite.global_position.y + 4)

func use_gps_arrow():
	if !visible:
		show()
	if PlayerManager.inventory_delivery_ids.size() <= 0:
		var closest_pickup_position = GameManager.get_closest_pickup_position(get_parent().global_position)
		if closest_pickup_position != null:
			var distance = get_parent().global_position.distance_to(closest_pickup_position)
			if distance < cross_hair_activation_distance:
				$CrossHair.global_position = lerp($CrossHair.global_position, closest_pickup_position, get_process_delta_time() * 40)
				animation_tree.set("parameters/conditions/disappear", true)
				animation_tree.set("parameters/conditions/appear", false)
			else:
				animation_tree.set("parameters/conditions/disappear", false)
				animation_tree.set("parameters/conditions/appear", true)
				distance_label.text = str(roundi(distance)).pad_zeros(2) + "m"
				$Pivot.rotation = lerp_angle($Pivot.rotation, global_position.angle_to_point(closest_pickup_position), get_process_delta_time() * 5)
	elif PlayerManager.inventory_delivery_ids.size() > 0:
		var closest_delivery_position = GameManager.get_closest_delivery_position(get_parent().global_position, PlayerManager.inventory_delivery_ids)
		if closest_delivery_position != null:
			var distance = get_parent().global_position.distance_to(closest_delivery_position)
			if distance < cross_hair_activation_distance:
				$CrossHair.global_position = lerp($CrossHair.global_position, closest_delivery_position, get_process_delta_time() * 40)
				animation_tree.set("parameters/conditions/disappear", true)
				animation_tree.set("parameters/conditions/appear", false)
			else:
				animation_tree.set("parameters/conditions/disappear", false)
				animation_tree.set("parameters/conditions/appear", true)
				distance_label.text = str(roundi(distance)).pad_zeros(2) + "m"
				$Pivot.rotation = lerp_angle($Pivot.rotation, global_position.angle_to_point(closest_delivery_position), get_process_delta_time() * 5)
