extends AudioStreamPlayer

export(AudioStream) var tension_music
var next_track: AudioStream

var TENSION_FADE_IN := 30.0
var TENSION_FADE_OUT := 8.0
var MIN_DB := -80.0
var FADEOUT_SPEED := 20.0

enum State {
	Explore,
	Fixed,
	Fadeout
}

var state = State.Explore
var next_state = State.Explore
var tension := false

func _process(delta):
	if state == State.Fadeout:
		volume_db -= FADEOUT_SPEED*delta
		if volume_db < MIN_DB:
			set_state(next_state)
	elif state == State.Explore:
		if tension:
			if stream_paused:
				stream_paused = false
			if !playing:
				play()
			if volume_db < 0:
				print(volume_db)
				volume_db += TENSION_FADE_IN*delta
		elif !tension:
			if volume_db > MIN_DB:
				volume_db -= TENSION_FADE_OUT*delta
			else:
				stream_paused = true

func set_state(new_state):
	if new_state == State.Explore:
		stream = tension_music
	elif new_state == State.Fixed:
		stream = next_track
		volume_db = 0
		stream_paused = false
		play()
	state = new_state

func play_music(music: AudioStream):
	next_state = State.Fixed
	next_track = music
	set_state(State.Fadeout)

func stop_music():
	if state == State.Fixed:
		next_state = State.Explore
		next_track = tension_music
		set_state(State.Fadeout)
