tool
extends Spatial

export(Material) var hologram_material
export(Material) var hidden_material

export(bool) var real_visible := false setget set_real_visible
onready var anim_tree:AnimationTree = $AnimationTree
onready var anim_state:AnimationNodeStateMachinePlayback = anim_tree["parameters/StateMachine/playback"]

var look_center := Vector2(0.5, 0.1)
var look_radii := Vector2(0.6, 0.4)

var look_target:Spatial = null
onready var eye_material: ShaderMaterial = $Armature/Skeleton/head.get_surface_material(1)
onready var eyes : Spatial = $Armature/Skeleton/head_attach/eyes

func _ready():
	_overlay($Armature/Skeleton)
	if Engine.editor_hint:
		make_visible()

func _overlay(n: Node):
	for m in n.get_children():
		if m is GeometryInstance:
			m.material_overlay = hologram_material
		else:
			_overlay(m)

func track(target: Spatial):
	look_target = target
	set_physics_process(!!look_target)

func hello():
	anim_tree.active = true
	$Armature/Skeleton/head.get_surface_material(0).set_shader_param("albedo",
		Color.from_hsv(randf(), randf(), randf(), 1.0)
	)
	anim_state.start("IntroWalk")
	make_visible()

func make_visible():
	anim_tree["parameters/Big/add_amount"] = randf()
	$vis_anim.play("Show")
	$Armature/Skeleton.refresh()

func bye():
	$vis_anim.play("Hide")
	track(null)

func set_real_visible(v):
	real_visible = v
	if !is_inside_tree():
		return
	var mat = null if v else hidden_material
	for m in $Armature/Skeleton.get_children():
		if m is GeometryInstance:
			m.material_override = mat

func _on_blink_timer_timeout():
	$blink.playback_speed = rand_range(0.7, 1.0)
	$blink.play("blink")
	var time: float
	if randf() < 0.15:
		time = rand_range(0.2, 0.5)
	else:
		time = rand_range(3.0, 6.0)
	$blink_timer.start(time)

func track_player():
	track(Global.get_player().eyes)

func track_target():
	track($look_target)

func _process(delta):
	if !is_visible_in_tree() or !is_instance_valid(look_target):
		track(null)
		return
	var relative_pos := eyes.global_transform.affine_inverse()*look_target.global_transform
	if relative_pos.origin.z <= 0:
		return
	var p := 0.5*Vector2(-relative_pos.origin.x, relative_pos.origin.y)/relative_pos.origin.z
	if p.length_squared() > 1.0:
		p = p.normalized()
	p *= look_radii
	p += look_center
	var current_pos:Vector2 = eye_material.get_shader_param("iris_offset")
	eye_material.set_shader_param("iris_offset", current_pos.move_toward(p, delta*6))
