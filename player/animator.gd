extends Spatial

var crouch_blend := 0.0

onready var anim: AnimationTree = $AnimationTree

onready var body: AnimationNodeStateMachinePlayback = anim["parameters/WholeBody/playback"]

func set_movement_animation(speed: float, is_crouch: bool):
	crouch_blend = lerp(crouch_blend, float(is_crouch), 0.45)
	anim["parameters/WholeBody/Ground/blend_position"] = Vector2(crouch_blend, speed)

func transition_to(state):
	body.travel(state)
