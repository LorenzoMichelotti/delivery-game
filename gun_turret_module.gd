extends Node2D

@onready var bullet_scene = preload("res://modules/bullet.tscn")
@onready var animation_tree = $AnimationTree
@onready var bullet_hole_pivot = $BulletHolePivot
@onready var bullet_hole = $BulletHolePivot/bullet_hole
@export var shoot_delay = 0.3
@export var enabled = true
@export var damage = 10

var can_shoot = true

func _process(delta):
	if not enabled:
		return
	update_animation()
	if can_shoot and Input.is_action_pressed("click"):
		_shoot.call_deferred()


func _shoot():
	can_shoot = false
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_hole.global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().current_scene.get_node("Entities").add_child(bullet)
	bullet.damage_dealer_module.damage = damage
	get_tree().create_timer(shoot_delay).timeout.connect(_set_can_shoot)

func _set_can_shoot():
	can_shoot = true


func update_animation():
	var dir = (get_global_mouse_position() - global_position).normalized()
	animation_tree.set("parameters/blend_position", dir)
	bullet_hole_pivot.rotation = lerp_angle(bullet_hole_pivot.rotation, global_position.angle_to_point(get_global_mouse_position()), get_process_delta_time() * 5)
