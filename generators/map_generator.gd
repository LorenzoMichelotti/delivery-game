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
@onready var player_pawn = preload("res://actors/player.tscn")
@onready var entities = $Entities
@onready var tunnel_scene: PackedScene = preload("res://tunnel.tscn")
@onready var tank_scene: PackedScene = preload("res://actors/tank/tank.tscn")

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

var terrain_tile_atlas_positions: Dictionary[TERRAIN, Vector2i] = {
	TERRAIN.OFFROAD: Vector2i(1,0),
	TERRAIN.GRASS: Vector2i(0,0)
}

var road_positions: Array[Vector2i] = []
var grass_positions: Array[Vector2i] = []
var tunnels: Array[Node2D] = []
var tanks: Array[Actor] = []
var current_player_pawn: CharacterBody2D
var rng

func _ready():
	if path_size == null:
		path_size = 3
	if not Engine.is_editor_hint():
		rng = RandomNumberGenerator.new()
		generate()

func generate(new_value: bool = true) -> void:
	rng = RandomNumberGenerator.new()
	
	print("map generation started")
	print("generating path...")
	_generate_walker()
	print("connecting terrains...")
	_connect_terrains()
	print(grass_positions.size())
	print(road_positions.size())
	print("map generated!")
	print("spawning player")
	_spawn_player_pawn()
	_spawn_tanks()
	map_generated.emit()

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
	
	for cell_position in map:
		road_tilemap_layer.set_cell(cell_position, 1, terrain_tile_atlas_positions[TERRAIN.OFFROAD])
		grass_positions.erase(cell_position)
		road_positions.append(cell_position)
		
	print("spawning doors")
	_spawn_exits(walker.get_exit_positions())

func _spawn_player_pawn():
	if current_player_pawn != null:
		current_player_pawn.queue_free()
	current_player_pawn = player_pawn.instantiate()
	current_player_pawn.global_position = road_tilemap_layer.map_to_local(road_positions.pick_random())
	entities.add_child(current_player_pawn)

func _spawn_tanks():
	if tanks.size() > 0:
		for t in tanks:
			if t != null:
				t.queue_free()
	tanks.clear()
	var should_spawn_tanks = randi_range(0,1)
	if should_spawn_tanks == 0:
		return
	var tank_count = randi_range(0, 2)
	for i in range(tank_count):
		var tank = tank_scene.instantiate()
		tank.global_position = road_tilemap_layer.map_to_local(road_positions.pick_random())
		tanks.append(tank)
		entities.add_child(tank)
	
func _fill_with(terrain: TERRAIN):
	for row in range(grid_size + (border_size * 2)):
		for col in range(grid_size + (border_size * 2)):
			var cell_position = Vector2i(row, col)
			road_tilemap_layer.set_cell(cell_position, 1, terrain_tile_atlas_positions[terrain])
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
		connected_positions[neighbouring_position] = road_tilemap_layer.get_cell_atlas_coords(Vector2i(tile_position.x + neighbouring_positions[neighbouring_position].x, tile_position.y + neighbouring_positions[neighbouring_position].y)) == terrain_tile_atlas_positions[terrain]
	return connected_positions

func _generate_maze():
	print("cleaning previous data...")
	road_tilemap_layer.clear()
	road_positions.clear()
	grass_positions.clear()
	
	print("filling with grass...")
	_fill_with_grass()
	
	var cell_position = grass_positions.pick_random()
	while cell_position.x < border_size or cell_position.x >= grid_size + border_size or cell_position.y < border_size or cell_position.y >= grid_size + border_size: # border
		cell_position = grass_positions.pick_random()
	road_tilemap_layer.set_cell(cell_position, 1, terrain_tile_atlas_positions[TERRAIN.OFFROAD])
	road_positions.append(cell_position)
	grass_positions.erase(cell_position)
	var tries = 0
	var border_cells = 0
	var current_path_size = 0
	if path_size > grid_size * grid_size / 2:
		path_size = floor(grid_size * grid_size / 2)
	while current_path_size < path_size:
		cell_position = grass_positions.pick_random()
		if cell_position.x < border_size or cell_position.x >= grid_size + border_size or cell_position.y < border_size or cell_position.y >= grid_size + border_size: # border
			border_cells += 1
			tries += 1
			continue
		var visited_walls_count = 0
		var neighbouring_tiles: Dictionary[NEIGHBOURING_POSITIONS, Vector2i] = _get_neighbouring_tile_positions(cell_position)
		var visited_tile_neighbouring_position: NEIGHBOURING_POSITIONS
		if road_tilemap_layer.get_cell_atlas_coords(neighbouring_tiles[NEIGHBOURING_POSITIONS.TOP]) == terrain_tile_atlas_positions[TERRAIN.OFFROAD]:
			visited_walls_count += 1
		if  road_tilemap_layer.get_cell_atlas_coords(neighbouring_tiles[NEIGHBOURING_POSITIONS.RIGHT]) == terrain_tile_atlas_positions[TERRAIN.OFFROAD]:
			visited_walls_count += 1
		if  road_tilemap_layer.get_cell_atlas_coords(neighbouring_tiles[NEIGHBOURING_POSITIONS.BOT]) == terrain_tile_atlas_positions[TERRAIN.OFFROAD]:
			visited_walls_count += 1
		if  road_tilemap_layer.get_cell_atlas_coords(neighbouring_tiles[NEIGHBOURING_POSITIONS.LEFT]) == terrain_tile_atlas_positions[TERRAIN.OFFROAD]:
			visited_walls_count += 1
		if visited_walls_count == 1:
			_create_road_tile(cell_position)
			current_path_size += 1
			tries += 1
			continue
		tries += 1
	print("took ", str(tries), " tries to generate roads")
	if path_size - current_path_size >= path_size/2:
		print("restarting path generation because path_size was too short: ", current_path_size)
		_generate_maze()

func _create_road_tile(cell_position):
	road_tilemap_layer.set_cell(cell_position, 1, terrain_tile_atlas_positions[TERRAIN.OFFROAD])
	grass_positions.erase(cell_position)
	road_positions.append(cell_position)

func _connect_terrains():
	road_tilemap_layer.set_cells_terrain_connect(road_positions, TERRAIN_SET.MAIN, TERRAIN.OFFROAD)
	road_tilemap_layer.set_cells_terrain_connect(grass_positions, TERRAIN_SET.MAIN, TERRAIN.GRASS)

func _neighbour_is_null_or_not_connected(neighbour_position, road_atlas_position):
	return (road_tilemap_layer.get_cell_tile_data(neighbour_position) == null or 
		road_tilemap_layer.get_cell_atlas_coords(neighbour_position) != road_atlas_position)

func _spawn_exits(exit_positions: Array[Vector2i]):
	if tunnels.size() > 0:
		for t in tunnels:
			if t != null:
				t.queue_free()
	tunnels.clear()
	for exit_pos in exit_positions:
		var tunnel = tunnel_scene.instantiate()
		tunnel.global_position = road_tilemap_layer.map_to_local(exit_pos)
		tunnels.append(tunnel)
		entities.add_child(tunnel)
		if not Engine.is_editor_hint():
			if exit_pos.x == 0:
				tunnel.frame = 0
			if exit_pos.x == grid_size + (border_size * 2):
				tunnel.frame = 1
