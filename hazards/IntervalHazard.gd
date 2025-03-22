extends Node2D

@export var damage_dealer_module: DamageDealerModule
@export var stream_sfx: AudioStreamWAV = preload("res://assets/sounds/Sword_Slash.wav")
@export var interval_delay: float = 2.0
@export var random_position: bool = false
@export var shake_screen: bool = false

func _ready():
	_set_armed(false)
	get_tree().create_timer(interval_delay).timeout.connect(_start)

func _set_armed(armed: bool):
	if armed:
		for area in damage_dealer_module.hurt_box.get_overlapping_areas():
			if area.get_parent() is AliveModule:
				damage_dealer_module.deal_damage(area.get_parent())
		$AnimationTree.set("parameters/conditions/enabled", false)
		get_tree().create_timer(interval_delay).timeout.connect(_start)
		SfxManager.play_sfx(stream_sfx, SfxManager.CHANNEL_CONFIG.SPIKES)
		if shake_screen: CameraManager.apply_shake(2)
	damage_dealer_module.enabled = armed

func _start():
	if get_tree().paused:
		return
	if random_position:
		global_position = LevelManager.tile_map_layer.map_to_local(LevelManager.road_positions.pick_random())
	$AnimationTree.set("parameters/conditions/enabled", true)
