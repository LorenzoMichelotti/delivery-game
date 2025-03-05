extends Node

enum CHANNEL_CONFIG {
	BASIC,
	HITS,
	EXPLOSIONS,
	SPIKES,
	GUN
} 

const BUS_CONFIG = {
	CHANNEL_CONFIG.BASIC: "Master",
	CHANNEL_CONFIG.GUN: "Master",
	CHANNEL_CONFIG.SPIKES: "Explosions",
	CHANNEL_CONFIG.HITS: "Explosions",
	CHANNEL_CONFIG.EXPLOSIONS: "Explosions",
} 

var channels = {
	CHANNEL_CONFIG.BASIC: [null, null, null, null, null, null],
	CHANNEL_CONFIG.GUN: [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null],
	CHANNEL_CONFIG.HITS: [null, null, null, null],
	CHANNEL_CONFIG.EXPLOSIONS: [null, null],
	CHANNEL_CONFIG.SPIKES: [null, null, null]
}

func play_sfx(stream: AudioStreamWAV, playback_channel = CHANNEL_CONFIG.BASIC, randomize_pitch = false):
	for i in range(channels[playback_channel].size()):
		if channels[playback_channel][i] == null:
			channels[playback_channel][i] = AudioStreamPlayer2D.new()
			channels[playback_channel][i].attenuation = .2
			channels[playback_channel][i].bus = BUS_CONFIG[playback_channel]
			channels[playback_channel][i].pitch_scale = randf_range(.5, 1.5) if randomize_pitch else 1
			add_child(channels[playback_channel][i])
			print("created basic audiostream channel")
		var channel: AudioStreamPlayer2D = channels[playback_channel][i]
		if not channel.playing:
			channel.stream = stream
			channel.play()
			return
