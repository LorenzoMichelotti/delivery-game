extends Node2D

const MAX_VFX = 10

var explosion_pool: Array = []
var pickup_pool: Array[CPUParticles2D] = []
var delivery_pool: Array[CPUParticles2D] = []
var number_pool: Array[Label] = []
@onready var canvas_layer: CanvasLayer
@onready var floating_text_scene = preload("res://floating_text/floating_text.tscn")
@onready var pickup_scene: PackedScene = preload("res://vfx/pickup_vfx.tscn")
@onready var delivery_scene: PackedScene = preload("res://vfx/delivery_vfx.tscn")
@onready var explosion_scene: PackedScene = preload("res://vfx/explosion_vfx.tscn")

func _ready():
	for i in range(MAX_VFX):
		number_pool.append(null)
	for i in range(MAX_VFX):
		explosion_pool.append(null)
	for i in range(2):
		pickup_pool.append(null)
	for i in range(2):
		delivery_pool.append(null)

func display_pickup_effect(new_position: Vector2):
	for i in len(pickup_pool):
		if pickup_pool[i] == null:
			pickup_pool[i] = pickup_scene.instantiate()
			get_tree().current_scene.add_child.call_deferred(pickup_pool[i])
		if not pickup_pool[i].emitting:
			pickup_pool[i].global_position = new_position
			pickup_pool[i].emitting = true
			return
			
func display_delivery_effect(new_position: Vector2):
	for i in len(delivery_pool):
		if delivery_pool[i] == null:
			delivery_pool[i] = delivery_scene.instantiate()
			get_tree().current_scene.add_child.call_deferred(delivery_pool[i])
		if not delivery_pool[i].emitting:
			delivery_pool[i].global_position = new_position
			delivery_pool[i].emitting = true
			return

func display_explosion_effect(new_position: Vector2):
	for i in len(explosion_pool):
		if explosion_pool[i] == null:
			explosion_pool[i] = explosion_scene.instantiate()
			get_tree().current_scene.add_child(explosion_pool[i])
		if not explosion_pool[i].emitting:
			explosion_pool[i].global_position = new_position
			explosion_pool[i].emitting = true
			return
		
func display_number(text: String, new_position: Vector2, color: Color = Color.WHITE):
	for i in len(number_pool):
		if number_pool[i] == null:
			number_pool[i] = floating_text_scene.instantiate()
			add_child.call_deferred(number_pool[i])
			number_pool[i].hide()
		if not number_pool[i].visible:
			number_pool[i].global_position = new_position 
			number_pool[i].global_position.y -= 8 
			number_pool[i].modulate = color 
			number_pool[i].set_text(text)  # Set the text value
			number_pool[i].animate()
			return
			
