extends Node2D

const MAX_VFX = 10

var pickup_pool: Array[CPUParticles2D] = []
var number_pool: Array[Node2D] = []
@onready var canvas_layer: CanvasLayer
@onready var floating_text_scene: PackedScene = preload("res://floating_text/floating_text.tscn")
@onready var pickup_scene: PackedScene = preload("res://vfx/pickup_vfx.tscn")

func _ready():
	for i in range(MAX_VFX):
		number_pool.append(null)
	for i in range(MAX_VFX):
		pickup_pool.append(null)

func display_pickup_effect(position: Vector2):
	for i in len(pickup_pool):
		if pickup_pool[i] == null:
			pickup_pool[i] = pickup_scene.instantiate()
			get_tree().current_scene.add_child.call_deferred(pickup_pool[i])
		if not pickup_pool[i].emitting:
			pickup_pool[i].global_position = position
			pickup_pool[i].emitting = true
			return
		
func display_number(text: String, position: Vector2):
	if !canvas_layer:
		canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
	for i in len(number_pool):
		if number_pool[i] == null:
			number_pool[i] = floating_text_scene.instantiate()
			number_pool[i].hide()
			canvas_layer.add_child.call_deferred(number_pool[i])
		if not number_pool[i].visible:
			var root = get_tree().root
			number_pool[i].global_position = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * position 
			number_pool[i].global_position.y -= 8 
			number_pool[i].set_text(text)  # Set the text value
			number_pool[i].show()
			number_pool[i].animate()
			return
			

func display_numbers(numbers, position: Vector2 ):
	if !canvas_layer:
		canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
	var initial_offset = -50 * numbers.size()
	var y_offset = 0
	for number in numbers:
		for i in len(number_pool):
			if number_pool[i] == null:
				number_pool[i] = floating_text_scene.instantiate()
				number_pool[i].hide()
				canvas_layer.add_child.call_deferred(number_pool[i])
			if not number_pool[i].visible:
				number_pool[i].global_position = Vector2(position.x, position.y + initial_offset + y_offset)
				number_pool[i].label.modulate = GameManager.DAMAGE_TYPE_COLORS[number.damage_type]
				number_pool[i].set_text(number.text)  # Set the text value
				number_pool[i].show()
				number_pool[i].animate()
				y_offset += 50
				break
		await get_tree().create_timer(.1).timeout
