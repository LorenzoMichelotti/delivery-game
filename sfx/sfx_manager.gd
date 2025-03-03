extends Node

enum CHANNEL_CONFIG {
	BASIC,
	HITS,
	EXPLOSIONS
} 

var channels = {
	CHANNEL_CONFIG.BASIC: [null, null, null, null, null],
	CHANNEL_CONFIG.HITS: [null],
	CHANNEL_CONFIG.EXPLOSIONS: [null]
}

func play_sfx(stream: AudioStreamWAV, playback_channel = CHANNEL_CONFIG.BASIC):
	for i in range(channels[playback_channel].size()):
		if channels[playback_channel][i] == null:
			channels[playback_channel][i] = AudioStreamPlayer2D.new()
			add_child(channels[playback_channel][i])
			print("created basic audiostream channel")
		var channel: AudioStreamPlayer2D = channels[playback_channel][i]
		if not channel.playing:
			channel.stream = stream
			channel.play()
			return
