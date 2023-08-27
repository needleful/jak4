tool
extends Spatial

export(Material) var hologram_material
export(Material) var hidden_material

export(bool) var real_visible := false setget set_real_visible
onready var anim_tree:AnimationTree = $AnimationTree
onready var anim_state:AnimationNodeStateMachinePlayback = anim_tree["parameters/StateMachine/playback"]

func _ready():
	for m in $Armature/Skeleton.get_children():
		m.material_overlay = hologram_material

func hello():
	#$Armature/Skeleton/head.get_surface_material(0).set_shader_param("albedo",
	#	Color.from_hsv(randf(), randf(), randf(), 1.0)
	#)
	anim_state.start("IntroWalk")
	anim_tree["parameters/Big/add_amount"] = randf()
	$vis_anim.play("Show")
	$Armature/Skeleton.refresh()

func bye():
	$vis_anim.play("Hide")

func set_real_visible(v):
	real_visible = v
	if !is_inside_tree():
		return
	var mat = null if v else hidden_material
	for m in $Armature/Skeleton.get_children():
		if m is MeshInstance:
			m.material_override = mat

func _on_blink_timer_timeout():
	$blink.playback_speed = rand_range(0.8, 1.0)
	$blink.play("blink")
	var time: float
	if randf() < 0.25:
		time = rand_range(0.2, 0.5)
	else:
		time = rand_range(3.0, 6.0)
	$blink_timer.start(time)
	
