extends Node

@onready var gas_bar_backdrop: Panel
@onready var gas_bar: Panel
@onready var gas_label: Label
@onready var points_label: Label
@onready var pawn: Node2D
@onready var pawn_spawn_position: Vector2
@onready var gps_scene: PackedScene = preload("res://ui/gps.tscn")
@onready var gps_arrow: Node2D

var max_gas = 100
var current_gas = 100
var initial_gas_usage = 10
var gas_usage = 0

var points = 0
var completed_deliveries = 0
var inventory_delivery_ids: Array[int] = []
var gps_enabled = true
var gas_enabled = true
var player_is_ready = false
var tank_empty = false
var success = false

signal inventory_delivery_ids_changed(hide: bool, animation_frame: int, texture: Texture2D, is_animated: bool)

func inventory_hold_delivery(delivery_id):
	inventory_delivery_ids.append(delivery_id)
	inventory_delivery_ids_changed.emit(false, GameManager.deliveries[delivery_id].item.item.animation_frame, GameManager.deliveries[delivery_id].item.item.texture, GameManager.deliveries[delivery_id].item.item.is_animated_sprite)

func inventory_complete_delivery(delivery_id):
	if gas_enabled:
		if gas_usage - 1 >= 0:
			gas_usage -= 1
		else:
			gas_usage = 0
	completed_deliveries += 1
	inventory_delivery_ids.erase(delivery_id)
	inventory_delivery_ids_changed.emit(true)
	if not GameManager.endless and GameManager.verify_level_win_condition():
		complete_level()

func on_level_changed():
	player_is_ready = false
	gas_bar_backdrop = get_tree().current_scene.get_node("CanvasLayer/LevelUI/Panel/GasBarContainer")
	gas_bar = get_tree().current_scene.get_node("CanvasLayer/LevelUI/Panel/GasBarContainer/GasBar")
	gas_label = get_tree().current_scene.get_node("CanvasLayer/LevelUI/Panel/GasBarContainer/GasLabel")
	points_label = get_tree().current_scene.get_node("CanvasLayer/LevelUI/PointsControl/Points")
	pawn = get_tree().current_scene.get_node("Entities/Player")
	CameraManager.set_pawn_to_follow(pawn)
	pawn_spawn_position = pawn.global_position
	pawn.alive_module.died.connect(empty_tank)
	gas_usage = initial_gas_usage
	
	reset_player()
	player_is_ready = true

func _process(delta):
	if !player_is_ready || GameManager.is_game_paused():
		return
	
	if gas_enabled: use_gas(delta)

func bump_gps_arrow():
	var tween = get_tree().create_tween()
	tween.finished.connect(tween.kill)

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
	if tank_empty:
		return
	tank_empty = true
	current_gas = 0
	update_gas_bar()
	complete_level()

func complete_level():
	if success:
		return
	success = GameManager.verify_level_win_condition()
	var current_scene = get_tree().current_scene
	if not success and current_scene.gameover_cutscene != null:
		CutsceneManager.cutscene_player.play.call_deferred(current_scene.gameover_cutscene, current_scene.game_ui)
		return 
	if success and current_scene.success_cutscene != null:
		CutsceneManager.cutscene_player.play.call_deferred(current_scene.success_cutscene, current_scene.game_ui)
		return 
	GameManager.set_game_mode(GameManager.GAMEMODE.GAMEOVER)

func reset_player():
	pawn.controller.current_direction = Vector2.ZERO
	pawn.controller.target_position = pawn_spawn_position
	pawn.global_position = pawn_spawn_position
	pawn.controller.input_queue.clear()
	inventory_delivery_ids.clear()
	
	gas_enabled = true
	gas_usage = initial_gas_usage
	current_gas = max_gas
	tank_empty = false
	
	points = 0
	completed_deliveries = 0
	success = false
	update_points_label(points)
	update_gas_bar()
	
func add_points(amount):
	if tank_empty:
		return 
		
	var previous_points = points
	points += amount
	
	if not GameManager.endless and GameManager.verify_level_win_condition():
		empty_tank()
	
	var points_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	points_tween.set_loops(1).tween_method(update_points_label, previous_points, points, .5)
	points_tween.finished.connect(points_tween.kill)
	
	var loop_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_SPRING)
	loop_tween.set_loops(5).tween_property(points_label, "scale", Vector2(1.1, 1.1), .01)
	loop_tween.tween_property(points_label, "scale", Vector2(1, 1), .1)
	loop_tween.finished.connect(points_tween.kill)

func update_points_label(points: int):
	points_label.text = str(points).pad_zeros(10)
	
