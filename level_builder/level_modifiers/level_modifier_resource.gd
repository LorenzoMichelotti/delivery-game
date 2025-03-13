class_name LevelModifierResource
extends Resource

@export var deliveries_enabled = true
@export var gas_enabled = false
@export var random_gas_enabled = false
@export var npc_count = 3
@export var tank_count = 5
@export var player_gun_turret = false

func apply_modifiers():
	PlayerManager.gas_enabled = gas_enabled
	PlayerManager.pawn.get_node("GunTurretModule").enabled = player_gun_turret
	GameManager.random_gas_enabled = random_gas_enabled
	GameManager.npc_count = npc_count
	GameManager.random_deliveries_enabled = deliveries_enabled
