class_name AliveModule
extends Node2D

@export var max_hp := 1
@export var should_free_on_dead := true
@export var can_be_knocked_down := true
@export var damage_stun_amount := .2
@export var invincibility_amount := .3
@export var on_death_points := 0
@export var hit_sfx_stream = preload("res://assets/sounds/Hit.wav")
@export var explosion_sfx_stream = preload("res://assets/sounds/Explode.wav")

@onready var actor
@onready var type: GlobalConstants.ACTOR_TYPES
@onready var hit_box: Area2D = $HitBox

var hp := 1
var is_dead := false
var is_taking_damage := false
var has_invincibility := false
signal died

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	actor = get_parent()
	type = actor.type
	hp = max_hp


func take_damage(damage: int, perpetrator: GlobalConstants.ACTOR_TYPES, is_knockup: bool = true, damage_dealer = null) -> bool:
	if is_dead or not _should_take_damage(perpetrator):
		return false
	
	if not is_knockup:
		VfxManager.display_number(str(damage).pad_zeros(2), actor.global_position, Color.RED)
		SfxManager.play_sfx(hit_sfx_stream, SfxManager.CHANNEL_CONFIG.HITS, true)
		VfxManager.display_explosion_effect(actor.global_position)
		CameraManager.apply_shake()
	
	if has_invincibility or is_taking_damage:
		return true # absorb bullets
	
	if type == GlobalConstants.ACTOR_TYPES.PLAYER:
		CameraManager.apply_quick_zoom()
	
	var new_hp = hp - damage
	if new_hp <= 0:
		die(perpetrator)
		return true
	
	hp = new_hp
	
	_play_hit_tweener(is_knockup)
	return true


func die(perpetrator):
	hp = 0
	is_dead = true
	died.emit()
	
	_play_death_tweener(perpetrator)

func _play_hit_tweener(is_knockup: bool):
	is_taking_damage = true
	get_tree().create_timer(damage_stun_amount).timeout.connect(_stop_being_stunned)
	
	var shader = actor.sprite.material as ShaderMaterial
	shader.set_shader_parameter("active", true)
	
	if not can_be_knocked_down or not is_knockup:
		await get_tree().create_timer(.4).timeout
		shader.set_shader_parameter("active", false)
		return
	
	if tween:
		tween.kill()
	tween = create_tween()
	
	# actor pivot sprite
	var knockdown_position = actor.sprite_pivot.position
	var knockup_position = Vector2(actor.sprite_pivot.position.x, actor.sprite_pivot.position.y - 10)
	tween.tween_property(actor.sprite_pivot, "position", knockup_position, 0.2)
	tween.parallel().tween_property(actor.sprite_pivot, "rotation", TAU, 0.3)
	
	# actor shadow sprite
	var base_shadow_scale = actor.shadow.scale
	var base_shadow_position = actor.shadow.position
	var base_shadow_alpha = actor.shadow.modulate.a
	tween.parallel().tween_property(actor.shadow, "position", Vector2(knockup_position.x, base_shadow_position.y) , 0.3)
	tween.parallel().tween_property(actor.shadow, "modulate:a", .35 , 0.3)
	tween.parallel().tween_property(actor.shadow, "scale", Vector2(.5, .5) , 0.3)
	
	# actor pivot sprite
	tween.tween_property(actor.sprite_pivot, "position", knockdown_position, 0.1)
	# actor shadow sprite
	tween.parallel().tween_property(actor.shadow, "position", base_shadow_position , 0.3)
	tween.parallel().tween_property(actor.shadow, "modulate:a", base_shadow_alpha , 0.3)
	tween.parallel().tween_property(actor.shadow, "scale", base_shadow_scale , 0.3)
	
	tween.finished.connect(tween.kill)
	await tween.finished
	shader.set_shader_parameter("active", false)
	
	actor.sprite_pivot.rotation = 0
	
	
func _play_death_tweener(perpetrator):
	var knockup_position = _get_random_knockup_position()
	var knockdown_position = _get_random_knockdown_position(knockup_position)
	VfxManager.display_explosion_effect(actor.global_position)
	SfxManager.play_sfx(hit_sfx_stream, SfxManager.CHANNEL_CONFIG.HITS, true)
	
	var shader = actor.sprite.material as ShaderMaterial
	shader.set_shader_parameter("active", true)
	
	if tween:
		tween.kill()
	tween = create_tween()
	
	# explode and tumble
	
	# actor sprite
	tween.tween_property(actor.sprite_pivot, "global_position", knockup_position, 0.2)
	tween.parallel().tween_property(actor.sprite_pivot, "rotation", TAU/2, 0.3)
	# actor shadow sprite
	var base_shadow_scale = actor.shadow.scale
	var base_shadow_alpha = actor.shadow.modulate.a
	tween.parallel().tween_property(actor.shadow, "global_position", Vector2(knockup_position.x, actor.shadow.global_position.y) , 0.3)
	tween.parallel().tween_property(actor.shadow, "modulate:a", .35 , 0.3)
	tween.parallel().tween_property(actor.shadow, "scale", Vector2(.5, .5) , 0.3)
	
	# fall back down
	
	# actor sprite
	tween.tween_property(actor.sprite_pivot, "global_position", knockdown_position, 0.1)
	# actor shadow sprite
	tween.parallel().tween_property(actor.shadow, "global_position", Vector2(knockdown_position.x, knockdown_position.y + 1) , 0.3)
	tween.parallel().tween_property(actor.shadow, "modulate:a", base_shadow_alpha , 0.3)
	tween.parallel().tween_property(actor.shadow, "scale", base_shadow_scale , 0.3)
	
	await tween.finished
	shader.set_shader_parameter("active", false)
	
	SfxManager.play_sfx(explosion_sfx_stream, SfxManager.CHANNEL_CONFIG.EXPLOSIONS, true)
	VfxManager.display_explosion_effect(knockdown_position)
	CameraManager.apply_shake()
	
	if perpetrator == GlobalConstants.ACTOR_TYPES.PLAYER and on_death_points > 0:
		VfxManager.display_number(str(on_death_points), knockdown_position)
		PlayerManager.add_points(on_death_points)
	
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(actor.sprite_pivot, "modulate", Color.BLACK, 0.1)
	tween.parallel().tween_property(actor.sprite_pivot, "modulate:a", 0, 0.6)  # Fade out effect
	tween.parallel().tween_property(actor.shadow, "modulate:a", 0 , .4)
	if should_free_on_dead:
		tween.finished.connect(get_parent().queue_free)  # Remove NPC after fade

func _get_random_knockup_position() -> Vector2:
	return Vector2(actor.global_position.x + randi_range(-8, 8), actor.global_position.y - 10)

func _get_random_knockdown_position(knockup_position: Vector2) -> Vector2:
	return Vector2(knockup_position.x, randi_range(knockup_position.y + 8, knockup_position.y -8))
	
func _should_take_damage(perpetrator: GlobalConstants.ACTOR_TYPES) -> bool:
	match type:
		GlobalConstants.ACTOR_TYPES.ENEMY:
			return false if perpetrator == GlobalConstants.ACTOR_TYPES.ENEMY else true
		GlobalConstants.ACTOR_TYPES.PLAYER:
			return true if perpetrator == GlobalConstants.ACTOR_TYPES.ENEMY or perpetrator == GlobalConstants.ACTOR_TYPES.HAZARD else false
		GlobalConstants.ACTOR_TYPES.FRIEND:
			return true if perpetrator == GlobalConstants.ACTOR_TYPES.ENEMY or perpetrator == GlobalConstants.ACTOR_TYPES.HAZARD else false
	return false

func _stop_being_stunned():
	is_taking_damage = false
	has_invincibility = true
	get_tree().create_timer(invincibility_amount).timeout.connect(_stop_invincibility)

func _stop_invincibility():
	has_invincibility = false
