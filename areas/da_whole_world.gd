extends Spatial

const MIN_DIST_LOAD := 325
const MIN_SQDIST_UPDATE := 10

const LOAD_TIME := 3.0
const UNLOAD_TIME := 2.0

const MAX_ACTIVE_CHUNKS := 4

var chunks: Array
var chunk_load_waitlist : Dictionary = {}
var chunk_unload_waitlist : Dictionary = {}
var active_chunks: Array
onready var player: PlayerBody = $player
var lowres_chunks: Dictionary

onready var player_last_postion: Vector3 = player.global_transform.origin

export(Material) var debug_active_chunk_material
export(Material) var debug_inactive_chunk_material

const PATH_CONTENT := "res://areas/chunks/%s.tscn"
const PATH_LOWRES := "res://areas/chunks/%s_lowres.tscn"

func _ready():
	for c in get_children():
		if c.name.begins_with("chunk"):
			chunks.append(c)
			var lowres_file: String = PATH_LOWRES % c.name
			if ResourceLoader.exists(lowres_file):
				var scn: PackedScene = load(lowres_file)
				if scn:
					var node = scn.instance()
					node.name = "lowres"
					lowres_chunks[c.name] = node 
	print(chunks.size(), " chunks")
	update_active_chunks(player_last_postion, true)

func _process(delta):
	var player_new_position = player.global_transform.origin
	if (player_last_postion - player_new_position).length_squared() >= MIN_SQDIST_UPDATE:
		update_active_chunks(player_new_position)
		player_last_postion = player_new_position
	
	for ch in chunk_load_waitlist:
		chunk_load_waitlist[ch] += delta
		if chunk_load_waitlist[ch] > LOAD_TIME:
			chunk_load_waitlist.erase(ch)
			mark_active(get_node(ch))
			
	for ch in chunk_unload_waitlist:
		chunk_unload_waitlist[ch] += delta
		if chunk_unload_waitlist[ch] > UNLOAD_TIME:
			chunk_unload_waitlist.erase(ch)
			mark_inactive(get_node(ch))
		

func update_active_chunks(position: Vector3, instant := false):
	for ch in chunks:
		var diff = ch.global_transform.origin - position
		if abs(diff.x) < MIN_DIST_LOAD and abs(diff.z) < MIN_DIST_LOAD:
			if instant:
				mark_active(ch)
				continue
			
			if !(ch.name in chunk_load_waitlist):
				chunk_load_waitlist[ch.name] = 0.0 
			if ch.name in chunk_unload_waitlist:
				chunk_unload_waitlist.erase(ch.name)
			ch.material_override = debug_active_chunk_material
		else:
			if instant:
				mark_inactive(ch)
				continue
			if !(ch.name in chunk_unload_waitlist):
				chunk_unload_waitlist[ch.name] = 0.0 
			if ch.name in chunk_load_waitlist:
				chunk_load_waitlist.erase(ch.name)
			ch.material_override = debug_inactive_chunk_material

func mark_active(chunk: Spatial):
	if (chunk in active_chunks):
		return
	active_chunks.append(chunk)
	# Dynamic chunk loading
	var content_file: String = PATH_CONTENT % chunk.name
	if ResourceLoader.exists(content_file):
		var scn: PackedScene = load(content_file) as PackedScene
		if scn:
			var node: Node = scn.instance()
			node.name = "dynamic_content"
			chunk.add_child(node)
		else:
			print_debug("Loading %s failed!!" % content_file)
		if chunk.has_node("lowres"):
			chunk.remove_child(chunk.get_node("lowres"))

func mark_inactive(chunk: Spatial):
	if !(chunk in active_chunks):
		return
	active_chunks.remove(active_chunks.find(chunk))
	if chunk.has_node("dynamic_content"):
		chunk.get_node("dynamic_content").queue_free()
		if chunk.name in lowres_chunks:
			chunk.add_child(lowres_chunks[chunk.name])
	
	
