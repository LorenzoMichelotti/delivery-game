extends Node

enum CHANNEL_CONFIG {
	BASIC,
	HITS,
	EXPLOSIONS,
	SPIKES
} 

const BUS_CONFIG = {
	CHANNEL_CONFIG.BASIC: "Master",
	CHANNEL_CONFIG.SPIKES: "Master",
	CHANNEL_CONFIG.HITS: "Explosions",
	CHANNEL_CONFIG.EXPLOSIONS: "Explosions",
} 

var channels = {
	CHANNEL_CONFIG.BASIC: [null, null, null, null, null],
	CHANNEL_CONFIG.HITS: [null, null],
	CHANNEL_CONFIG.EXPLOSIONS: [null, null],
	CHANNEL_CONFIG.SPIKES: [null]
}

func play_sfx(stream: AudioStreamWAV, playback_channel = CHANNEL_CONFIG.BASIC):
	for i in range(channels[playback_channel].size()):
		if channels[playback_channel][i] == null:
			channels[playback_channel][i] = AudioStreamPlayer2D.new()
			channels[playback_channel][i].attenuation = .2
			channels[playback_channel][i].bus = BUS_CONFIG[playback_channel]
			add_child(channels[playback_channel][i])
			print("created basic audiostream channel")
		var channel: AudioStreamPlayer2D = channels[playback_channel][i]
		if not channel.playing:
			channel.stream = stream
			channel.play()
			return
