class_name CompletionRequirementResource
extends Resource

@export var goal_description: String
@export var gas_enabled = true
@export var npc_count = 5

func apply_modifiers():
	PlayerManager.gas_enabled = gas_enabled
	GameManager.npc_count = npc_count

func verify_completion_requirement_met():
	return false

func get_value() -> String:
	return "IDC"
