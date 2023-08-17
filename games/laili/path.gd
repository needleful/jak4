extends Spatial

signal activated(point)

export(String) var chunk_entry := ""
export(Mesh) var rope_knot:Mesh
export(Mesh) var rope_segment:Mesh
export(ShaderMaterial) var rope_material:ShaderMaterial

var active_segment:Spatial = null
var previous_node:Spatial = null
var previous_checkpoint:Spatial = null
var current_active := 0

var rope_compositor: MultiMeshSystem
var bone_ref:Spatial
var continuation: Node

func _ready():
	for c in get_children():
		c.hide()

func _process(_delta):
	if !active_segment:
		set_process(false)
		return
	if !bone_ref:
		bone_ref = Global.get_player().mesh.get_bone_ref("backLower")
	drag_rope_to(bone_ref.global_transform.origin)

func start(checkpoint:Spatial = null):
	current_active = 0
	rope_compositor = MultiMeshSystem.new()
	get_parent().add_child(rope_compositor)
	activate(current_active)
	if !checkpoint:
		checkpoint = get_child(0)
		tie_rope(checkpoint.global_transform.origin)
	add_rope_segment(checkpoint.global_transform.origin)

	previous_checkpoint = checkpoint
	previous_node = checkpoint
	set_process(true)

func cancel():
	rope_compositor.queue_free()
	rope_compositor = null
	active_segment = null
	previous_checkpoint = null
	previous_node = null
	set_process(false)
	if continuation:
		continuation.cancel()
		continuation = null
	if previous_checkpoint:
		previous_checkpoint.disconnect_spawn(Global.get_player())

func activate_next():
	var player := Global.get_player()
	var crossed = get_child(current_active)
	
	crossed.active = false
	tie_rope(crossed.global_transform.origin)

	if crossed.checkpoint:
		crossed.connect_spawn(player)
		if previous_checkpoint:
			previous_checkpoint.disconnect_spawn(Global.get_player())
			previous_checkpoint = crossed
	previous_node = crossed

	current_active += 1
	if current_active < get_child_count():
		add_rope_segment(crossed.global_transform.origin)
		activate(current_active)
	elif chunk_entry != "":
		pass_to_next()
	elif CustomGames.is_active():
		active_segment = null
		CustomGames.end(true)
		if previous_checkpoint:
			previous_checkpoint.disconnect_spawn(Global.get_player())

func activate(point: int):
	var p = get_child(point)
	p.active = true
	emit_signal("activated", point)

func pass_to_next():
	var path := chunk_entry.split(":")
	var chunk_name = path[0]
	var next_node = path[1]
	var world = get_tree().current_scene
	var node = world.get_node(chunk_name)
	if !world.is_active(node):
		print_debug("WARNING: chunk '", chunk_name,
			"' is inactive. Forcing activation.")
		world.force_activate(node)
		
	continuation = node.get_node("dynamic_content/active_entities").get_node(next_node)
	continuation.start(previous_checkpoint)
	set_process(false)

func add_rope_segment(point:Vector3):
	active_segment = MultiMeshComponent.new()
	active_segment.mesh = rope_segment
	active_segment.material_override = rope_material
	rope_compositor.add_child(active_segment)
	active_segment.global_transform.origin = point

func drag_rope_to(p:Vector3):
	var d := p - active_segment.global_transform.origin
	var z := d.normalized()
	z = Vector3(z.z, -z.x, z.y)
	active_segment.global_transform.basis = Basis(
		d.cross(z).normalized(), d, z)

func tie_rope(point:Vector3):
	if active_segment:
		drag_rope_to(point)
	var k := MultiMeshComponent.new()
	k.mesh = rope_knot
	k.material_override = rope_material
	rope_compositor.add_child(k)
	k.global_transform.origin = point
