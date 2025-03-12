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

var acquired_targets = {}
func _on_acquire_target(target_type: GlobalConstants.TARGET_TYPES):
	if not acquired_targets.has(target_type):
		acquired_targets[target_type] = 0
	acquired_targets[target_type] += 1

func _ready():
	game_over_ui = game_over_scene.instantiate()
	add_child.call_deferred(game_over_ui)

func _unhandled_input(event):
	print("ababa")
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
	acquired_targets.clear()

func _get_free_tiles(road: TileMapLayer):
	var free_tiles = LevelManager.road_positions.filter(
		func(tile_position: Vector2i): 
			if !road.get_cell_tile_data(tile_position).get_custom_data("occupied"): 
				return tile_position
	)
	if free_tiles.size() <= 0:
		# fallback cause sometimes it doesnt find any free tiles....
		free_tiles = LevelManager.road_positions
	return free_tiles

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
