extends Node2D

const item_scene = preload("res://items/item.tscn")

const items = {
	"gas": {
		"resource": preload("res://items/gas.gd")
	},
	"pickup": {
		"resource": preload("res://items/pickup.gd")
	},
	"delivery_target": {
		"resource": preload("res://items/delivery_target.gd")
	}
}

@onready var game_over_scene: PackedScene = preload("res://ui_themes/GameOver.tscn")
@onready var city_road: TileMapLayer
@onready var off_road: TileMapLayer
var game_over_ui
var roads: Array[TileMapLayer]

enum GAMEMODE {
	PLAYING,
	GAMEOVER
}

var current_game_mode = GAMEMODE.PLAYING
var previous_game_mode = GAMEMODE.PLAYING
var rng = RandomNumberGenerator.new()

var deliveries = {}
signal clear_items

func _ready():
	city_road = get_tree().current_scene.get_node("Tiles/CityRoad")
	off_road = get_tree().current_scene.get_node("Tiles/OffRoad")
	roads = [city_road, off_road]
	reset_map()

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
		GAMEMODE.PLAYING:
			PlayerManager.reset_player()
			reset_map()

func _process(delta):
	pass

func gameover():
	if game_over_ui:
		game_over_ui.show()
		return
	game_over_ui = game_over_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(game_over_ui)

func reset_map():
	clear_items.emit()
	deliveries.clear()
	create_delivery()
	_scatter_fuel(5)

func get_closest_pickup_position(compare_position: Vector2):
	if deliveries.size() <= 0:
		return null
	var shortest_distance = null
	var shortest_distance_position = null
	for delivery_id in deliveries.keys():
		var delivery = deliveries[delivery_id]
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
	var pickup_item: ItemScene = _spawn_item(items.pickup.resource)
	var target: ItemScene = _spawn_item(items.delivery_target.resource)
	
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
	var tile_position = _get_free_tiles(road).pick_random()
	var tile_data = road.get_cell_tile_data(tile_position)
	tile_data.set_custom_data("occupied", true)
	var spawned_item = item_scene.instantiate()
	clear_items.connect(spawned_item.queue_free)
	spawned_item.item = item_resource.new()
	spawned_item.tile_position = tile_position
	spawned_item.road = road
	spawned_item.global_position = to_global(road.map_to_local(tile_position)) 
	get_tree().current_scene.add_child.call_deferred(spawned_item)
	return spawned_item

func _get_free_tiles(road: TileMapLayer):
	var road_tiles: Array[Vector2i] = road.get_used_cells()
	return road_tiles.filter(
		func(tile_position: Vector2i): 
			if road == null:
				print("_get_free_: road was null")
			if !road.get_cell_tile_data(tile_position).get_custom_data("occupied"): 
				return tile_position
	)

func _scatter_fuel(amount: int):
	for i in range(amount):
		var road = roads.pick_random()
		var tile_position = road.get_used_cells().pick_random()
		var tile_data = road.get_cell_tile_data(tile_position)
		while tile_data.get_custom_data("occupied"):
			road = roads.pick_random()
			tile_position = road.get_used_cells().pick_random()
			tile_data = road.get_cell_tile_data(tile_position)
		tile_data.set_custom_data("occupied", true)
		var gas_item = item_scene.instantiate()
		clear_items.connect(gas_item.queue_free)
		gas_item.item = items.gas.resource.new(20)
		gas_item.tile_position = tile_position
		gas_item.road = road
		gas_item.global_position = to_global(road.map_to_local(tile_position)) 
		get_tree().current_scene.add_child.call_deferred(gas_item)

func pickup_delivery_item(delivery_id: int):
	deliveries[delivery_id].obtained = true

func can_deliver_item(delivery_id: int):
	if deliveries.has(delivery_id) and deliveries[delivery_id].obtained == true:
		deliveries.erase(delivery_id)
		create_delivery()
		_scatter_fuel(rng.randi_range(1,3))
		return true
	return false
