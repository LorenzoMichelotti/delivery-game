@tool
extends Node
class_name Walker

const DIRECTIONS = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]

var position = Vector2i.ZERO
var direction = Vector2i.RIGHT
var borders: Rect2 = Rect2()
var outer_borders: int = 1
var step_history: Array[Vector2i] = []
var road_history: Array[Vector2i] = []
var steps_since_turn = 0
var rooms = []
var exits: Array[Vector2i] = []

func _init(starting_position: Vector2i, new_borders: Rect2, _outer_borders: int):
	assert(new_borders.has_point(starting_position))
	position = starting_position
	step_history.append(starting_position)
	road_history.append(starting_position)
	borders = new_borders
	outer_borders = _outer_borders

func walk(steps):
	place_room(position)
	for step in steps:
		if steps_since_turn >= 5:
			change_direction()
		
		if step():
			step_history.append(position)
			road_history.append(position)
		else:
			change_direction()
	generate_random_exits()
	return {"step_history": step_history, "road_history": road_history}

func step():
	var target_position = position + direction
	if borders.has_point(target_position):
		steps_since_turn += 1
		position = target_position
		return true
	else:
		return false

func change_direction():
	place_room(position)
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not borders.has_point(position + direction):
		direction = directions.pop_front()

func create_room(position, size):
	return {position = position, size = size}

func place_room(position):
	var size = Vector2i(1, 1)
	var top_left_corner = Vector2i(position.x - size.x/2, position.y - size.y/2)
	rooms.append(create_room(position, size))
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2i(x, y)
			if borders.has_point(new_step):
				step_history.append(new_step)
				road_history.append(new_step)

func get_exit_positions():
	return exits

func _generate_exit(direction: Vector2i):
	var exit_tiles = []
	var success = false
	var tries = 0
	
	while not success and tries < 10:
		exit_tiles.clear()
		var exit_position: Vector2i
		var max_range: Array
		
		match direction:
			Vector2i.RIGHT:
				exit_position = Vector2i(0, randi_range(borders.position.y, borders.size.y))
				max_range = range(((borders.size.x + (outer_borders * 2)) - 1) / 3)
			Vector2i.LEFT:
				exit_position = Vector2i((borders.size.x + (outer_borders * 2)) - 1, randi_range(borders.position.y, borders.size.y))
				max_range = range(((borders.size.x + (outer_borders * 2)) - 1) / 3)
			Vector2i.DOWN:
				exit_position = Vector2i(randi_range(borders.position.x, borders.size.x), 0)
				max_range = range(((borders.size.y + (outer_borders * 2)) - 1) / 3)
			Vector2i.UP:
				exit_position = Vector2i(randi_range(borders.position.x, borders.size.x), (borders.size.y + (outer_borders * 2)) - 1)
				max_range = range(((borders.size.y + (outer_borders * 2)) - 1) / 3)
			_:
				return
		
		for border_tile in range(((borders.size.x + (outer_borders * 2)) - 1) / 3):
			exit_tiles.append(exit_position)
			exit_position += direction

			if step_history.has(exit_position):
				success = true
				exit_tiles.append(exit_position)
				exits.append(exit_tiles.front())
				for exit in exit_tiles:
					step_history.append(exit)
				return
		
		tries += 1
		
func generate_all_exits():
	_generate_exit(Vector2i.UP)
	_generate_exit(Vector2i.RIGHT)
	_generate_exit(Vector2i.DOWN)
	_generate_exit(Vector2i.LEFT)

func generate_random_exits():
	var directions = DIRECTIONS.duplicate()
	directions.shuffle()
	var exit_count = randi_range(1, 4)
	for i in range(exit_count):
		_generate_exit(directions[i])
