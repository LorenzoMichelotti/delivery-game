extends Node

@onready var gas_bar_backdrop: Panel
@onready var gas_bar: Panel
@onready var gas_label: Label
@onready var points_label: Label
@onready var pawn: Actor:
	set(new_pawn):
		pawn = new_pawn
		pawn_changed.emit()
signal pawn_changed
@onready var pawn_spawn_position: Vector2
@onready var gps_scene: PackedScene = preload("res://ui/gps.tscn")
@onready var gps_arrow: Node2D

const save_path = "user://dddelivery_player_data.tres"

var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)
signal money_changed(money)

var attributes: PlayerAttributeData = PlayerAttributeData.new():
	set(new_attributes):
		print("attributes changed")
		attributes = new_attributes
		current_hp = max_hp

var attack_speed:
	get: return clamp(1 - attributes.base_attack_speed + attributes.bonus_attack_speed, 0.005, 1)
var damage:
	get: return attributes.base_damage + attributes.bonus_damage
var speed:
	get: return attributes.base_speed + attributes.bonus_speed
var max_gas:
	get: return attributes.base_max_gas + attributes.bonus_max_gas
var initial_gas_usage:
	get: return attributes.base_initial_gas_usage + attributes.bonus_initial_gas_usage
var max_hp: int:
	get: return attributes.base_max_hp + attributes.bonus_max_hp
	
var current_gas = attributes.base_max_gas
var gas_usage = 0
var current_hp = attributes.base_max_hp:
	set(new_value):
		if new_value < 0:
			current_hp = 0
			return
		if new_value > max_hp:
			current_hp = max_hp
			return
		current_hp = new_value

var points: int = 0:
	set(new_points):
		points = new_points
		points_changed.emit(points)
signal points_changed(points: int)

var current_level_points: int = 0

var point_multiplier = attributes.base_point_multiplier:
	get:
		return point_multiplier + attributes.base_point_multiplier + attributes.bonus_point_multiplier
	set(new_point_multiplier):
		point_multiplier = new_point_multiplier
		point_multiplier_changed.emit(point_multiplier)
signal point_multiplier_changed(point_multiplier: int)

var multiplier_timer = 60

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
	pawn_changed.connect(update_pawn_attributes)
	
func update_pawn_attributes():
	if pawn == null:
		return
	pawn.controller.speed = speed
	pawn.gun_turret_module.shoot_delay = clamp(attack_speed, 0.05, 0.2)
	pawn.gun_turret_module.windup_shoot_delay = attack_speed 
	pawn.gun_turret_module.damage = damage
	pawn.gun_turret_module.bullet_speed = attributes.bullet_speed
	
func load_data():
	var player_attribute_data: PlayerAttributeData = DataManager.load_resource(save_path)
	if player_attribute_data != null:
		attributes = player_attribute_data
		money = player_attribute_data.money

func save_data():
	var player_attribute_data = attributes
	player_attribute_data.money = money
	DataManager.save_resource(player_attribute_data, save_path)
	return

func on_upgrade_changed(upgrade: UpgradeResource):
	if upgrade.current_level == 0:
		attributes.upgrade_data.upgrades.erase(upgrade.id)
		return
	attributes.upgrade_data.upgrades.set(upgrade.id, upgrade)

func inventory_hold_delivery(delivery_id):
	inventory_delivery_ids.append(delivery_id)
	var delivery = EntityManager.deliveries.get(delivery_id)
	if is_instance_valid(delivery):
		inventory_delivery_ids_changed.emit(false, delivery.item.item.animation_frame, delivery.item.item.texture, delivery.item.item.is_animated_sprite)

func inventory_complete_delivery(delivery_id):
	print(EntityManager.deliveries)
	print(inventory_delivery_ids)
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
	point_multiplier = attributes.base_point_multiplier
	multiplier_timer = attributes.base_multiplier_timer

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
		LevelManager.next_level()
	
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
	if pawn != null:
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
	money += floor(points * 0.02)
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
	
