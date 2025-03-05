class_name ActorInanimate
extends CharacterBody2D

@export var type: GlobalConstants.ACTOR_TYPES

@onready var sprite_pivot = $SpritePivot
@onready var sprite = $SpritePivot/Sprite2D
