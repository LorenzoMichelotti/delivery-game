extends Panel

var mouse_inside = false
var dragging = false
var offset_position: Vector2

func _process(delta):
	if Input.is_action_just_pressed("click") and mouse_inside:
		offset_position =  get_parent().get_local_mouse_position() - position
		dragging = true
	if Input.is_action_just_released("click"):
		dragging = false
	if dragging:
		position = get_parent().get_local_mouse_position() - offset_position

func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false
