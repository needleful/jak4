tool
extends Spatial

export(Material) var hologram_material
export(Material) var hidden_material

export(bool) var real_visible := false setget set_real_visible
export(NodePath) var path_node:NodePath setget set_path_node
export(float, 0.0, 1.0) var path_amount := 0.0 setget set_path_amount

onready var anim_tree:AnimationTree = $AnimationTree
onready var anim_state:AnimationNodeStateMachinePlayback = anim_tree["parameters/StateMachine/playback"]
onready var custom_anim: AnimationNodeAnimation = anim_tree.tree_root.get_node("StateMachine").get_node("CustomNode")

var look_center := Vector2(0.5, 0.1)
var look_radii := Vector2(0.6, 0.4)
var path : Path

var look_target:Spatial = null
onready var eye_material: ShaderMaterial = $Armature.eye_material
onready var eyes : Spatial = $Armature/Skeleton/head_attach/eyes

func _ready():
	if Engine.editor_hint:
		make_visible()

func _overlay(n: Node):
	for m in n.get_children():
		if m is GeometryInstance:
			m.material_overlay = hologram_material
			m.layers = 65536 # the medium view layer
		else:
			_overlay(m)

func track(target: Spatial):
	look_target = target
	set_physics_process(!!look_target)

func hello():
	print_debug("hello")
	anim_tree.active = true
	make_visible()

func make_visible():
	var skeleton := $Armature
	if !Engine.editor_hint:
		if Global.mum.outfit:
			skeleton.outfit = Global.mum.outfit
		else:
			Global.mum.set_outfit(skeleton.outfit)
		skeleton.refresh()
	anim_tree["parameters/Big/add_amount"] = 1.0
	$vis_anim.play("Show")
	_overlay(skeleton)

func play_state(state: String):
	anim_state.travel(state)

func play_animation(anim: String):
	custom_anim.animation = anim
	anim_state.travel("CustomNode")

func bye():
	$vis_anim.play("Hide")
	track(null)

func set_real_visible(v):
	real_visible = v
	if !is_inside_tree():
		return
	_override($Armature, null if v else hidden_material)

func _override(n: Node, mat: Material):
	for m in n.get_children():
		if m is GeometryInstance:
			m.material_override = mat
		else:
			_override(m, mat)

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

func set_path_node(p_path: NodePath):
	path_node = p_path
	if has_node(p_path):
		path = get_node(p_path)
	else:
		path = null

func set_path_amount(p_path: float):
	path_amount = p_path
	if !path:
		return
	else:
		var pos = path.curve.interpolate_baked(p_path*path.curve.get_baked_length())
		pos.y = 0
		global_transform.origin = path.global_transform*pos
