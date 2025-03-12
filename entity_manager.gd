extends Node

var entities = []
var deliveries = {}


func spawn_entities(scene, amount = 1, global_position = LevelManager.tile_map_layer.map_to_local(LevelManager.road_positions.pick_random())):
	var new_entities = []
	for i in range(amount):
		var entity = scene.instantiate()
		entity.global_position = global_position
		entities.append(entity)
		new_entities.append(entity)
		get_tree().current_scene.get_node("Map/Entities").add_child(entity)
	return new_entities


func _clear_entities():
	for entity in entities:
		if entity != null:
			entity.queue_free.call_deferred()
	entities.clear()


func create_delivery(valid_positions: Array[Vector2i] = LevelManager.road_positions, tile_map_layer: TileMapLayer = LevelManager.tile_map_layer):
	if not LevelManager.current_completion_requirements.level_modifiers.deliveries_enabled:
		return
	
	var pickup_item_resource = Items.PICKUP_RES.duplicate()
	pickup_item_resource.texture = LevelManager.current_completion_requirements.client.objects.pick_random()
	var pickup_item: ItemScene = _spawn_item(pickup_item_resource, valid_positions.pick_random(), tile_map_layer)
	var target: ItemScene = _spawn_item(Items.DELIVERY_TARGET_RES.duplicate(), valid_positions.pick_random(), tile_map_layer)
	target.color = LevelManager.current_completion_requirements.client.color
	var delivery_id = deliveries.size() + 1
	pickup_item.item.delivery_id = delivery_id
	target.item.delivery_id = delivery_id
	pickup_item.item.picked_up.connect(target.item.on_delivery_item_picked_up.bind(target))
	
	deliveries[delivery_id] = {
		"item": pickup_item,
		"obtained": false,
		"target": target
	}
	
	return deliveries[delivery_id]


func _spawn_item(item_resource: Resource, tile_position = LevelManager.road_positions.pick_random(), tile_map_layer: TileMapLayer = LevelManager.tile_map_layer) -> ItemScene:
	var spawned_item = Items.ITEM_SCENE.instantiate()
	spawned_item.z_index += 2
	spawned_item.item = item_resource
	spawned_item.tile_position = tile_position
	spawned_item.road = tile_map_layer
	spawned_item.global_position = tile_map_layer.to_global(tile_map_layer.map_to_local(tile_position)) 
	get_tree().current_scene.get_node("Map/Entities").add_child.call_deferred(spawned_item)
	return spawned_item


func pickup_delivery_item(delivery_id: int):
	deliveries[delivery_id].obtained = true


func can_deliver_item(delivery_id: int):
	if deliveries.has(delivery_id) and deliveries[delivery_id].obtained == true:
		return true
	return false


func deliver_item(delivery_id: int):
	if deliveries[delivery_id].item != null:
		deliveries[delivery_id].item.queue_free.call_deferred()
	if deliveries[delivery_id].target != null:
		deliveries[delivery_id].target.queue_free.call_deferred()
	deliveries.erase(delivery_id)
	if not LevelManager.verify_level_win_condition():
		create_delivery()


func get_closest_pickup_position(compare_position: Vector2):
	if EntityManager.deliveries.size() <= 0:
		return null
	var positions = EntityManager.deliveries.values().filter(
		func(delivery): return is_instance_valid(delivery.item) or is_instance_valid(delivery.target)).map(
		func(delivery): return delivery.item.global_position if is_instance_valid(delivery.item) else delivery.target.global_position)
	
	return get_closest_position_in_array(compare_position, positions)
	
	
func get_closest_tunnel_position(compare_position: Vector2):
	var tunnels = get_tree().get_nodes_in_group("tunnel")
	if tunnels.size() <= 0:
		return null
	var positions = get_tree().get_nodes_in_group("tunnel").map(func(tunnel): return tunnel.global_position)
	
	return get_closest_position_in_array(compare_position, positions)


func get_closest_delivery_position(compare_position: Vector2, delivery_ids: Array[int]):
	if delivery_ids.size() <= 0:
		return null
	var positions = delivery_ids.map(func(delivery_id): return EntityManager.deliveries[delivery_id].target.global_position if EntityManager.deliveries[delivery_id].target != null else EntityManager.deliveries[delivery_id].item)
	
	return get_closest_position_in_array(compare_position, positions)


func get_closest_position_in_array(compare_position, positions):
	if positions.size() <= 0:
		return null
	var shortest_distance = null
	var shortest_distance_position = null
	for position in positions:
		var distance = compare_position.distance_to(position)
		if shortest_distance == null || distance < shortest_distance:
			shortest_distance = distance
			shortest_distance_position = position
	
	return shortest_distance_position
