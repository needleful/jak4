extends Spatial

signal activated(chunk)
signal deactivated(chunk)

var air_tutorial := false

# Distance from the bounding box edge
const MIN_DIST_LOAD := 200
const MIN_DIST_MUST_LOAD := 30

const UNLOAD_TIME := 10.0

var chunks: Dictionary
var lowres_chunks: Dictionary
#var chunk_collider: Dictionary

const CHUNK_SQDIST_UPDATE := 17
const VIS_SQDIST_UPDATE := 23
const ENEMIES_SQDIST_UPDATE := 9

onready var player: PlayerBody = $player
onready var chunk_last_position: Vector3 = player.global_transform.origin
onready var vis_last_position :Vector3 = player.global_transform.origin
onready var enemies_last_position :Vector3 = player.global_transform.origin

var enemies_present := false
var MIN_DIST_SQ_ENEMIES := 2000.0



onready var env := $WorldEnvironment
onready var env_tween: Tween = $env_tween
onready var sun_tween: Tween = $sun_tween
onready var sun := $sun
onready var indirect := $indirect_light
onready var indirect_tween := $indirect_tween
var sun_enabled := true

var env_override := false
var shaders_ready := false

onready var env_defaults := {
	"end": env.environment.fog_depth_end,
	"begin":env.environment.fog_depth_begin,
	"color":env.environment.fog_color,
	"indirect_light":indirect.light_color
}
var time := 0.0
var TIME_READY := 0.5

const FOG_TWEEN_TIME := 2.5
const FOG_MIN_HEIGHT := 1000
const FOG_MAX_HEIGHT := 3500
onready var FOG_DISTANCE_MIN = env_defaults.end
onready var FOG_DISTANCE_MAX = env_defaults.end*2.0

const DIST_HIRES := 1500.0
const DIST_LOWRES := 2000.0

var terrain_hires := {}
var terrain_lowres := {}

var chunk_loader: ChunkLoader

func _input(event):
	if event.is_action_pressed("debug_map_view"):
		if $mapcam.current:
			player.ui.show()
			player.cam_rig.camera.current = true
			env_override = false
		else:
			player.hide()
			$mapcam.current = true
			env_override = true
			env.environment.fog_depth_end *= 3

func _enter_tree():
	if !Global.valid_game_state and ResourceLoader.exists(Global.save_path):
		Global.load_sync(false)
		
func _exit_tree():
	chunk_loader.quit()
		
func _ready():
	var _x = env_tween.start()
	if false:
		print("Random races")
		for _i in range (10):
			print("\t", int(rand_range(0, 144)))
		print("Random jump game")
		for _i in range (15):
			print("\t", int(rand_range(0, 144)))
		print("Riley")
		for _i in range (10):
			print("\t", int(rand_range(0, 144)))
	
	chunk_loader = ChunkLoader.new()
	print("Readying world...")
	_x = chunk_loader.connect("load_start", self, "_on_load_started")
	_x = chunk_loader.connect("load_complete", self, "_on_load_complete")
	
	for c in get_children():
		if c.name.begins_with("chunk_lowres"):
			var name_convert = c.name.replace("chunk_lowres", "chunk").replace("000", "")
			terrain_lowres[name_convert] = c.mesh
			c.queue_free()
		elif c.name.begins_with("chunk"):
			terrain_hires[c.name] = c.mesh
			chunks[c.name] = c
	print("Collected meshes")
	#load_everything()
	# Briefly render the opposite light
	sun.visible = !sun_enabled
	chunk_last_position = player.global_transform.origin
	update_active_chunks(chunk_last_position)
	start_loading_chunks()
	
	vis_last_position = player.global_transform.origin
	update_terrain_lod(vis_last_position)
	if Global.valid_game_state:
		if Global.has_stat("clock_time"):
			set_time(Global.stat("clock_time"))

func _process(delta):
	time += delta
	if !shaders_ready and time > TIME_READY:
		sun.visible = sun_enabled
		sun.light_energy = 1.0 if sun_enabled else 0.0
		shaders_ready = true
	var player_new_position = player.global_transform.origin
	#apply_fog(player_new_position.y)
	if (chunk_last_position - player_new_position).length_squared() >= CHUNK_SQDIST_UPDATE:
		update_active_chunks(player_new_position)
		chunk_last_position = player_new_position
		if chunk_last_position.y < -8000:
			player.fall_to_death()
	if (enemies_last_position - player_new_position).length_squared() >= ENEMIES_SQDIST_UPDATE:
		enemies_last_position = player_new_position
		detect_enemies(delta)
	if (vis_last_position - player_new_position).length_squared() >= VIS_SQDIST_UPDATE:
		vis_last_position = player_new_position
		get_tree().call_group("distance_activated", "process_player_distance", player_new_position)
		update_terrain_lod(vis_last_position)

func get_sun():
	return sun

func prepare_save():
	Global.set_stat("clock_time", get_time())

func update_terrain_lod(pos: Vector3):
	pos.y = 0
	for c in chunks.values():
		if !(c.name in terrain_lowres and c.name in terrain_hires):
			continue
		var d = (c.global_transform.origin - pos).length_squared()
		if d > DIST_LOWRES*DIST_LOWRES:
			if c.mesh != terrain_lowres[c.name]:
				c.mesh = terrain_lowres[c.name]
		elif d < DIST_HIRES*DIST_HIRES:
			if c.mesh != terrain_hires[c.name]:
				c.mesh = terrain_hires[c.name]

func load_everything():
	for c in chunks.values():
		var path = chunk_loader.PATH_CONTENT % c.name
		if ResourceLoader.exists(path):
			var scn = load(path).instance()
			scn.name = "dynamic_content"
			c.add_child(scn)

func free_everything():
	print("everything mus go!!!")
	free_between(10, 80)

func free_between(start, end):
	var i = 0
	for c in chunks.values():
		i += 1
		if i < start:
			continue
		elif i > end:
			break
		if c.has_node("dynamic_content"):
			print(c.name)
			c.get_node('dynamic_content').queue_free()

func free_every_other(on_even : bool):
	var even = on_even
	for c in chunks.values():
		if c.has_node("dynamic_content") and even:
			print(c.name)
			c.get_node('dynamic_content').queue_free()
		even = !even

func start_loading_chunks():
	# Sort the chunks by distance from player
	var sorted_chunks := chunks.values()
	sorted_chunks.sort_custom(self, "compare_distances")
	chunk_loader.start_loading(sorted_chunks)
	#var _x = chunk_loader.first_complete.wait()

func _on_load_started():
	$loading.show()

func _on_load_complete():
	chunk_loader.quit()
	$loading.hide()

func compare_distances(a: Spatial, b: Spatial):
	var dist_a = (chunk_last_position - a.global_transform.origin).length_squared()
	var dist_b = (chunk_last_position - b.global_transform.origin).length_squared()
	return dist_a < dist_b

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

func update_active_chunks(position: Vector3):
	var active_box = $debug/box/active_chunks
	active_box.text = "Active Chunks:"
	for ch in chunks.values():
		var local : Vector3 = position - ch.global_transform.origin
		var hlocal : Vector3 = local
		hlocal.y = 0
		var load_zone: AABB = ch.get_aabb().grow(Global.render_distance*MIN_DIST_LOAD)
		var must_load_zone: AABB = ch.get_aabb().grow(MIN_DIST_MUST_LOAD)
		# Reimplement load_sync and unloading over time
		if load_zone.has_point(local) or must_load_zone.has_point(hlocal):
			if !chunk_loader.is_active(ch.name):
				chunk_loader.queue_load(ch)
				emit_signal("activated", ch)
			active_box.text += "\n\t" + ch.name
		elif chunk_loader.is_active(ch.name):
			chunk_loader.queue_unload(ch)
			emit_signal("deactivated", ch)


func apply_fog(height: float):
	var factor := clamp((height - FOG_MIN_HEIGHT)/(FOG_MAX_HEIGHT - FOG_MIN_HEIGHT), 0, 1)
	env_defaults.end = lerp(FOG_DISTANCE_MIN, FOG_DISTANCE_MAX, factor)
	if !env_override and !env_tween.is_active():
		env.environment.fog_depth_end = env_defaults.end

func show_combat_tutorial():
	var _x = Global.add_stat("combat_tutorial")
	player.ui.show_prompt(["combat_lunge"], "Lunge Kick")
	air_tutorial = false
	$tutorial_swap.start()

func show_cloaked_combat_tutorial():
	var _x = Global.add_stat("cloaked_combat_tutorial")
	if Global.using_gamepad:
		player.ui.show_prompt(["combat_aim_toggle"], "Toggle aim")
	else:
		player.ui.show_prompt(["combat_aim"], "Aim")

func show_air_combat_tutorial():
	var _x = Global.add_stat("air_combat_tutorial")
	player.ui.show_prompt(["mv_crouch", "combat_lunge"], "Uppercut")
	air_tutorial = true
	$tutorial_swap.start()

func _on_tutorial_swap_timeout():
	if air_tutorial:
		player.ui.show_prompt(["mv_jump", "combat_lunge"], "Diving Kick")
	else:
		player.ui.show_prompt(["combat_spin"], "Spin Kick")

# Environment

func get_wind_audio():
	return $audio_wind

func set_sun_enabled(enabled:bool):
	sun_enabled = enabled
	if time < TIME_READY:
		sun.light_energy = 1.0 if !enabled else 0.0
		sun.visible = !enabled
		return
		
	var _x = sun_tween.remove_all()
	_x = sun_tween.interpolate_property(sun, "light_energy",
		sun.light_energy,
		1.0 if enabled else 0.0,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	if !enabled and sun.visible:
		_x = sun_tween.interpolate_callback(sun, 
			FOG_TWEEN_TIME, "hide")
	elif enabled:
		if !sun.visible:
			sun.light_energy = 0
		sun.show()
	_x = sun_tween.start()

func indirect_light_override(light: Color):
	var _x = indirect_tween.stop_all()
	env_override = true
	if time < TIME_READY:
		indirect.light_color = light
		return
	_x = indirect_tween.remove_all()
	_x = indirect_tween.interpolate_property(indirect, "light_color",
		indirect.light_color, light,
		FOG_TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_x = indirect_tween.start()

func clear_indirect_light():
	indirect_light_override(env_defaults.indirect_light)
	env_override = false

func set_fog_override(fog: Color, begin: float, end:float):
	var _x = env_tween.stop_all()
	env_override = true
	if time < TIME_READY:
		env.environment.fog_color = fog
		env.environment.fog_depth_begin = begin
		env.environment.fog_depth_end = end
		return
	_x = env_tween.remove_all()
	_x = env_tween.interpolate_property(env.environment, "fog_color",
		env.environment.fog_color, fog,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_x = env_tween.interpolate_property(env.environment, "fog_depth_begin",
		env.environment.fog_depth_begin, begin,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_x = env_tween.interpolate_property(env.environment, "fog_depth_end",
		env.environment.fog_depth_end, end,
		FOG_TWEEN_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_x = env_tween.start()

func clear_fog_override():
	set_fog_override(env_defaults.color, env_defaults.begin, env_defaults.end)
	env_override = false

func is_active(chunk_name):
	return chunk_loader.is_active(chunk_name)

func get_dynamic_content(chunk_name):
	return get_node(chunk_name).get_node("dynamic_content")

## Day/night cycle

# Hours with decimals
func get_time():
	# Seconds of animation (600 for 24-hour day)
	var hours_per_second := 1.0/25.0
	# Offset in the animation to midnight
	var midnight_offset := 330.0
	var sec_time:float = $day_night.current_animation_position
	var hour := hours_per_second * (sec_time - midnight_offset)
	while hour < 0.0:
		hour += 24.0
	while hour > 24.0:
		hour -= 24.0
	return hour

func set_time(hour: float):
	var seconds_per_hour := 25.0
	var midnight_offset := 330.0
	var animation_length := 600.0
	var seconds := seconds_per_hour*hour + midnight_offset
	while seconds > animation_length:
		seconds -= animation_length
	while seconds < 0.0:
		seconds += animation_length
	$day_night.stop()
	$day_night.play("day_night_normal")
	$day_night.advance(seconds/$day_night.playback_speed)
	sun.update_rotation()
