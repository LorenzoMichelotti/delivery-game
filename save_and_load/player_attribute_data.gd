extends Resource
class_name PlayerAttributeData

@export var bullet_speed = GlobalConstants.BULLET_SPEED.SLOW
@export var money = 0

@export var base_damage = 100
@export var base_max_gas = 100
@export var base_max_hp = 3
@export var base_initial_gas_usage = 3
@export var base_point_multiplier = 1
@export var base_multiplier_timer = 60
@export var base_speed = 50
@export var base_attack_speed = 0

@export var bonus_damage = 0
@export var bonus_max_gas = 0
@export var bonus_max_hp = 0
@export var bonus_initial_gas_usage = 0
@export var bonus_point_multiplier = 0
@export var bonus_multiplier_timer = 0
@export var bonus_speed = 0
@export var bonus_attack_speed = 0

@export var upgrade_data: Upgrades = Upgrades.new()
