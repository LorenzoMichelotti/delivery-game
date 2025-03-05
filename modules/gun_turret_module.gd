extends Node2D

@export var stream_sfx: AudioStreamWAV = preload("res://assets/sounds/Gun.wav")
@export var shoot_delay = 0.3
@export var enabled = true
@export var damage = 10
@export var bullet_speed = 200
@export var automatic_aim = true
@export var automatic_shoot = true

@onready var type: GlobalConstants.ACTOR_TYPES
@onready var bullet_scene = preload("res://modules/bullet.tscn")
@onready var animation_tree = $AnimationTree
@onready var bullet_hole_pivot = $BulletHolePivot
@onready var bullet_hole = $BulletHolePivot/bullet_hole
@onready var crosshair_pivot = $CrossHairPivot
@onready var area_range = $Range

var can_shoot = true
var enemies_in_range: Array[Node2D] = []
var closest_enemy_in_range: Node2D
var actor: Actor

func _ready():
	actor = get_parent()
	type = actor.type
	crosshair_pivot.modulate = GlobalConstants.ACTOR_COLORS[type]


func _process(delta):
	if not enabled or actor.alive_module.is_dead:
		animation_tree.set("parameters/conditions/appear", false)
		animation_tree.set("parameters/conditions/disappear", true)
		return
	update_animations()
	if can_shoot and (automatic_shoot or (type == GlobalConstants.ACTOR_TYPES.PLAYER and Input.is_action_pressed("space"))):
		_shoot.call_deferred()


func _shoot():
	can_shoot = false
	get_tree().create_timer(shoot_delay).timeout.connect(_set_can_shoot)
	var bullet: Bullet = bullet_scene.instantiate()
	if automatic_aim:
		if closest_enemy_in_range == null:
			return
		bullet.direction = (closest_enemy_in_range.global_position - bullet_hole.global_position).normalized()
	else:
		bullet.direction = (get_global_mouse_position() - bullet_hole.global_position).normalized()
	SfxManager.play_sfx(stream_sfx, SfxManager.CHANNEL_CONFIG.GUN, true)
	bullet.speed = bullet_speed
	bullet.global_position = bullet_hole.global_position
	bullet.type = type
	get_tree().current_scene.get_node("Entities").add_child(bullet)
	bullet.damage_dealer_module.damage = damage


func _set_can_shoot():
	can_shoot = true


func update_animations():
	_update_crosshair_animation()
	if automatic_aim:
		if closest_enemy_in_range == null:
			return
		var dir = (closest_enemy_in_range.global_position - bullet_hole.global_position).normalized()
		animation_tree.set("parameters/DirectionBlendSpace/blend_position", dir)
		bullet_hole_pivot.rotation = lerp_angle(bullet_hole_pivot.rotation, bullet_hole.global_position.angle_to_point(closest_enemy_in_range.global_position), get_process_delta_time() * 5)
		return
	var dir = (get_global_mouse_position() - global_position).normalized()
	animation_tree.set("parameters/DirectionBlendSpace/blend_position", dir)
	bullet_hole_pivot.rotation = lerp_angle(bullet_hole_pivot.rotation, global_position.angle_to_point(get_global_mouse_position()), get_process_delta_time() * 5)


func _update_crosshair_animation():
	if automatic_aim:
		# go to closest enemy
		closest_enemy_in_range = _get_closest_enemy_in_range()
		if closest_enemy_in_range != null:
			animation_tree.set("parameters/conditions/appear", true)
			animation_tree.set("parameters/conditions/disappear", false)
			crosshair_pivot.global_position = lerp(crosshair_pivot.global_position, closest_enemy_in_range.global_position, get_process_delta_time() * 40)
		else:
			animation_tree.set("parameters/conditions/appear", false)
			animation_tree.set("parameters/conditions/disappear", true)
		return
	# go to mouse position
	animation_tree.set("parameters/conditions/appear", true)
	animation_tree.set("parameters/conditions/disappear", false)
	crosshair_pivot.global_position = lerp(crosshair_pivot.global_position, get_global_mouse_position(), get_process_delta_time() * 40)
	
	
func _get_closest_enemy_in_range():
	var closest_enemy = null
	var closest_distance = null
	for enemy in enemies_in_range:
		var new_distance = global_position.distance_to(enemy.global_position)
		if closest_distance == null or new_distance < closest_distance:
			closest_distance = new_distance
			closest_enemy = enemy
	return closest_enemy


func _on_range_body_entered(area):
	if not enemies_in_range.has(area) and area.is_in_group("hit_box") and area.get_parent()._should_take_damage(type):
		area.get_parent().died.connect(_on_range_body_exited.bind(area))
		enemies_in_range.append(area)


func _on_range_body_exited(area):
	if enemies_in_range.has(area) and area.is_in_group("hit_box") and area.get_parent()._should_take_damage(type):
		area.get_parent().died.disconnect(_on_range_body_exited.bind(area))
		enemies_in_range.erase(area)
