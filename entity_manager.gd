@tool
extends Node

const NPC = preload("res://actors/npc.tscn")

var entities = []
var deliveries = {}

func spawn_entity(scene, global_position = LevelManager.tile_map_layer.map_to_local(LevelManager.road_positions.pick_random()), regenerate: bool = false):
	var entity: Node = scene.instantiate()
	entity.global_position = global_position
	if regenerate:
		entity.tree_exited.connect(regenerate_entity.bind(scene, LevelManager.tile_map_layer.map_to_local(LevelManager.road_positions.pick_random()), regenerate))
	entities.append(entity)
	if get_tree().current_scene == null:
		return null
	get_tree().current_scene.get_node("Map/Entities").add_child.call_deferred(entity)
	return entity

func regenerate_entity(scene, global_position = LevelManager.tile_map_layer.map_to_local(LevelManager.road_positions.pick_random()), regenerate: bool = false):
	if is_inside_tree():
		spawn_entity.call_deferred(scene, LevelManager.tile_map_layer.map_to_local(LevelManager.road_positions.pick_random()), regenerate)

func _clear_entities():
	for entity in entities:
		if entity != null:
			entity.queue_free()
	entities.clear()


func create_delivery(valid_positions: Array[Vector2i] = LevelManager.road_positions, tile_map_layer: TileMapLayer = LevelManager.tile_map_layer, regenerate: bool = true):
	if not LevelManager.current_completion_requirements.level_modifiers.deliveries_enabled:
		return
	
	# TODO need to fix concurrent deliveries...
	#for i in range(LevelManager.current_completion_requirements.level_modifiers.concurrent_deliveries):
	var pickup_local_position: Vector2i = valid_positions.pick_random()
	var delivery_id = deliveries.size() + 1
	
	var target: ItemScene = ItemScene.new_delivery_target(Items.DELIVERY_TARGET_RES, tile_map_layer.to_global(tile_map_layer.map_to_local(_get_position_away_from_position(pickup_local_position, valid_positions, tile_map_layer))), delivery_id)
	get_tree().current_scene.get_node("Map/Entities").add_child.call_deferred(target)
	
	var pickup_item = ItemScene.new_delivery_pickupable(Items.PICKUP_RES, tile_map_layer.to_global(tile_map_layer.map_to_local(pickup_local_position)), delivery_id, target)
	get_tree().current_scene.get_node("Map/Entities").add_child.call_deferred(pickup_item)

	deliveries[delivery_id] = {
		"item": pickup_item,
		"obtained": false,
		"target": target
	}

	if LevelManager.current_completion_requirements.level_modifiers.mobile_delivery:
		pickup_item.set_cant_be_picked_up()
		var npc: Npc = spawn_entity(NPC, tile_map_layer.to_global(tile_map_layer.map_to_local(pickup_local_position)))
		await get_tree().process_frame
		npc.delivery_id = delivery_id
	
	return

func _get_position_away_from_position(position, valid_positions, tile_map_layer):
	var safe_position: Vector2i = valid_positions.pick_random()
	var safe_distance = 10
	var tries = 0
	while safe_position.distance_to(position) < safe_distance and tries < 50:
		safe_position = valid_positions.pick_random()
		tries += 1
	if tries >= 50:
		print("exceded maximum tries(50) getting safe position away from another position: ", position)
		return valid_positions.pick_random()
	return safe_position


func pickup_delivery_item(delivery_id: int):
	var delivery = deliveries.get(delivery_id)
	if delivery == null:
		return
	delivery.obtained = true


func can_deliver_item(delivery_id: int):
	if deliveries.has(delivery_id) and deliveries[delivery_id].obtained == true:
		return true
	return false


func deliver_item(delivery_id: int):
	erase_delivery_item(delivery_id)
	if not LevelManager.verify_level_win_condition():
		create_delivery()


func erase_delivery_item(delivery_id: int):
	if deliveries[delivery_id].item != null:
		deliveries[delivery_id].item.queue_free.call_deferred()
	if deliveries[delivery_id].target != null:
		deliveries[delivery_id].target.queue_free.call_deferred()
	deliveries.erase(delivery_id)

func get_closest_tank_position(compare_position: Vector2):
	var tanks = get_tree().get_nodes_in_group("tank")
	if tanks.size() <= 0:
		return null
		
	var positions = get_tree().get_nodes_in_group("tank").map(func(tank): if not (tank as Actor).alive_module.is_dead: return tank.global_position)
	
	return get_closest_position_in_array(compare_position, positions)
	
func get_closest_truck_position(compare_position: Vector2):
	var trucks = get_tree().get_nodes_in_group("truck")
	if trucks.size() <= 0:
		return null
	var positions = get_tree().get_nodes_in_group("truck").map(func(truck): if not (truck as Actor).alive_module.is_dead: return truck.global_position)
	
	return get_closest_position_in_array(compare_position, positions)

func get_closest_pickup_position(compare_position: Vector2):
	if EntityManager.deliveries.size() <= 0:
		return null
	var positions = EntityManager.deliveries.values().filter(
		func(delivery): return is_instance_valid(delivery.item) or is_instance_valid(delivery.target)).map(
		func(delivery): return delivery.item.global_position if is_instance_valid(delivery.item) else delivery.target.global_position)
	
	return get_closest_position_in_array(compare_position, positions)
	
func get_pickup_delivery_position(delivery_id):
	if delivery_id == null: 
		return null
	var delivery = EntityManager.deliveries.get(delivery_id)
	if delivery == null or delivery.target == null: 
		return null
	return delivery.target.global_position
	
func get_closest_tunnel_position(compare_position: Vector2):
	var tunnels = get_tree().get_nodes_in_group("tunnel")
	if tunnels.size() <= 0:
		return null
	var positions = get_tree().get_nodes_in_group("tunnel").map(func(tunnel): return tunnel.global_position)
	
	return get_closest_position_in_array(compare_position, positions)


func get_closest_delivery_position(compare_position: Vector2, delivery_ids: Array[int]):
	if delivery_ids.size() <= 0:
		return null
	var positions = delivery_ids.map(get_delivery_positions)
	
	return get_closest_position_in_array(compare_position, positions)


func get_delivery_positions(delivery_id): 
	var delivery = EntityManager.deliveries.get(delivery_id)
	if delivery:
		if delivery.target != null:
			return delivery.target.global_position
		if delivery.item != null:
			return delivery.item
	return null

func get_closest_position_in_array(compare_position, positions):
	if positions.size() <= 0:
		return null
	var shortest_distance = null
	var shortest_distance_position = null
	for position in positions:
		if position == null:
			continue
		var distance = compare_position.distance_to(position)
		if shortest_distance == null || distance < shortest_distance:
			shortest_distance = distance
			shortest_distance_position = position
	
	return shortest_distance_position
