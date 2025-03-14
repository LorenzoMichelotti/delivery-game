@tool
extends Node

const ACTORS = {
	"npc": preload("res://actors/npc.tscn")
}



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
	
	var pickup_position = valid_positions.pick_random()
	print(pickup_position)
	
	var pickup_item_resource = Items.PICKUP_RES.duplicate()
	pickup_item_resource.texture = LevelManager.current_completion_requirements.client.objects.pick_random()
	
	var delivery_id = deliveries.size() + 1
	var target: ItemScene = await _spawn_item(Items.DELIVERY_TARGET_RES.duplicate(), _get_position_away_from_position(pickup_position, valid_positions, tile_map_layer), tile_map_layer)
	target.color = LevelManager.current_completion_requirements.client.color
	target.item.delivery_id = delivery_id
	
	var pickup_item: ItemScene = await _spawn_item(pickup_item_resource, pickup_position, tile_map_layer)
	pickup_item.item.delivery_id = delivery_id
	pickup_item.item.picked_up.connect(target.item.on_delivery_item_picked_up.bind(target))

	deliveries[delivery_id] = {
		"item": pickup_item,
		"obtained": false,
		"target": target
	}

	if LevelManager.current_completion_requirements.level_modifiers.mobile_delivery:
		pickup_item.set_cant_be_picked_up()
		var npc: Npc = spawn_entity(ACTORS.npc, tile_map_layer.to_global(tile_map_layer.map_to_local(pickup_position)))
		await get_tree().process_frame
		npc.delivery_id = delivery_id
	
	return deliveries[delivery_id]

func _get_position_away_from_position(position, valid_positions, tile_map_layer):
	var safe_position: Vector2i = valid_positions.pick_random()
	var safe_distance = 5
	var tries = 0
	while safe_position.distance_to(position) < safe_distance and tries < 50:
		safe_position = valid_positions.pick_random()
		tries += 1
	if tries >= 50:
		print("exceded maximum tries(50) getting safe position away from another position: ", position)
	return valid_positions.pick_random()


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
	erase_delivery_item(delivery_id)
	if not LevelManager.verify_level_win_condition():
		create_delivery()


func erase_delivery_item(delivery_id: int):
	if deliveries[delivery_id].item != null:
		deliveries[delivery_id].item.queue_free.call_deferred()
	if deliveries[delivery_id].target != null:
		deliveries[delivery_id].target.queue_free.call_deferred()
	deliveries.erase(delivery_id)

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
