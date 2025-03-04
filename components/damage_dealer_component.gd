extends Node2D

@export var damage := 1
@export var type: GlobalConstants.ACTOR_TYPES

@onready var hurt_box: Area2D = $HurtBox

func _ready():
	hurt_box.area_entered.connect(_on_are_entered)

func _on_are_entered(area):
	if area.is_in_group("hit_box"):
		(area.get_parent() as AliveComponent).take_damage(damage, type)
