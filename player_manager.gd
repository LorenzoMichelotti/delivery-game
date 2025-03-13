extends Node

@onready var gas_bar_backdrop: Panel
@onready var gas_bar: Panel
@onready var gas_label: Label
@onready var points_label: Label
@onready var pawn: Actor
@onready var pawn_spawn_position: Vector2
@onready var gps_scene: PackedScene = preload("res://ui/gps.tscn")
@onready var gps_arrow: Node2D

var max_gas = 100
var current_gas = 100
var initial_gas_usage = 10
var gas_usage = 0
var max_hp = 3
var current_hp = 3

var points: int = 0:
	set(new_points):
		points = new_points
		points_changed.emit(points)
signal points_changed(points: int)

var current_level_points: int = 0

var point_multiplier = 1:
	set(new_point_multiplier):
		point_multiplier = new_point_multiplier
		point_multiplier_changed.emit(point_multiplier)
signal point_multiplier_changed(point_multiplier: int)

var base_point_multiplier = 1
var base_multiplier_timer = 5
var multiplier_timer = 5

var completed_deliveries = 0
var inventory_delivery_ids: Array[int] = []
var gps_enabled = true

var gas_enabled = true:
	set(value): 
		gas_enabled = value
		gas_enabled_changed.emit(gas_enabled)
signal gas_enabled_changed(enabled: bool)

var player_is_ready = false
var tank_empty = false
var timer: Timer

signal inventory_delivery_ids_changed(hide: bool, animation_frame: int, texture: Texture2D, is_animated: bool)

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(end_combo)
	add_child(timer)

func inventory_hold_delivery(delivery_id):
	inventory_delivery_ids.append(delivery_id)
	inventory_delivery_ids_changed.emit(false, EntityManager.deliveries[delivery_id].item.item.animation_frame, EntityManager.deliveries[delivery_id].item.item.texture, EntityManager.deliveries[delivery_id].item.item.is_animated_sprite)

func inventory_complete_delivery(delivery_id):
	if gas_enabled:
		if gas_usage - 1 >= 0:
			gas_usage -= 1
		else:
			gas_usage = 0
	completed_deliveries += 1
	increase_combo()
	inventory_delivery_ids.erase(delivery_id)
	inventory_delivery_ids_changed.emit(true)

func increase_combo():
	timer.stop()
	point_multiplier += 1
	var multiplier_timer_discount = (point_multiplier % 2) - 1
	if multiplier_timer_discount >= 0:
		multiplier_timer -= multiplier_timer_discount 
	timer.start()
	
func end_combo():
	point_multiplier = base_point_multiplier
	multiplier_timer = base_multiplier_timer

func on_level_changed():
	player_is_ready = false
	gas_bar_backdrop = get_tree().current_scene.get_node("CanvasLayer/LevelUI/Panel/GasBarContainer")
	gas_bar = get_tree().current_scene.get_node("CanvasLayer/LevelUI/Panel/GasBarContainer/GasBar")
	gas_label = get_tree().current_scene.get_node("CanvasLayer/LevelUI/Panel/GasBarContainer/GasLabel")
	points_label = get_tree().current_scene.get_node("CanvasLayer/LevelUI/PointsControl/Points")
	gas_usage = initial_gas_usage
	
	reset_player()
	player_is_ready = true

func set_curent_pawn(new_pawn):
	if new_pawn == null:
		new_pawn = get_tree().current_scene.get_node("Map/Entities/Player")
	pawn = new_pawn
	pawn.alive_module.max_hp = max_hp
	pawn.alive_module.hp = current_hp
	pawn.alive_module.took_damage.connect(func(damage): current_hp -= damage)
	CameraManager.set_pawn_to_follow(pawn)
	pawn_spawn_position = pawn.global_position
	pawn.alive_module.died.connect(empty_tank)

func _process(delta):
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
	
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
	var current_scene = get_tree().current_scene
	if current_scene.gameover_cutscene != null:
		CutsceneManager.cutscene_player.play.call_deferred(current_scene.gameover_cutscene, current_scene.game_ui)
		return 
	GameManager.set_game_mode(GameManager.GAMEMODE.GAMEOVER)

func reset_player(hard = false):
	pawn.controller.current_direction = Vector2.ZERO
	pawn.controller.target_position = pawn_spawn_position
	pawn.global_position = pawn_spawn_position
	
	inventory_delivery_ids.clear()
	
	if hard: # hard reset
		current_hp = max_hp
		points = 0
	
	current_level_points = 0
	gas_enabled = true
	gas_usage = initial_gas_usage
	current_gas = max_gas
	tank_empty = false
	
	completed_deliveries = 0
	update_points_label(points)
	update_gas_bar()
	
func add_points(amount):
	if tank_empty:
		return
		
	var previous_points = points
	current_level_points += amount * point_multiplier
	points += amount * point_multiplier
	LevelManager.verify_level_win_condition()
	
	var points_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	points_tween.set_loops(1).tween_method(update_points_label, previous_points, points, .5)
	points_tween.finished.connect(points_tween.kill)
	
	var loop_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_SPRING)
	loop_tween.set_loops(5).tween_property(points_label, "scale", Vector2(1.1, 1.1), .01)
	loop_tween.tween_property(points_label, "scale", Vector2(1, 1), .1)
	loop_tween.finished.connect(points_tween.kill)

func update_points_label(new_points: int):
	points_label.text = str(new_points).pad_zeros(10)
	
