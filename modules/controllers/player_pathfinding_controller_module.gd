class_name PlayerPathfindingControllerModule
extends BaseControllerModuleResource

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D


func _ready():
	navigation_agent_2d.target_position = get_parent().global_position
	navigation_agent_2d.navigation_finished.connect(_on_nav_finished)
	super()

func _physics_process(delta):
	if not pawn or pawn.alive_module.is_dead or pawn.alive_module.is_taking_damage or not enabled or NavigationServer2D.map_get_iteration_id(navigation_agent_2d.get_navigation_map()) == 0:
		return
	
	get_input_target_position()
	
	if navigation_agent_2d.is_navigation_finished():
		return 
	
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = get_parent().global_position.direction_to(next_path_position) * speed
		
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func _on_nav_finished():
	print("navigation finished")

func get_input_target_position():
	var input = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if input != Vector2.ZERO:
		var new_target_position = get_parent().global_position + input * (GlobalConstants.GRID_SIZE/2 + 1)
		if is_valid_path_length(new_target_position):
			navigation_agent_2d.target_position = get_parent().global_position + input * (GlobalConstants.GRID_SIZE/2 + 1)

func get_random_target_position():
	return NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(), navigation_agent_2d.navigation_layers, false)

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	get_parent().velocity = safe_velocity
	get_parent().move_and_slide()

func is_valid_path_length(target_position: Vector2):
	var previous_point
	var total_path_distance = 0
	
	for point in NavigationServer2D.map_get_path(navigation_agent_2d.get_navigation_map(), get_parent().global_position, target_position, true):
		if previous_point == null:
			previous_point = point
			continue
		total_path_distance += point.distance_to(previous_point)
		if total_path_distance > 20:
			return false
		previous_point = point
	
	if total_path_distance < 2:
		return false
		
	if total_path_distance > 20:
		navigation_agent_2d.target_position = get_parent().global_position
		return false
	return true
