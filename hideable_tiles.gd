extends TileMapLayer

var used_tiles: Array[Vector2i]
@onready var hide_range: Area2D = $HideRange
@onready var hide_range_shape: CollisionShape2D = $HideRange/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	used_tiles = get_used_cells()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlayerManager.pawn:
		hide_range.global_position = PlayerManager.pawn.global_position
		for used_tile in used_tiles:
			var tile_world_pos = map_to_local(used_tile)
			var corners = [
				tile_world_pos + Vector2(0, 0),
				tile_world_pos + Vector2(GlobalConstants.GRID_SIZE, 0),
				tile_world_pos + Vector2(GlobalConstants.GRID_SIZE, GlobalConstants.GRID_SIZE),
				tile_world_pos + Vector2(0, GlobalConstants.GRID_SIZE)
			]
			var inside_hide_range = true
			for corner in corners:
				if hide_range.global_position.distance_to(corner) > hide_range_shape.shape.radius:
					inside_hide_range = false
			if inside_hide_range:
				set_cell(used_tile, 2, get_cell_atlas_coords(used_tile), 1)
			else:
				set_cell(used_tile, 2, get_cell_atlas_coords(used_tile))
