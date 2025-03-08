class_name ActorInanimate
extends CharacterBody2D

@export var type: GlobalConstants.ACTOR_TYPES

@onready var sprite_pivot : Node2D = $SpritePivot
@onready var sprite : Sprite2D = $SpritePivot/Sprite2D
