extends AnimationPlayer

export(NodePath) var blink_timer
export(bool) var randomize_speed := true
onready var timer : Timer = get_node(blink_timer)

func _ready():
	if timer:
		var _x = timer.connect("timeout", self, "blink")

func blink():
	if randomize_speed:
		playback_speed = rand_range(0.7, 1.0)
	play("blink")
	var time: float
	if randf() < 0.15:
		time = rand_range(0.2, 0.5)
	else:
		time = rand_range(3.0, 6.0)
	timer.start(time)
