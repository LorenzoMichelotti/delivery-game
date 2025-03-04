class_name AliveModule
extends Node2D

@export var max_hp := 1
@export var on_death_points := 0
@export var hit_sfx_stream = preload("res://assets/sounds/Hit.wav")
@export var explosion_sfx_stream = preload("res://assets/sounds/Explode.wav")
@export var type: GlobalConstants.ACTOR_TYPES

@onready var actor
@onready var hit_box: Area2D = $HitBox

var hp := 1
var is_dead := false
var is_taking_damage := false
signal died

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	actor = get_parent()
	hp = max_hp


func take_damage(damage: int, perpetrator: GlobalConstants.ACTOR_TYPES):
	if is_dead or is_taking_damage or GameManager.is_game_paused() or not _should_take_damage(perpetrator):
		return
	
	var new_hp = hp - damage
	if new_hp <= 0:
		die()
		return
	
	hp = new_hp
	_play_hit_tweener()


func die():
	hp = 0
	is_dead = true
	died.emit()
	
	_play_death_tweener()

func _play_hit_tweener():
	is_taking_damage = true
	var knockup_position = Vector2(actor.global_position.x, actor.global_position.y - 10)
	var knockdown_position = actor.global_position
	VfxManager.display_explosion_effect(actor.global_position)
	SfxManager.play_sfx(hit_sfx_stream, SfxManager.CHANNEL_CONFIG.HITS)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(actor, "global_position", knockup_position, 0.2)
	tween.parallel().tween_property(actor.sprite_pivot, "rotation", TAU, 0.3)
	tween.tween_property(actor, "global_position", knockdown_position, 0.1)
	tween.finished.connect(tween.kill)
	await tween.finished
	actor.sprite_pivot.rotation = 0
	is_taking_damage = false
	
func _play_death_tweener():
	var knockup_position = _get_random_knockup_position()
	var knockdown_position = _get_random_knockdown_position(knockup_position)
	VfxManager.display_explosion_effect(actor.global_position)
	SfxManager.play_sfx(hit_sfx_stream, SfxManager.CHANNEL_CONFIG.HITS)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(actor.sprite_pivot, "global_position", knockup_position, 0.2)
	tween.parallel().tween_property(actor.sprite_pivot, "rotation", TAU/2, 0.3)
	tween.chain().tween_property(actor.sprite_pivot, "global_position", knockdown_position, 0.1)
	
	await tween.finished
	
	SfxManager.play_sfx(explosion_sfx_stream, SfxManager.CHANNEL_CONFIG.EXPLOSIONS)
	VfxManager.display_explosion_effect(knockdown_position)
	
	if on_death_points > 0:
		VfxManager.display_number(str(on_death_points), knockdown_position)
		PlayerManager.add_points(on_death_points)
	
	tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(actor.sprite_pivot, "modulate", Color.BLACK, 0.1)
	tween.parallel().tween_property(actor.sprite_pivot, "modulate:a", 0, 0.6)  # Fade out effect
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
			return true if perpetrator == GlobalConstants.ACTOR_TYPES.ENEMY else false
		GlobalConstants.ACTOR_TYPES.FRIEND:
			return true if perpetrator == GlobalConstants.ACTOR_TYPES.ENEMY else false
	return false
