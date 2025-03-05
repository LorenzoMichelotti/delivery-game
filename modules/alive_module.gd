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
@export var type: GlobalConstants.ACTOR_TYPES

@onready var actor
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
	hp = max_hp


func take_damage(damage: int, perpetrator: GlobalConstants.ACTOR_TYPES, is_knockup: bool = true) -> bool:
	if is_dead or not _should_take_damage(perpetrator):
		return false
	
	if not is_knockup:
		VfxManager.display_number(str(damage).pad_zeros(2), actor.global_position)
	
	if has_invincibility or is_taking_damage:
		return true # absorb bullets
	
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
	
	VfxManager.display_explosion_effect(actor.global_position)
	SfxManager.play_sfx(hit_sfx_stream, SfxManager.CHANNEL_CONFIG.HITS)
	
	var shader = actor.sprite.material as ShaderMaterial
	shader.set_shader_parameter("active", true)
	
	if not can_be_knocked_down or not is_knockup:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(actor, "global_position", actor.global_position, 0.4)
		tween.finished.connect(tween.kill)
		await tween.finished
		shader.set_shader_parameter("active", false)
		return
	
	var knockdown_position = actor.global_position
	var knockup_position = Vector2(actor.global_position.x, actor.global_position.y - 10)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(actor, "global_position", knockup_position, 0.2)
	tween.parallel().tween_property(actor.sprite_pivot, "rotation", TAU, 0.3)
	tween.tween_property(actor, "global_position", knockdown_position, 0.1)
	tween.finished.connect(tween.kill)
	await tween.finished
	shader.set_shader_parameter("active", false)
	
	actor.sprite_pivot.rotation = 0
	
	
func _play_death_tweener(perpetrator):
	var knockup_position = _get_random_knockup_position()
	var knockdown_position = _get_random_knockdown_position(knockup_position)
	VfxManager.display_explosion_effect(actor.global_position)
	SfxManager.play_sfx(hit_sfx_stream, SfxManager.CHANNEL_CONFIG.HITS)
	
	var shader = actor.sprite.material as ShaderMaterial
	shader.set_shader_parameter("active", true)
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(actor.sprite_pivot, "global_position", knockup_position, 0.2)
	tween.parallel().tween_property(actor.sprite_pivot, "rotation", TAU/2, 0.3)
	tween.chain().tween_property(actor.sprite_pivot, "global_position", knockdown_position, 0.1)
	
	await tween.finished
	shader.set_shader_parameter("active", false)
	
	SfxManager.play_sfx(explosion_sfx_stream, SfxManager.CHANNEL_CONFIG.EXPLOSIONS)
	VfxManager.display_explosion_effect(knockdown_position)
	
	if perpetrator == GlobalConstants.ACTOR_TYPES.PLAYER and on_death_points > 0:
		VfxManager.display_number(str(on_death_points), knockdown_position)
		PlayerManager.add_points(on_death_points)
	
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(actor.sprite_pivot, "modulate", Color.BLACK, 0.1)
	tween.parallel().tween_property(actor.sprite_pivot, "modulate:a", 0, 0.6)  # Fade out effect
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
