class_name Bullet
extends ActorInanimate

@export var bullet_speed: GlobalConstants.BULLET_SPEED = GlobalConstants.BULLET_SPEED.FAST
@export var direction: Vector2 = Vector2.RIGHT
@export var piercing: int = 0

@onready var damage_dealer_module: DamageDealerModule = $DamageDealerModule

var speed: float
var friction: float
var acceleration: float

var current_speed := 0
var lifespan := 5.0
var decaying = false

func _ready():
	speed = GlobalConstants.BULLET_SPEEDS[bullet_speed].speed
	friction = GlobalConstants.BULLET_SPEEDS[bullet_speed].friction
	acceleration = GlobalConstants.BULLET_SPEEDS[bullet_speed].acceleration
	
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
