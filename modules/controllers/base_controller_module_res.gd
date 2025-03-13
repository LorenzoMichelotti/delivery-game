class_name BaseControllerModuleResource
extends Node

@export var enabled := true
@export var speed: float = 50.0  

@onready var pawn: Actor

var current_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var moving: bool = false

func _ready():
	pawn = get_parent()
	target_position = pawn.global_position
