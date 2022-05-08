extends Spatial

export(Texture) var gamepad_spin
export(Texture) var gamepad_lunge
export(Texture) var keyboard_spin
export(Texture) var keyboard_lunge

# Distance from the bounding box edge
const MIN_DIST_LOAD := 200
const MIN_DIST_MUST_LOAD := 100
const MIN_SQDIST_UPDATE := 10

const LOAD_TIME := 3.0
const UNLOAD_TIME := 10.0

var chunks: Array
var chunk_load_waitlist : Dictionary = {}
var chunk_unload_waitlist : Dictionary = {}
var active_chunks: Array
onready var player: PlayerBody = $player
var lowres_chunks: Dictionary
var chunk_collider: Dictionary

var chunk_scenes: Dictionary = {}

onready var player_last_postion: Vector3 = player.global_transform.origin

export(Material) var debug_active_chunk_material
export(Material) var debug_inactive_chunk_material

const PATH_CONTENT := "res://areas/chunks/%s.tscn"
const PATH_LOWRES := "res://areas/chunks/%s_lowres.tscn"

var enemies_present := false
var MIN_DIST_SQ_ENEMIES := 2000.0

func _enter_tree():
	if !Global.valid_game_state and ResourceLoader.exists(Global.save_path):
		Global.load_sync()
		
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
					c.add_child(node)
			var content_file: String = PATH_CONTENT % c.name
			if ResourceLoader.exists(content_file):
				chunk_scenes[c.name] = load(content_file)
			if c.has_node("static_collision"):
				chunk_collider[c.name] = c.get_node("static_collision")
	update_active_chunks(player_last_postion, true)

func _process(delta):
	var player_new_position = player.global_transform.origin
	if (player_last_postion - player_new_position).length_squared() >= MIN_SQDIST_UPDATE:
		update_active_chunks(player_new_position)
		player_last_postion = player_new_position
	
	for ch in chunk_load_waitlist:
		chunk_load_waitlist[ch] += delta
		if chunk_load_waitlist[ch] > LOAD_TIME:
			mark_active(get_node(ch))
			
	for ch in chunk_unload_waitlist:
		chunk_unload_waitlist[ch] += delta
		if chunk_unload_waitlist[ch] > UNLOAD_TIME:
			mark_inactive(get_node(ch))
	
	detect_enemies(delta)

func detect_enemies(_delta):
	var were_present := enemies_present
	enemies_present = false
	var enemies = get_tree().get_nodes_in_group("distance_activated")
	for e in enemies:
		var dist_squared: float = e.process_player_distance(player.global_transform.origin)
		if dist_squared < MIN_DIST_SQ_ENEMIES:
			enemies_present = true
	
	Music.tension = enemies_present
	if !were_present and enemies_present and !Global.stat("combat_tutorial"):
		show_combat_tutorial()

func update_active_chunks(position: Vector3, instant := false):
	for ch in chunks:
		var local : Vector3 = position - ch.global_transform.origin
		var load_zone: AABB = ch.get_aabb().grow(MIN_DIST_LOAD)
		var must_load_zone: AABB = ch.get_aabb().grow(MIN_DIST_MUST_LOAD)
		
		if load_zone.has_point(local):
			if instant or must_load_zone.has_point(local):
				mark_active(ch)
			else:
				queue_load(ch)
		else:
			if instant:
				mark_inactive(ch)
			else:
				queue_unload(ch)
	player.get_node("ui/debug/stats/a4").text = "%d active chunks" % active_chunks.size()
	if $debug.visible:
		$debug/box/Label.text = "Moved from (%f, %f %f) to (%f %f %f)" % [
			player_last_postion.x, player_last_postion.y, player_last_postion.z,
			position.x, position.y, position.z
		]
		var active_str = "Active Chunks:"
		for c in active_chunks:
			active_str += "\n\t"+c.name
		$debug/box/Label2.text = active_str
		
		var load_str = "Load Queue"
		for c in chunk_load_waitlist:
			load_str += "\n\t" + c
		$debug/box/Label3.text = load_str
		
		var unload_str = "Unload Queue:"
		for c in chunk_unload_waitlist:
			unload_str += "\n\t" + c
		$debug/box/Label4.text = unload_str
		
	if active_chunks.size() == 0 and chunk_load_waitlist.size() == 0:
		player.fall_to_death()

func queue_load(ch: Spatial):
	if ch.name in chunk_unload_waitlist:
		var _x = chunk_unload_waitlist.erase(ch.name)
	if ch in active_chunks:
		return
	if !(ch.name in chunk_load_waitlist):
		chunk_load_waitlist[ch.name] = 0.0 
	#ch.material_override = debug_active_chunk_material

func queue_unload(ch: Spatial):
	if ch.name in chunk_load_waitlist:
		var _x = chunk_load_waitlist.erase(ch.name)
	if !(ch in active_chunks):
		return
	if !(ch.name in chunk_unload_waitlist):
		chunk_unload_waitlist[ch.name] = 0.0 
	#ch.material_override = debug_inactive_chunk_material

func mark_active(chunk: Spatial):
	if chunk.name in chunk_unload_waitlist:
		var _x = chunk_unload_waitlist.erase(chunk.name)
	if (chunk in active_chunks):
		return
	if chunk.name in chunk_load_waitlist:
		var _x = chunk_load_waitlist.erase(chunk.name)
	active_chunks.append(chunk)
	if chunk.name in chunk_scenes:
		var scn: PackedScene = chunk_scenes[chunk.name]
		if scn:
			var node: Node = scn.instance()
			node.name = "dynamic_content"
			chunk.add_child(node)
		else:
			print_debug("Loading %s failed!!" % chunk.name)
		if chunk.has_node("lowres"):
			chunk.remove_child(chunk.get_node("lowres"))
	if !chunk.has_node("static_collision"):
		chunk.add_child(chunk_collider[chunk.name])

func mark_inactive(chunk: Spatial):
	if chunk.name in chunk_load_waitlist:
		var _x = chunk_load_waitlist.erase(chunk.name)
	if !(chunk in active_chunks):
		return
	if chunk.name in chunk_unload_waitlist:
		var _x = chunk_unload_waitlist.erase(chunk.name)
	active_chunks.remove(active_chunks.find(chunk))
	if chunk.has_node("dynamic_content"):
		chunk.get_node("dynamic_content").queue_free()
		if chunk.name in lowres_chunks:
			chunk.add_child(lowres_chunks[chunk.name])
	
	if chunk.has_node("static_collision"):
		chunk.remove_child(chunk.get_node("static_collision"))

func show_combat_tutorial():
	var _x = Global.add_stat("combat_tutorial")
	if Global.using_gamepad:
		player.show_prompt([gamepad_lunge], "Lunge Kick")
	else:
		player.show_prompt([keyboard_lunge], "Lunge Kick")
	$tutorial_swap.start()

func _on_tutorial_swap_timeout():
	if Global.using_gamepad:
		player.show_prompt([gamepad_spin], "Spin Kick")
	else:
		player.show_prompt([keyboard_spin], "Spin Kick")
