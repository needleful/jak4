extends Spatial

signal activated(point)

export(String) var chunk_entry := ""

var previous_node = null
var previous_checkpoint = null
var current_active := 0

func _ready():
	for c in get_children():
		c.hide()

func start(checkpoint = null):
	activate(current_active)
	previous_checkpoint = checkpoint

func activate_next():
	var player := Global.get_player()
	var crossed = get_child(current_active)
	
	crossed.active = false
	if crossed.checkpoint:
		crossed.connect_spawn(player)
		if previous_checkpoint:
			previous_checkpoint.disconnect_spawn(Global.get_player())
			previous_checkpoint = crossed

	current_active += 1
	if current_active < get_child_count():
		activate(current_active)
	elif chunk_entry != "":
		pass_to_next()
	elif CustomGames.is_active():
		CustomGames.end(true)

func activate(point):
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
