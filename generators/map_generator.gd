@tool
extends Node2D

@export var grid_size: int = 4:
	set(new_grid_size):
		if new_grid_size % 2 == 0:
			if grid_size > new_grid_size:
				new_grid_size -= 1
			else:
				new_grid_size += 1
		grid_size = new_grid_size
		path_size = floor(grid_size * grid_size / 2) 
@export var border_size: int = 1
@export var path_size = 10
@export var generate_button: bool = false : set = generate

@onready var road_tilemap_layer = $Tiles/Road
@onready var background_tilemap_layer = $Tiles/Background
@onready var player_pawn_scene = preload("res://actors/player.tscn")
@onready var entities_container = $Entities
@onready var tunnel_scene: PackedScene = preload("res://tunnel.tscn")
@onready var tank_scene: PackedScene = preload("res://actors/tank/tank.tscn")
@onready var spike_scene: PackedScene = preload("res://hazards/spikes.tscn")
@onready var air_strike: PackedScene = preload("res://hazards/air_strike.tscn")

signal map_generated

enum TERRAIN_SET {
	MAIN
}

enum TERRAIN {
	OFFROAD,
	CITY,
	FOREST,
	GRASS
}

const TILE_SOURCES = {
	TERRAIN.OFFROAD: 1,
	TERRAIN.GRASS: 1,
	TERRAIN.CITY: 2
}

const TERRAIN_TILE_ATLAS_POSITIONS: Dictionary[TERRAIN, Vector2i] = {
	TERRAIN.OFFROAD: Vector2i(1,0),
	TERRAIN.GRASS: Vector2i(0,0),
	TERRAIN.CITY: Vector2i(1,0)
}


enum NEIGHBOURING_POSITIONS {
	TOP,
	LEFT,
	MID,
	RIGHT,
	BOT,
}

const neighbouring_positions: Dictionary[NEIGHBOURING_POSITIONS, Vector2i] = {
	NEIGHBOURING_POSITIONS.TOP: Vector2i(0, -1),
	NEIGHBOURING_POSITIONS.LEFT: Vector2i(-1, 0),
	NEIGHBOURING_POSITIONS.MID: Vector2i(0, 0),
	NEIGHBOURING_POSITIONS.RIGHT: Vector2i(1, 0),
	NEIGHBOURING_POSITIONS.BOT: Vector2i(0, 1),
}

var road_positions: Array[Vector2i] = []
var all_road_positions: Array[Vector2i] = []
var off_road_positions: Array[Vector2i] = []
var city_road_positions: Array[Vector2i] = []

var TERRAIN_POSITIONS = {
	TERRAIN.OFFROAD: off_road_positions,
	TERRAIN.CITY: city_road_positions
}

var grass_positions: Array[Vector2i] = []
var tunnels: Array[Node2D] = []
var tanks: Array[Actor] = []
var entities: Array = []

var rng

func _ready():
	if path_size == null:
		path_size = 3
	if not Engine.is_editor_hint():
		rng = RandomNumberGenerator.new()
		generate()

func generate(new_value: bool = true) -> void:
	rng = RandomNumberGenerator.new()
	_clear_entities()
	
	print("map generation started")
	print("generating path...")
	var walker = _generate_walker()
	print("connecting terrains...")
	_connect_terrains()
	print("map generated!")
	
	print("spawning entities")
	print("spawning tunnels")
	for exit_position in walker.get_exit_positions():
		_spawn_entities(tunnel_scene, 1, road_tilemap_layer.map_to_local(exit_position))
	print("spawning player")
	_spawn_entities(player_pawn_scene)
	print("spawning tanks")
	_spawn_entities(tank_scene, LevelManager.current_completion_requirements.level_modifiers.tank_count)
	_spawn_entities(spike_scene, randi_range(0,2))
	_spawn_entities(air_strike, randi_range(0,2))
	
	map_generated.emit()

func _clear_entities():
	for entity in entities:
		if entity != null:
			entity.queue_free.call_deferred()
	entities.clear()

func _generate_walker():
	print("cleaning previous data...")
	road_tilemap_layer.clear()
	road_positions.clear()
	grass_positions.clear()
	
	print("filling with roads...")
	_fill_with(TERRAIN.GRASS)
	
	var initial_cell_position = grass_positions.pick_random()
	while initial_cell_position.x < border_size or initial_cell_position.x >= grid_size + border_size or initial_cell_position.y < border_size or initial_cell_position.y >= grid_size + border_size: # border
		initial_cell_position = grass_positions.pick_random()
	
	var walker = Walker.new(Vector2i(border_size, border_size), Rect2(border_size, border_size, grid_size, grid_size), border_size)
	var map = walker.walk(grid_size * grid_size)
	
	for cell_position in map.road_history:
		_create_road_tile(cell_position, TERRAIN.OFFROAD) 
		road_positions.append(cell_position)
	for cell_position in map.step_history:
		_create_road_tile(cell_position, TERRAIN.OFFROAD) 
	
	return walker

func _spawn_entities(scene, amount = 1, position = road_tilemap_layer.map_to_local(road_positions.pick_random())):
	for i in range(amount):
		var entity = scene.instantiate()
		entity.global_position = position
		entities.append(entity)
		entities_container.add_child(entity)
	
func _fill_with(terrain: TERRAIN):
	for row in range(grid_size + (border_size * 2)):
		for col in range(grid_size + (border_size * 2)):
			var cell_position = Vector2i(row, col)
			road_tilemap_layer.set_cell(cell_position, TILE_SOURCES[terrain], TERRAIN_TILE_ATLAS_POSITIONS[terrain])
			grass_positions.append(cell_position)
	road_tilemap_layer.set_cells_terrain_connect(grass_positions, TERRAIN_SET.MAIN, terrain)
	
func _fill_with_grass():
	_fill_with(TERRAIN.GRASS)

func _get_neighbouring_tile_positions(tile_position: Vector2i) -> Dictionary[NEIGHBOURING_POSITIONS, Vector2i]:
	var neighbouring_tiles: Dictionary[NEIGHBOURING_POSITIONS, Vector2i] = {}
	for neighbouring_position in neighbouring_positions.keys():
		neighbouring_tiles[neighbouring_position] = Vector2i(tile_position.x + neighbouring_positions[neighbouring_position].x, tile_position.y + neighbouring_positions[neighbouring_position].y)
	return neighbouring_tiles
	
func _get_connected_terrain_positions(tile_position: Vector2i, terrain: TERRAIN) -> Dictionary[NEIGHBOURING_POSITIONS, bool]:
	var connected_positions: Dictionary[NEIGHBOURING_POSITIONS, bool] = {}
	for neighbouring_position in neighbouring_positions.keys():
		connected_positions[neighbouring_position] = road_tilemap_layer.get_cell_atlas_coords(Vector2i(tile_position.x + neighbouring_positions[neighbouring_position].x, tile_position.y + neighbouring_positions[neighbouring_position].y)) == TERRAIN_TILE_ATLAS_POSITIONS[terrain]
	return connected_positions

func _create_road_tile(cell_position, terrain):
	road_tilemap_layer.set_cell(cell_position, TILE_SOURCES[terrain], TERRAIN_TILE_ATLAS_POSITIONS[terrain])
	grass_positions.erase(cell_position)
	all_road_positions.append(cell_position)

func _connect_terrains():
	road_tilemap_layer.set_cells_terrain_connect(all_road_positions, TERRAIN_SET.MAIN, TERRAIN.OFFROAD)
	road_tilemap_layer.set_cells_terrain_connect(grass_positions, TERRAIN_SET.MAIN, TERRAIN.GRASS)

func _neighbour_is_null_or_not_connected(neighbour_position, road_atlas_position):
	return (road_tilemap_layer.get_cell_tile_data(neighbour_position) == null or 
		road_tilemap_layer.get_cell_atlas_coords(neighbour_position) != road_atlas_position)
