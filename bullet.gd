class_name Bullet
extends CharacterBody2D

@export var speed := 200
@export var direction: Vector2 = Vector2.RIGHT
@export var piercing := 0

@onready var damage_dealer_module: DamageDealerModule = $DamageDealerModule

var lifespan: float = 5.0

func _ready():
	get_tree().create_timer(lifespan).timeout.connect(_on_lifespan_timeout)

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()

func _on_lifespan_timeout():
	queue_free()
