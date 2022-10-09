extends Spatial

var air_tutorial := false

# Distance from the bounding box edge
const MIN_DIST_LOAD := 300
const MIN_DIST_MUST_LOAD := 30
const MIN_SQDIST_UPDATE := 10

const UNLOAD_TIME := 10.0

var chunks: Array
var active_chunks: Array

var loading : Spatial
var load_thread := Thread.new()
var load_queue: Array = []
var loaded_chunks: Dictionary = {}

var chunk_unload_waitlist : Dictionary = {}
var lowres_chunks: Dictionary
#var chunk_collider: Dictionary

onready var player: PlayerBody = $player
onready var player_last_postion: Vector3 = player.global_transform.origin

export(Material) var debug_active_chunk_material
export(Material) var debug_inactive_chunk_material

const PATH_CONTENT := "res://areas/chunks/%s.tscn"
const PATH_LOWRES := "res://areas/chunks/%s_lowres.tscn"

var enemies_present := false
var MIN_DIST_SQ_ENEMIES := 2000.0

onready var env := $WorldEnvironment
onready var env_tween := $env_tween
onready var sun_tween := $sun_tween
onready var sun := $DirectionalLight

onready var fog_defaults := {
	"color":env.environment.fog_color,
	"begin":env.environment.fog_depth_begin,
	"end":env.environment.fog_depth_end
}

var env_override := false

var time := 0.0
var TIME_READY := 0.5

const FOG_TWEEN_TIME := 2.5
const FOG_MIN_HEIGHT := 1000
const FOG_MAX_HEIGHT := 3500
onready var FOG_DISTANCE_MIN = fog_defaults.end
onready var FOG_DISTANCE_MAX = fog_defaults.end*2.0

func _enter_tree():
	if !Global.valid_game_state and ResourceLoader.exists(Global.save_path):
		Global.load_sync()
		
func _ready():
	for c in get_children():
		if c.name.begins_with("chunk"):
			chunks.append(c)
			if Global.show_lowres:
				var lowres_file: String = PATH_LOWRES % c.name
				if ResourceLoader.exists(lowres_file):
					var scn: PackedScene = load(lowres_file)
					if scn:
						var node = scn.instance()
						node.name = "lowres"
						lowres_chunks[c.name] = node
						c.add_child(node)
	update_active_chunks(player_last_postion, true)

func _process(delta):
	time += delta
	var player_new_position = player.global_transform.origin
	apply_fog(player_new_position.y)
	if (player_last_postion - player_new_position).length_squared() >= MIN_SQDIST_UPDATE:
		get_tree().call_group("distance_activated", "process_player_distance", player_new_position)
		detect_enemies(delta)
		update_active_chunks(player_new_position)
		player_last_postion = player_new_position
	
	if !load_queue.empty() and !load_thread.is_alive():
		if load_thread.is_active():
			load_thread.wait_to_finish()
		var _x = load_thread.start(self, "load_async", load_queue.pop_front())
	
	for ch in chunk_unload_waitlist:
		chunk_unload_waitlist[ch] += delta
		if chunk_unload_waitlist[ch] > UNLOAD_TIME:
			mark_inactive(get_node(ch))

func get_or_load(chunk_name: String) -> PackedScene:
	if chunk_name in loaded_chunks:
		return loaded_chunks[chunk_name] as PackedScene
	var content_file: String = PATH_CONTENT % chunk_name
	if ResourceLoader.exists(content_file):
		var content = ResourceLoader.load(content_file, "PackedScene", true) as PackedScene
		if content:
			loaded_chunks[chunk_name] = content
		return content
	else:
		return null

func detect_enemies(_delta):
	var were_present := enemies_present
	enemies_present = false
	var air_enemies_present = false
	var cloaked_enemies_present = false
	for e in get_tree().get_nodes_in_group("enemy"):
		var dist_squared: float = e.process_player_distance(player.global_transform.origin)
		if dist_squared < MIN_DIST_SQ_ENEMIES:
			if "can_fly" in e and e.can_fly:
				air_enemies_present = true
			elif e.cloaked:
				cloaked_enemies_present = true
			else:
				enemies_present = true
	
	Music.in_combat = enemies_present
	if cloaked_enemies_present and Global.count("wep_pistol") and !Global.stat("cloaked_combat_tutorial"):
		show_cloaked_combat_tutorial()
	if air_enemies_present and !Global.stat("air_combat_tutorial"):
		show_air_combat_tutorial()
	elif !were_present and enemies_present and !Global.stat("combat_tutorial"):
		show_combat_tutorial()

func update_active_chunks(position: Vector3, instant := false):
	for ch in chunks:
		var local : Vector3 = position - ch.global_transform.origin
		var hlocal : Vector3 = local
		hlocal.y = 0
		var load_zone: AABB = ch.get_aabb().grow(Global.render_distance*MIN_DIST_LOAD)
		var must_load_zone: AABB = ch.get_aabb().grow(MIN_DIST_MUST_LOAD)
		
		if load_zone.has_point(local) or must_load_zone.has_point(hlocal):
			if instant or must_load_zone.has_point(local):
				load_sync(ch)
			else:
				queue_load(ch)
		else:
			if instant:
				mark_inactive(ch)
			else:
				queue_unload(ch)
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
		for c in load_queue:
			load_str += "\n\t" + c.name
		$debug/box/Label3.text = load_str
		
		var unload_str = "Unload Queue:"
		for c in chunk_unload_waitlist:
			unload_str += "\n\t" + c
		$debug/box/Label4.text = unload_str
		
	if position.y < -8000 and active_chunks.empty():
		player.fall_to_death()

func queue_load(ch: Spatial):
	if ch.name in chunk_unload_waitlist:
		var _x = chunk_unload_waitlist.erase(ch.name)
	if ch in active_chunks:
		return
	if loading == ch:
		return
	if ch.has_node("dynamic_content"):
		print_debug("Duplicate dynamic content: ", ch.name)
		return
	var load_i = load_queue.find(ch)
	if load_i >= 0:
		return
	if ch.name in loaded_chunks:
		active_chunks.append(ch)
		add_dynamic_content(ch, loaded_chunks[ch.name].instance())
	else:
		load_queue.push_back(ch)

func load_async(ch:Spatial):
	if ch.has_node("dynamic_content") or (ch in active_chunks):
		print_debug("Duplicate dynamic content: ", ch.name)
		return
	active_chunks.append(ch)
	loading = ch
	var scn: PackedScene = get_or_load(ch.name)
	call_deferred("add_dynamic_content", ch, scn.instance())
	loading = null

func apply_fog(height: float):
	var factor := clamp((height - FOG_MIN_HEIGHT)/(FOG_MAX_HEIGHT - FOG_MIN_HEIGHT), 0, 1)
	fog_defaults.end = lerp(FOG_DISTANCE_MIN, FOG_DISTANCE_MAX, factor)
	if !env_override:
		env.environment.fog_depth_end = fog_defaults.end

func load_sync(chunk: Spatial):
	if chunk.name in chunk_unload_waitlist:
		var _x = chunk_unload_waitlist.erase(chunk.name)
	if (chunk in active_chunks):
		return
	if loading == chunk and load_thread.is_active():
		load_thread.wait_to_finish()
		return
	if chunk.has_node("dynamic_content"):
		print_debug("Duplicate dynamic content: ", chunk.name)
		return
	active_chunks.append(chunk)
	if chunk.name in chunk_unload_waitlist:
		var _x = chunk_unload_waitlist.erase(chunk.name)
	var load_i = load_queue.find(chunk)
	if load_i >= 0:
		load_queue.remove(load_i)
	var scn: PackedScene = get_or_load(chunk.name)
	if scn:
		add_dynamic_content(chunk, scn.instance())

func add_dynamic_content(chunk: Spatial, node: Node):
	if chunk.has_node("dynamic_content"):
		print_debug("Tried adding duplicate content: ", chunk.name)
		return
	print("Loading ", chunk.name)
	if chunk.has_node("lowres"):
		chunk.remove_child(chunk.get_node("lowres"))
	node.name = "dynamic_content"
	chunk.add_child(node)

func queue_unload(ch: Spatial):
	var load_i = load_queue.find(ch)
	if load_i >= 0:
		load_queue.remove(load_i)
	if !(ch in active_chunks):
		return
	if !(ch.name in chunk_unload_waitlist):
		chunk_unload_waitlist[ch.name] = 0.0 

func mark_inactive(chunk: Spatial):
	var load_i = load_queue.find(chunk)
	if load_i >= 0:
		load_queue.remove(load_i)
	if !(chunk in active_chunks):
		return
	print("Unloading ", chunk.name)
	if chunk.name in chunk_unload_waitlist:
		var _x = chunk_unload_waitlist.erase(chunk.name)
	active_chunks.remove(active_chunks.find(chunk))
	if chunk.has_node("dynamic_content"):
		chunk.get_node("dynamic_content").queue_free()
		if chunk.name in lowres_chunks:
			var l: Node = lowres_chunks[chunk.name]
			l.request_ready()
			chunk.add_child(l)

func unload_all():
	print("Unloading all chunks..")
	load_queue.clear()
	chunk_unload_waitlist.clear()
	for a in active_chunks:
		if a.has_node("dynamic_content"):
			a.get_node("dynamic_content").queue_free()
		if a.name in lowres_chunks:
			var l: Node = lowres_chunks[a.name]
			l.request_ready()
			a.add_child(l)
	active_chunks.clear()

func show_combat_tutorial():
	var _x = Global.add_stat("combat_tutorial")
	player.show_prompt(["combat_lunge"], "Lunge Kick")
	air_tutorial = false
	$tutorial_swap.start()

func show_cloaked_combat_tutorial():
	var _x = Global.add_stat("cloaked_combat_tutorial")
	if Global.using_gamepad:
		player.show_prompt(["combat_aim_toggle"], "Toggle aim")
	else:
		player.show_prompt(["combat_aim"], "Aim")

func show_air_combat_tutorial():
	var _x = Global.add_stat("air_combat_tutorial")
	player.show_prompt(["mv_crouch", "combat_lunge"], "Uppercut")
	air_tutorial = true
	$tutorial_swap.start()

func _on_tutorial_swap_timeout():
	if air_tutorial:
		player.show_prompt(["mv_jump", "combat_lunge"], "Diving Kick")
	else:
		player.show_prompt(["combat_spin"], "Spin Kick")

# Environment

func get_wind_audio():
	return $audio_wind

func set_sun_enabled(enabled:bool):
	if time < TIME_READY:
		sun.visible = enabled
		return
	sun_tween.remove_all()
	sun_tween.interpolate_property(sun, "light_energy",
		sun.light_energy,
		1.0 if enabled else 0.0,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	if !enabled and sun.visible:
		sun_tween.interpolate_callback(sun, 
			FOG_TWEEN_TIME, "hide")
	elif enabled:
		sun.show()
	sun_tween.start()

func set_fog_override(fog: Color, begin: float, end:float):
	env_override = true
	if time < TIME_READY:
		env.environment.fog_color = fog
		env.environment.fog_depth_begin = begin
		env.environment.fog_depth_end = end
		return
	env_tween.remove_all()
	env_tween.interpolate_property(env.environment, "fog_color",
		env.environment.fog_color, fog,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	env_tween.interpolate_property(env.environment, "fog_depth_begin",
		env.environment.fog_depth_begin, begin,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	env_tween.interpolate_property(env.environment, "fog_depth_end",
		env.environment.fog_depth_end, end,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	env_tween.start()

func clear_fog_override():
	env_override = false
	env_tween.remove_all()
	env_tween.interpolate_property(env.environment, "fog_color",
		env.environment.fog_color, fog_defaults.color,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	env_tween.interpolate_property(env.environment, "fog_depth_begin",
		env.environment.fog_depth_begin, fog_defaults.begin,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	env_tween.interpolate_property(env.environment, "fog_depth_end",
		env.environment.fog_depth_end, fog_defaults.end,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	env_tween.start()
