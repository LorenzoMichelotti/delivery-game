class_name LevelModifierResource
extends Resource

@export var deliveries_enabled = true
@export var mobile_delivery = false
@export var concurrent_deliveries = 1
@export var gas_enabled = false
@export var random_gas_enabled = false
@export var player_gun_turret = false

@export var npc_count = 3
@export var randomize_npc_count = false
@export var tank_count = 5
@export var randomize_tank_count = false

func apply_modifiers():
	PlayerManager.gas_enabled = gas_enabled
	PlayerManager.pawn.get_node("GunTurretModule").enabled = player_gun_turret
