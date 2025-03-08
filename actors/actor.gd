class_name Actor
extends CharacterBody2D

@export var type: GlobalConstants.ACTOR_TYPES
@export var phase = 0

@onready var sprite_pivot = $SpritePivot
@onready var sprite = $SpritePivot/Sprite2D
@onready var alive_module: AliveModule = $AliveModule
@onready var shadow: Sprite2D = $Shadow

func _ready():
	alive_module.took_damage.connect(_on_take_damage)
	set_phase(phase)
	
func _on_take_damage():
	if alive_module.hp < alive_module.max_hp * 1/3:
		set_phase(2)
		return
	if alive_module.hp < alive_module.max_hp * 2/3:
		# phase 1
		set_phase(1)
		return
		
func set_phase(new_phase):
	if phase == new_phase:
		return
	phase = new_phase
	sprite.frame = phase
