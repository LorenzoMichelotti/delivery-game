extends Node

@onready var gas_bar_backdrop: Panel
@onready var gas_bar: Panel
@onready var gas_label: Label
@onready var points_label: Label
@onready var pawn: Node2D
@onready var pawn_spawn_position: Vector2 = Vector2(4, -5)
@onready var gps_scene: PackedScene = preload("res://ui/gps.tscn")
@onready var gps_arrow: Node2D

var max_gas = 100
var current_gas = 100
var initial_gas_usage = 5
var gas_usage = 0
var points = 0
var inventory_delivery_ids: Array[int] = []

func _ready():
	gas_bar_backdrop = get_tree().current_scene.get_node("CanvasLayer/Control/GasBarContainer")
	gas_bar = get_tree().current_scene.get_node("CanvasLayer/Control/GasBarContainer/GasBar")
	gas_label = get_tree().current_scene.get_node("CanvasLayer/Control/GasBarContainer/GasLabel")
	points_label = get_tree().current_scene.get_node("CanvasLayer/Control/PointsControl/Points")
	pawn = get_tree().current_scene.get_node("Player")
	gps_arrow = gps_scene.instantiate()
	pawn.add_child.call_deferred(gps_arrow)
	gas_usage = initial_gas_usage

func _process(delta):
	if GameManager.current_game_mode != GameManager.GAMEMODE.PLAYING:
		return
	
	if gps_arrow and inventory_delivery_ids.size() <= 0:
		var closest_pickup_position = GameManager.get_closest_pickup_position(pawn.global_position)
		if closest_pickup_position != null:
			gps_arrow.look_at(closest_pickup_position)
	elif gps_arrow and inventory_delivery_ids.size() > 0:
		var closest_delivery_position = GameManager.get_closest_delivery_position(pawn.global_position, inventory_delivery_ids)
		if closest_delivery_position != null:
			gps_arrow.look_at(closest_delivery_position)
	
	use_gas(delta)

func calculate_gps_arrow_direction():
	pass

func update_gas_bar():
	gas_bar.scale.x = gas_bar_backdrop.scale.x * current_gas / max_gas
	gas_label.text = str(roundi(current_gas))

func use_gas(delta):
	if current_gas - 1 <= 0:
		return empty_tank()
	current_gas -= gas_usage * delta
	gas_usage += 5 * delta/10
	update_gas_bar()

func add_gas(amount):
	if current_gas + amount > max_gas:
		current_gas = max_gas
		return
	current_gas += amount
	update_gas_bar()

func empty_tank():
	current_gas = 0
	update_gas_bar()
	GameManager.set_game_mode(GameManager.GAMEMODE.GAMEOVER)

func reset_player():
	pawn.current_direction = Vector2.ZERO
	pawn.target_position = pawn_spawn_position
	pawn.global_position = pawn_spawn_position
	pawn.input_queue.clear()
	inventory_delivery_ids.clear()
	gas_usage = initial_gas_usage
	current_gas = max_gas
	points = 0
	update_points_label(points)
	update_gas_bar()
	GameManager.set_game_mode(GameManager.GAMEMODE.PLAYING)
	
func add_points(amount):
	var previous_points = points
	points += amount
	var points_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	points_tween.set_loops(1).tween_method(update_points_label, previous_points, points, .5)
	points_tween.finished.connect(points_tween.kill)
	
	var loop_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_SPRING)
	loop_tween.set_loops(5).tween_property(points_label, "scale", Vector2(1.1, 1.1), .01)
	loop_tween.tween_property(points_label, "scale", Vector2(1, 1), .1)
	loop_tween.finished.connect(points_tween.kill)

func update_points_label(points: int):
	points_label.text = str(points).pad_zeros(10)
	
