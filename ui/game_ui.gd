extends Control

@onready var goal_description = $PointsControl/Goal
@onready var goal_value = $PointsControl/GoalValue
@onready var gas_bar_container = $Panel

@onready var health_bar_backdrop = $HealthBarContainer/HealthBarBackDrop
@onready var health_bar = $HealthBarContainer/HealthBarBackDrop/HealthBar
@onready var health_bar_label = $HealthBarContainer/HealthLabel
@onready var point_multiplier = $PointsControl/PointMultiplier

func _ready():
	PlayerManager.point_multiplier_changed.connect(update_multiplier)
	PlayerManager.gas_enabled_changed.connect(hide_gasbar_if_gas_disabled)
	show()

func _process(delta):
	update_health_bar()
	update_goals()

func hide_gasbar_if_gas_disabled(enabled: bool):
	if enabled:
		gas_bar_container.show()
	else:
		gas_bar_container.hide()

func update_goals():
	if LevelManager.current_completion_requirements == null:
		return
	goal_description.text = LevelManager.current_completion_requirements.goal_description
	goal_value.text = LevelManager.current_completion_requirements.get_value()

func update_health_bar():
	if PlayerManager.pawn == null:
		return
	health_bar.scale.x = health_bar_backdrop.scale.x * PlayerManager.current_hp / PlayerManager.max_hp
	health_bar_label.text = str(PlayerManager.current_hp) + "/" + str(PlayerManager.max_hp)

func update_multiplier(new_multiplier: int):
	point_multiplier.text = "X" + str(new_multiplier)
	
	var tween = create_tween()
	tween.tween_property(point_multiplier, "scale", Vector2.ONE * (1 + clamp(new_multiplier/5, 0.2, 1)), .1)
	tween.parallel().tween_property(point_multiplier, "rotation", deg_to_rad(-5), .1)
	tween.tween_property(point_multiplier, "scale", Vector2.ONE * (1 + clamp(new_multiplier/5, 0.1, .5)), .05)
	tween.parallel().tween_property(point_multiplier, "rotation", deg_to_rad(0), .05)
	tween.finished.connect(tween.kill)
