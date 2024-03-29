extends Spatial

export(bool) var open := true
#export(float) var toggle_time := 0.0

onready var anim : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready():
	toggle(open, true)

func swap():
	toggle(!open)

func toggle(should_open, ready := false):
	open = should_open

	if ready and !open:
		anim.start("Closed")
	elif open:
		anim.travel("Opened")
	else:
		anim.travel("Closed")
