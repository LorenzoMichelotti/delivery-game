extends Camera2D

var _following

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _following != null:
		global_position = _following.global_position

func set_pawn_to_follow(pawn: Node2D):
	_following = pawn
