extends Spatial

export(bool) var open := true
#export(float) var toggle_time := 0.0

export(NodePath) var body_opened := NodePath("body_open")
export(NodePath) var body_closed := NodePath("closed-kine")

onready var opened := get_node(body_opened)
onready var closed := get_node(body_closed)

onready var anim : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready():
	toggle(open)

func swap():
	toggle(!open)

func toggle(should_open):
	open = should_open
	if open:
		anim.travel("Opened")
		if !opened.is_inside_tree():
			add_child(opened)
		remove_child(closed)
	else:
		anim.travel("Closed")
		if !closed.is_inside_tree():
			add_child(closed)
		remove_child(opened)
