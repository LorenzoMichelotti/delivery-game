extends Resource
class_name UpgradeResource

@export var id: int
@export var name: String
var description: String:
	get:
		return "Increases " + name + " by " + str(abs(bonus_value_per_level * (current_level + 1)))
@export var cost: int = 100
@export var current_level: int = 0
@export var max_level: int = 5
@export var bonus_value_per_level: float

func get_value():
	pass
	
func apply():
	pass
	
func remove():
	pass
