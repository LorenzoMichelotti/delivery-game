class_name LevelModifierResource
extends Resource

@export var gas_enabled = false
@export var random_gas_enabled = false
@export var npc_count = 3

func apply_modifiers():
	PlayerManager.gas_enabled = gas_enabled
	GameManager.random_gas_enabled = random_gas_enabled
	GameManager.npc_count = npc_count
