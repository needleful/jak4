extends Spatial

var crouch_blend := 0.0
var climb_blend := 0.0

onready var anim: AnimationTree = $AnimationTree
onready var body: AnimationNodeStateMachinePlayback = anim["parameters/WholeBody/playback"]

func set_movement_animation(speed: float, is_crouch: bool, is_climb: bool):
	crouch_blend = lerp(crouch_blend, float(is_crouch), 0.45)
	climb_blend = lerp(climb_blend, float(is_climb), 0.15)
	
	anim["parameters/WholeBody/Ground/blend_position"] = Vector2(crouch_blend + climb_blend, speed)

func transition_to(state):
	body.travel(state)

func show_coat(coat: Coat):
	var mat = coat.generate_material()
	$Armature/Skeleton/coat.material_override = mat
