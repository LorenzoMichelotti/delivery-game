class_name Bullet
extends ActorInanimate

@export var speed := 200
@export var direction: Vector2 = Vector2.RIGHT
@export var piercing := 0

@onready var damage_dealer_module: DamageDealerModule = $DamageDealerModule

var lifespan: float = 5.0

func _ready():
	get_tree().create_timer(lifespan).timeout.connect(_on_lifespan_timeout)
	damage_dealer_module.type = type
	match type:
		GlobalConstants.ACTOR_TYPES.PLAYER:
			sprite.frame = 0
		GlobalConstants.ACTOR_TYPES.ENEMY:
			sprite.frame = 2
		GlobalConstants.ACTOR_TYPES.HAZARD:
			sprite.frame = 2
		GlobalConstants.ACTOR_TYPES.FRIEND:
			sprite.frame = 0

func _physics_process(delta):
	velocity = direction * speed
	rotation = direction.angle()
	move_and_slide()

func _on_lifespan_timeout():
	queue_free()
