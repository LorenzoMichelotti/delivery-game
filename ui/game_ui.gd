extends Control

@onready var goal_description = $PointsControl/Goal
@onready var goal_value = $PointsControl/GoalValue
@onready var gas_bar_container = $Panel

func _ready():
	show()

func _process(delta):
	update_goals()

func update_goals():
	goal_description.text = GameManager.current_completion_goal.goal_description
	goal_value.text = GameManager.current_completion_goal.get_value()
