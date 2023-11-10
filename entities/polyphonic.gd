extends AudioStreamPlayer3D

export(Dictionary) var sound_streams

func play_one(sound: String):
	stop()
	if sound in sound_streams:
		stream = sound_streams[sound]
		play()
	else:
		print_debug("No such sound: ", sound)
