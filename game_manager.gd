extends Node2D

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
const npcs = {
	"police_car": {
		"scene": preload("res://actors/npc.tscn")
	}
}

@export var current_client: ActorResource

@onready var game_over_scene: PackedScene = preload("res://ui/GameOver.tscn")
@onready var pause_scene: PackedScene = preload("res://ui/Pause.tscn")

var skip_cutscenes = true
var game_over_ui
var pause_ui
var road: TileMapLayer

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
var endless = true

var npc_count = 5
var npcs_alive = 0
var random_gas_enabled = true
var random_deliveries_enabled = true

var level_deliveries = {}
signal clear_items

var acquired_targets = {}
func _on_acquire_target(target_type: GlobalConstants.TARGET_TYPES):
	if not acquired_targets.has(target_type):
		acquired_targets[target_type] = 0
	acquired_targets[target_type] += 1

func _ready():
	game_over_ui = game_over_scene.instantiate()
	add_child.call_deferred(game_over_ui)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.set_game_mode(GameManager.GAMEMODE.PAUSED)

func is_game_paused():
	return current_game_mode != GAMEMODE.PLAYING

func set_game_mode(new_game_mode: GAMEMODE):
	if new_game_mode == current_game_mode:
		return
		
	previous_game_mode = current_game_mode
	current_game_mode = new_game_mode
	
	match current_game_mode:
		GAMEMODE.INITIALIZING:
			get_tree().paused = true
			return
		GAMEMODE.GAMEOVER:
			get_tree().paused = true
			gameover()
			return
		GAMEMODE.PAUSED:
			get_tree().paused = true
			pause_screen()
			return
		GAMEMODE.CUTSCENE:
			return
		GAMEMODE.PLAYING:
			get_tree().paused = false

func gameover():
	game_over_ui.play.call_deferred()
	
func pause_screen():
	if pause_ui != null:
		pause_ui.show.call_deferred()
		return
	pause_ui = pause_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(pause_ui)

func on_level_changed():
	reset_map()

func reset_level():
	reset_map()
	PlayerManager.reset_player()

func reset_map():
	_clear_map()
	create_delivery()
	_scatter_fuel(5)
	_scatter_npcs(npc_count)

func _clear_map():
	acquired_targets.clear()
	clear_items.emit()
	level_deliveries.clear()

func get_closest_pickup_position(compare_position: Vector2):
	if level_deliveries.size() <= 0:
		return null
	var shortest_distance = null
	var shortest_distance_position = null
	for delivery_id in level_deliveries.keys():
		var delivery = level_deliveries[delivery_id]
		if !delivery.item and !delivery.target:
			return null
		var position = delivery.item.global_position if delivery.item != null else delivery.target.global_position
		var distance = compare_position.distance_to(position)
		if shortest_distance == null || distance < shortest_distance:
			shortest_distance = distance
			shortest_distance_position = position
	return shortest_distance_position
	
func get_closest_tunnel_position(compare_position: Vector2):
	var tunnels = get_tree().get_nodes_in_group("tunnel")

	if tunnels.size() <= 0:
		return null
		
	var shortest_distance = null
	var shortest_distance_position = null
	for tunnel in tunnels:
		var position = tunnel.global_position
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
		var delivery = level_deliveries[delivery_id]
		if delivery.target == null:
			return null
		var position = delivery.target.global_position if delivery.target != null else delivery.item
		var distance = compare_position.distance_to(position)
		if shortest_distance == null || distance < shortest_distance:
			shortest_distance = distance
			shortest_distance_position = position
	return shortest_distance_position

func create_delivery():
	if not random_deliveries_enabled:
		return
	var pickup_item_resource = items.pickup.resource.duplicate()
	pickup_item_resource.texture = current_client.objects.pick_random()
	var pickup_item: ItemScene = _spawn_item(pickup_item_resource)
	var target: ItemScene = _spawn_item(items.delivery_target.resource.duplicate())
	target.color = current_client.color
	
	var delivery_id = level_deliveries.size() + 1
	
	pickup_item.item.delivery_id = delivery_id
	target.item.delivery_id = delivery_id
	pickup_item.item.picked_up.connect(target.item.on_delivery_item_picked_up.bind(target))
	
	level_deliveries[delivery_id] = {
		"item": pickup_item,
		"obtained": false,
		"target": target
	}
	
func _spawn_item(item_resource: Resource) -> ItemScene:
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
	get_tree().current_scene.get_node("Map/Entities").add_child.call_deferred(spawned_item)
	return spawned_item

func _get_free_tiles(road: TileMapLayer):
	var road_tiles: Array[Vector2i] = LevelManager.road_positions
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
	if not random_gas_enabled or not PlayerManager.gas_enabled:
		return
	for i in range(amount):
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
		get_tree().current_scene.get_node("Map/Entities").add_child.call_deferred(gas_item)
		
func _scatter_npcs(amount: int):
	for i in range(amount):
		var road_tiles: Array[Vector2i] = LevelManager.road_positions
		var tile_position = road_tiles.pick_random()
		npcs_alive += 1
		var police_car_npc = npcs.police_car.scene.instantiate()
		police_car_npc.global_position = to_global(road.map_to_local(tile_position)) 
		get_tree().current_scene.get_node("Map/Entities").add_child(police_car_npc)
		police_car_npc.add_to_group("enemy")
		police_car_npc.alive_module.died.connect(_on_npc_died)

func _on_npc_died():
	npcs_alive -= 1
	get_tree().create_timer(5).timeout.connect(_scatter_npcs.call_deferred.bind(1))

func pickup_delivery_item(delivery_id: int):
	level_deliveries[delivery_id].obtained = true

func can_deliver_item(delivery_id: int):
	if level_deliveries.has(delivery_id) and level_deliveries[delivery_id].obtained == true:
		return true
	return false

func deliver_item(delivery_id: int):
	level_deliveries.erase(delivery_id)
	if not LevelManager.verify_level_win_condition():
		create_delivery()
		_scatter_fuel(rng.randi_range(1,3))
