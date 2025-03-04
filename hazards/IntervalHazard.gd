extends Node2D

@export var damage_dealer_module: DamageDealerModule
@export var stream_sfx: AudioStreamWAV = preload("res://assets/sounds/Sword_Slash.wav")
@export var start_delay: float = 0.0

func _ready():
	_set_armed(false)
	get_tree().create_timer(start_delay).timeout.connect(_start)

func _set_armed(armed: bool):
	if armed:
		SfxManager.play_sfx(stream_sfx, SfxManager.CHANNEL_CONFIG.SPIKES)
	damage_dealer_module.enabled = armed

func _start():
	print("abuble")
	$AnimationTree.set("parameters/conditions/enabled", true)
