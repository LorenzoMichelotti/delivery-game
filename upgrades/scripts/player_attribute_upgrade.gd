extends UpgradeResource
class_name  PlayerAttributeUpgradeResource

@export var attribute: String

func get_value():
	return bonus_value_per_level
	
func apply():
	PlayerManager.attributes.set(attribute, PlayerManager.attributes.get(attribute) + floor(bonus_value_per_level))
	
func remove():
	PlayerManager.attributes.set(attribute, PlayerManager.attributes.get(attribute) - floor(bonus_value_per_level))
