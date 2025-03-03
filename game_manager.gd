extends Node2D

var levels = {
	1: {
		"road_node_paths": ["Tiles/CityRoad", "Tiles/OffRoad"],
		"scene": preload("res://levels/1.tscn"),
		"watched_cutscene": true
	},
	2: {
		"road_node_paths": ["Tiles/CityRoad", "Tiles/OffRoad"],
		"scene": preload("res://levels/2.tscn"),
		"watched_cutscene": true
	},
	3: {
		"road_node_paths": ["Tiles/CityRoad", "Tiles/OffRoad"],
		"scene": preload("res://levels/3.tscn"),
		"watched_cutscene": true
	},
}
const item_scene = preload("res://items/item.tscn")
const items = {
	"gas": {
		"resource": preload("res://items/gas_item_resource.tres")
	},
	"pickup": {
		"resource": preload("res://items/pickup_item_resource.tres")
	},
	"delivery_target": {
		"resource": preload("res://items/delivery_target_resource.tres")
	}
}

@export var current_client: ActorResource

@onready var game_over_scene: PackedScene = preload("res://ui/GameOver.tscn")
@onready var pause_scene: PackedScene = preload("res://ui/Pause.tscn")

var current_level: int = 0
var current_day: int = 0
var current_completion_goal
var current_level_retries: int = 0

var game_over_ui
var pause_ui
var roads: Array[TileMapLayer]

enum GAMEMODE {
	INITIALIZING,
	MENU,
	PLAYING,
	GAMEOVER,
	PAUSED,
	CUTSCENE
}

var current_game_mode = GAMEMODE.INITIALIZING
var previous_game_mode = GAMEMODE.INITIALIZING
var rng = RandomNumberGenerator.new()
var endless = false

var deliveries = {}
signal clear_items

func _ready():
	change_level(3)

func set_watched_level_cutscene():
	levels[current_level].watched_cutscene = true

func have_watched_level_cutscene():
	if current_level == 0:
		return false
	return levels[current_level].watched_cutscene

func change_level(level: int):
	set_game_mode(GAMEMODE.INITIALIZING)
	if level != current_level:
		current_day += 1
		current_level = level
		current_level_retries = 0
	else:
		current_level_retries += 1
	var level_data = levels[level]
	get_tree().change_scene_to_packed.call_deferred(level_data.scene)
	
func next_level():
	var next_level_number = current_level + 1
	if next_level_number > levels.size():
		next_level_number = 1
	change_level(next_level_number)

func is_game_paused():
	return current_game_mode != GAMEMODE.PLAYING

func set_game_mode(new_game_mode: GAMEMODE):
	if new_game_mode == current_game_mode:
		return
		
	previous_game_mode = current_game_mode
	current_game_mode = new_game_mode
	
	match current_game_mode:
		GAMEMODE.GAMEOVER:
			gameover()
			return
		GAMEMODE.PAUSED:
			pause_screen()
			return
		GAMEMODE.CUTSCENE:
			return

func verify_level_win_condition():
	if current_completion_goal:
		return current_completion_goal.verify_completion_requirement_met()
	
func gameover():
	if game_over_ui != null:
		game_over_ui.play.call_deferred()
		return
	game_over_ui = game_over_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(game_over_ui)
	
func pause_screen():
	if pause_ui != null:
		pause_ui.show.call_deferred()
		return
	pause_ui = pause_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(pause_ui)

func on_level_changed():
	roads = [
		get_tree().current_scene.get_node("Tiles/CityRoad"), 
		get_tree().current_scene.get_node("Tiles/OffRoad")
	]
	_clear_map()
	create_delivery()
	_scatter_fuel(5)

func reset_level():
	_clear_map()
	create_delivery()
	_scatter_fuel(5)
	PlayerManager.reset_player()

func reset_map():
	_clear_map()
	create_delivery()
	_scatter_fuel(5)

func _clear_map():
	clear_items.emit()
	deliveries.clear()

func get_closest_pickup_position(compare_position: Vector2):
	if deliveries.size() <= 0:
		return null
	var shortest_distance = null
	var shortest_distance_position = null
	for delivery_id in deliveries.keys():
		var delivery = deliveries[delivery_id]
		if !delivery.item and !delivery.target:
			return null
		var position = delivery.item.global_position if delivery.item != null else delivery.target.global_position
		var distance = compare_position.distance_to(position)
		if shortest_distance == null || distance < shortest_distance:
			shortest_distance = distance
			shortest_distance_position = position
	return shortest_distance_position

func get_closest_delivery_position(compare_position: Vector2, delivery_ids: Array[int]):
	if delivery_ids.size() <= 0:
		return null
	var shortest_distance = null
	var shortest_distance_position = null
	for delivery_id in delivery_ids:
		var delivery = deliveries[delivery_id]
		if delivery.target == null:
			return null
		var position = delivery.target.global_position if delivery.target != null else delivery.item
		var distance = compare_position.distance_to(position)
		if shortest_distance == null || distance < shortest_distance:
			shortest_distance = distance
			shortest_distance_position = position
	return shortest_distance_position

func create_delivery():
	var pickup_item_resource = items.pickup.resource.duplicate()
	pickup_item_resource.texture = current_client.objects.pick_random()
	var pickup_item: ItemScene = _spawn_item(pickup_item_resource)
	var target: ItemScene = _spawn_item(items.delivery_target.resource.duplicate())
	target.color = current_client.color
	
	var delivery_id = deliveries.size() + 1
	
	pickup_item.item.delivery_id = delivery_id
	target.item.delivery_id = delivery_id
	pickup_item.item.picked_up.connect(target.item.on_delivery_item_picked_up.bind(target))
	
	deliveries[delivery_id] = {
		"item": pickup_item,
		"obtained": false,
		"target": target
	}
	
func _spawn_item(item_resource: Resource) -> ItemScene:
	var road: TileMapLayer = roads.pick_random()
	var free_tiles = _get_free_tiles(road)
	if free_tiles == null or free_tiles.size() <= 0:
		print("ERROR: couldnt spawn item because there were no free tiles")
	var tile_position = free_tiles.pick_random()
	var tile_data = road.get_cell_tile_data(tile_position)
	tile_data.set_custom_data("occupied", true)
	var spawned_item = item_scene.instantiate()
	spawned_item.z_index += 2
	clear_items.connect(spawned_item.queue_free)
	spawned_item.item = item_resource
	spawned_item.tile_position = tile_position
	spawned_item.road = road
	spawned_item.global_position = to_global(road.map_to_local(tile_position)) 
	get_tree().current_scene.add_child.call_deferred(spawned_item)
	return spawned_item

func _get_free_tiles(road: TileMapLayer):
	var road_tiles: Array[Vector2i] = road.get_used_cells()
	var free_tiles = road_tiles.filter(
		func(tile_position: Vector2i): 
			if !road.get_cell_tile_data(tile_position).get_custom_data("occupied"): 
				return tile_position
	)
	if free_tiles.size() <= 0:
		# fallback cause sometimes it doesnt find any free tiles....
		free_tiles = road_tiles
	return free_tiles

func _scatter_fuel(amount: int):
	for i in range(amount):
		var road = roads.pick_random()
		var free_tiles = _get_free_tiles(road)
		if free_tiles == null or free_tiles.size() <= 0:
			print("ERROR: couldnt spawn item because there were no free tiles")
		var tile_position = free_tiles.pick_random()
		var tile_data = road.get_cell_tile_data(tile_position)
		tile_data.set_custom_data("occupied", true)
		var gas_item = item_scene.instantiate()
		clear_items.connect(gas_item.queue_free)
		gas_item.item = items.gas.resource.duplicate()
		gas_item.tile_position = tile_position
		gas_item.road = road
		gas_item.global_position = to_global(road.map_to_local(tile_position)) 
		get_tree().current_scene.add_child.call_deferred(gas_item)

func pickup_delivery_item(delivery_id: int):
	deliveries[delivery_id].obtained = true

func can_deliver_item(delivery_id: int):
	if deliveries.has(delivery_id) and deliveries[delivery_id].obtained == true:
		return true
	return false

func deliver_item(delivery_id: int):
	print("deliver_item")
	print(deliveries)
	deliveries.erase(delivery_id)
	print("erased delivery from deliveries object")
	print(deliveries)
	create_delivery()
	print(deliveries)
	_scatter_fuel(rng.randi_range(1,3))
