class_name DamageDealerModule
extends Node2D

@export var enabled = true
@export var damage = 1
@export var type: GlobalConstants.ACTOR_TYPES
@export var is_knockup = true
@export var is_bullet = false

@onready var hurt_box: Area2D = $HurtBox

func _ready():
	hurt_box.area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if enabled and area.is_in_group("hit_box") and area.get_parent():
		if (area.get_parent() as AliveModule).take_damage(damage, type, is_knockup, get_parent()) and is_bullet:
			get_parent().queue_free()
