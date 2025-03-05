extends Camera2D

var _following

@export var shake_fade: float = 10.0

@onready var rand = RandomNumberGenerator.new()

var shake_strength: float = 0.0
var tween

func _ready() -> void:
	rand.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _following != null:
		global_position = _following.global_position
		
		if shake_strength > 0:
			shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
			
			offset = _get_random_offset(delta)

func set_pawn_to_follow(pawn: Node2D):
	_following = pawn

func apply_shake(random_strength: float = 1.0) -> void:
	shake_strength = random_strength
	
func apply_quick_zoom() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	
	var default_zoom = zoom
	tween.tween_property(self, "zoom", Vector2(default_zoom.x + 2, default_zoom.y + 2), .2)
	tween.tween_property(self, "zoom", default_zoom, .1)

func _get_random_offset(delta: float) -> Vector2:
	return Vector2(rand.randf_range(-shake_strength,shake_strength), rand.randf_range(-shake_strength,shake_strength))
	
