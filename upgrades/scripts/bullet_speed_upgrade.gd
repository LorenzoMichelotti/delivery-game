extends UpgradeResource
class_name BulletSpeedUpgradeResource

@export var bullet_speed: GlobalConstants.BULLET_SPEED = GlobalConstants.BULLET_SPEED.SLOW

func get_value():
	return bonus_value_per_level
	
func apply():
	PlayerManager.attributes.bullet_speed = bullet_speed
	PlayerManager.pawn.gun_turret_module.bullet_speed = bullet_speed
