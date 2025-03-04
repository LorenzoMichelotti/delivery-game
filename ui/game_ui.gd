extends Control

@onready var goal_description = $PointsControl/Goal
@onready var goal_value = $PointsControl/GoalValue
@onready var gas_bar_container = $Panel

@onready var health_bar_backdrop = $HealthBarContainer/HealthBarBackDrop
@onready var health_bar = $HealthBarContainer/HealthBarBackDrop/HealthBar
@onready var health_bar_label = $HealthBarContainer/HealthLabel

func _ready():
	show()

func _process(delta):
	update_health_bar()
	update_goals()

func update_goals():
	goal_description.text = GameManager.current_completion_goal.goal_description
	goal_value.text = GameManager.current_completion_goal.get_value()

func update_health_bar():
	health_bar.scale.x = health_bar_backdrop.scale.x * PlayerManager.pawn.alive_module.hp / PlayerManager.pawn.alive_module.max_hp
	health_bar_label.text = str(PlayerManager.pawn.alive_module.hp) + "/" + str(PlayerManager.pawn.alive_module.max_hp)
