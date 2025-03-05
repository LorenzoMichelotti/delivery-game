class_name Bullet
extends ActorInanimate

@export var speed: float= 200.0
@export var friction: float = 8
@export var acceleration: float = 70
@export var direction: Vector2 = Vector2.RIGHT
@export var piercing: int = 0

@onready var damage_dealer_module: DamageDealerModule = $DamageDealerModule

var current_speed := 0
var lifespan := 5.0
var decaying = false

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
	if decaying:
		current_speed -= friction
		if current_speed <= 0:
			damage_dealer_module.disable()
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 0, .1)
			tween.parallel().tween_property(self, "scale", Vector2.ZERO, .2)
			await tween.finished
			queue_free()
	else:
		current_speed += acceleration
		if current_speed >= speed:
			decaying = true
	velocity = direction * current_speed
	rotation = direction.angle()
	move_and_slide()

func _on_lifespan_timeout():
	queue_free()
