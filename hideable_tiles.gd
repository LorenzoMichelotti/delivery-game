extends TileMapLayer

var used_tiles: Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready():
	used_tiles = get_used_cells()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlayerManager.pawn:
		for used_tile in used_tiles:
			var tile_world_pos = map_to_local(used_tile)
			if PlayerManager.pawn.global_position.distance_to(tile_world_pos) < 16:
				set_cell(used_tile, 2, get_cell_atlas_coords(used_tile), 1)
				return
			#for item in get_tree().get_nodes_in_group("item"):
				#if item.global_position.distance_to(tile_world_pos) < 16:
					#set_cell(used_tile, 2, get_cell_atlas_coords(used_tile), 1)
					#return
			#for enemy in get_tree().get_nodes_in_group("enemy"):
				#if enemy.global_position.distance_to(tile_world_pos) < 16:
					#set_cell(used_tile, 2, get_cell_atlas_coords(used_tile), 1)
					#return
			set_cell(used_tile, 2, get_cell_atlas_coords(used_tile))
