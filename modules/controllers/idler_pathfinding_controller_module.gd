class_name IdlerPathfindingControllerModule
extends BaseControllerModuleResource

enum STATES {
	WALKING,
	PICKING,
	DELIVERING,
	HUNTING,
	ROBBING,
	EXITING
}

@export var state: STATES

@onready var navigation_agent_2d = $NavigationAgent2D

func _ready():
	super()


func _physics_process(delta):
	if not pawn or pawn.alive_module.is_dead or pawn.alive_module.is_taking_damage or not enabled or NavigationServer2D.map_get_iteration_id(navigation_agent_2d.get_navigation_map()) == 0:
		return
		
	#navigation_agent_2d.target_desired_distance = 1
	$Label.text = STATES.keys()[state]
	
	state_machine()
	
	var is_at_target_desired_distance = pawn.global_position.distance_to(navigation_agent_2d.target_position) - navigation_agent_2d.target_desired_distance <= 0.0
	if is_at_target_desired_distance:
		navigation_agent_2d.set_velocity(Vector2.ZERO)
	else:
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var new_velocity = pawn.global_position.direction_to(next_path_position) * speed
			
		if navigation_agent_2d.avoidance_enabled:
			navigation_agent_2d.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)


func state_machine():
	match state:
		STATES.WALKING:
			navigation_agent_2d.target_desired_distance = 1
			if LevelManager.current_goal_achieved:
				state = STATES.EXITING
				return
			if LevelManager.current_completion_requirements.level_modifiers.deliveries_enabled and EntityManager.get_closest_pickup_position(pawn.global_position) != null:
				if LevelManager.current_completion_requirements.level_modifiers.mobile_delivery:
					state = STATES.ROBBING
					return
				state = STATES.PICKING
				return
			if EntityManager.get_closest_tank_position(pawn.global_position) != null:
				state =STATES.HUNTING
				return
			if navigation_agent_2d.is_navigation_finished():
				navigation_agent_2d.target_position = get_random_target_position()
				return
		STATES.PICKING:
			navigation_agent_2d.target_desired_distance = 1
			if PlayerManager.inventory_delivery_ids.size() > 0:
				state = STATES.DELIVERING
				return
			var pickup_position = EntityManager.get_closest_pickup_position(pawn.global_position)
			if pickup_position == null:
				state = STATES.WALKING
				return
			navigation_agent_2d.target_position = pickup_position
		STATES.ROBBING:
			var truck_position = EntityManager.get_closest_truck_position(pawn.global_position)
			if truck_position == null:
				state = STATES.PICKING
				return
			navigation_agent_2d.target_desired_distance = 20
			navigation_agent_2d.target_position = truck_position
		STATES.DELIVERING:
			navigation_agent_2d.target_desired_distance = 1
			if PlayerManager.inventory_delivery_ids.size() <= 0:
				state = STATES.WALKING
				return
			var new_delivery_position = EntityManager.get_closest_delivery_position(pawn.global_position, PlayerManager.inventory_delivery_ids)
			if new_delivery_position == null:
				state = STATES.WALKING
				return
			navigation_agent_2d.target_position = new_delivery_position if new_delivery_position != null else navigation_agent_2d.target_position
		STATES.EXITING:
			if not LevelManager.current_goal_achieved:
				state = STATES.WALKING
				return
			var tunnel_position = EntityManager.get_closest_tunnel_position(pawn.global_position)
			if tunnel_position == null:
				state = STATES.WALKING
				return
			navigation_agent_2d.target_position = tunnel_position if tunnel_position != null else navigation_agent_2d.target_position
		STATES.HUNTING:
			var tank_position = EntityManager.get_closest_tank_position(pawn.global_position)
			if tank_position == null:
				state = STATES.WALKING
				return
			navigation_agent_2d.target_desired_distance = 25
			navigation_agent_2d.target_position = tank_position if tank_position != null else navigation_agent_2d.target_position

func get_random_target_position():
	return NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(), navigation_agent_2d.navigation_layers, false)


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	pawn.velocity = safe_velocity
	pawn.move_and_slide()
