class_name PathfindingControllerModule
extends BaseControllerModuleResource

@onready var navigation_agent_2d = $NavigationAgent2D

func _ready():
	super()

func _physics_process(delta):
	
	if NavigationServer2D.map_get_iteration_id(navigation_agent_2d.get_navigation_map()) == 0:
		return
	if navigation_agent_2d.is_navigation_finished():
		navigation_agent_2d.target_position = get_random_target_position()
	
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = pawn.global_position.direction_to(next_path_position) * speed
		
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func get_random_target_position():
	return NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(), navigation_agent_2d.navigation_layers, false)

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	pawn.velocity = safe_velocity
	pawn.move_and_slide()
