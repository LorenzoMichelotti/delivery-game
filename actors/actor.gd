class_name Actor
extends CharacterBody2D

@export var type: GlobalConstants.ACTOR_TYPES

@onready var sprite_pivot = $SpritePivot
@onready var sprite = $SpritePivot/Sprite2D
@onready var alive_module: AliveModule = $AliveModule
@onready var shadow: Sprite2D = $Shadow
