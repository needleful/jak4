extends Spatial

signal activated(point)

export(String) var chunk_entry := ""
export(Mesh) var rope_segment:Mesh
export(Mesh) var rope_knot:Mesh

var previous_node:Spatial = null
var previous_checkpoint:Spatial = null
var current_active := 0

var active_segment: MultiMeshComponent
var bone_ref:Spatial

func _ready():
	for c in get_children():
		c.hide()

func _process(_delta):
	if !active_segment:
		set_process(false)
		return
	if !bone_ref:
		bone_ref = Global.get_player().mesh.get_bone_ref("backLower")
	set_end_point(bone_ref.global_transform.origin)

func start(checkpoint:Spatial = null):
	activate(current_active)
	if !checkpoint:
		checkpoint = get_child(0)
	else:
		add_rope(checkpoint.global_transform.origin)
	previous_checkpoint = checkpoint
	previous_node = checkpoint
	set_process(true)

func activate_next():
	var player := Global.get_player()
	var crossed = get_child(current_active)
	
	crossed.active = false
	if crossed.checkpoint:
		crossed.connect_spawn(player)
		if previous_checkpoint:
			previous_checkpoint.disconnect_spawn(Global.get_player())
			previous_checkpoint = crossed
	previous_node = crossed

	current_active += 1
	if current_active < get_child_count():
		activate(current_active)
		add_rope(crossed.global_transform.origin)
	elif chunk_entry != "":
		pass_to_next()
	elif CustomGames.is_active():
		set_end_point(crossed.global_transform.origin)
		active_segment = null
		CustomGames.end(true)

func activate(point: int):
	if active_segment:
		set_end_point(previous_node.global_transform.origin)
		active_segment = null
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
		
	var next = node.get_node("dynamic_content/active_entities").get_node(next_node)
	next.start(previous_checkpoint)
	if active_segment:
		set_end_point(get_child(current_active - 1).global_transform.origin)
		active_segment = null
	set_process(false)

func set_end_point(p:Vector3):
	var d := p - active_segment.global_transform.origin 
	var z := d.normalized()
	z = Vector3(z.z, -z.x, z.y)
	active_segment.global_transform.basis = Basis(
		d.cross(z).normalized(), d, z)

func add_rope(point:Vector3):
	var p := get_parent()
	active_segment = MultiMeshComponent.new()
	active_segment.mesh = rope_segment
	p.add_child(active_segment)
	active_segment.global_transform.origin = point
	
	var k := MultiMeshComponent.new()
	k.mesh = rope_knot
	p.add_child(k)
	k.global_transform.origin = point
