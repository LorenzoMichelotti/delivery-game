extends Node2D

@export var damage_dealer_module: DamageDealerModule
@export var stream_sfx: AudioStreamWAV = preload("res://assets/sounds/Sword_Slash.wav")
@export var interval_delay: float = 2.0

func _ready():
	_set_armed(false)
	get_tree().create_timer(interval_delay).timeout.connect(_start)

func _set_armed(armed: bool):
	if armed:
		$AnimationTree.set("parameters/conditions/enabled", false)
		get_tree().create_timer(interval_delay).timeout.connect(_start)
		SfxManager.play_sfx(stream_sfx, SfxManager.CHANNEL_CONFIG.SPIKES)
	damage_dealer_module.enabled = armed

func _start():
	$AnimationTree.set("parameters/conditions/enabled", true)
