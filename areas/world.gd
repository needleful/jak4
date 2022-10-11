extends Spatial

var air_tutorial := false

# Distance from the bounding box edge
const MIN_DIST_LOAD := 300
const MIN_DIST_MUST_LOAD := 30
const MIN_SQDIST_UPDATE := 10

const UNLOAD_TIME := 10.0

var chunks: Dictionary

var loading : Spatial
var load_thread := Thread.new()
var load_queue: Array = []
var loaded_chunks: Dictionary = {}

var chunk_unload_waitlist : Dictionary = {}
var lowres_chunks: Dictionary
#var chunk_collider: Dictionary

onready var player: PlayerBody = $player
onready var player_last_position: Vector3 = player.global_transform.origin

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

var chunk_loader: ChunkLoader

func _enter_tree():
	if !Global.valid_game_state and ResourceLoader.exists(Global.save_path):
		Global.load_sync(false)
		
func _exit_tree():
	chunk_loader.quit()
		
func _ready():
	for c in get_children():
		if c.name.begins_with("chunk"):
			chunks[c.name] = c
	chunk_loader = ChunkLoader.new(chunks)
	print("Readying world...")
	
	update_active_chunks(player_last_position)

func _process(delta):
	time += delta
	var player_new_position = player.global_transform.origin
	apply_fog(player_new_position.y)
	if (player_last_position - player_new_position).length_squared() >= MIN_SQDIST_UPDATE:
		get_tree().call_group("distance_activated", "process_player_distance", player_new_position)
		detect_enemies(delta)
		update_active_chunks(player_new_position)
		player_last_position = player_new_position
		if player_last_position.y < -8000:
			player.fall_to_death()

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
	print("Update chunks.")
	for ch in chunks.values():
		var local : Vector3 = position - ch.global_transform.origin
		var hlocal : Vector3 = local
		hlocal.y = 0
		var load_zone: AABB = ch.get_aabb().grow(Global.render_distance*MIN_DIST_LOAD)
		var must_load_zone: AABB = ch.get_aabb().grow(MIN_DIST_MUST_LOAD)
		# Reimplement load_sync and unloading over time
		if load_zone.has_point(local) or must_load_zone.has_point(hlocal):
			if !chunk_loader.is_active(ch.name):
				chunk_loader.queue_load(ch.name)
		elif chunk_loader.is_active(ch.name):
			chunk_loader.queue_unload(ch.name)


func apply_fog(height: float):
	var factor := clamp((height - FOG_MIN_HEIGHT)/(FOG_MAX_HEIGHT - FOG_MIN_HEIGHT), 0, 1)
	fog_defaults.end = lerp(FOG_DISTANCE_MIN, FOG_DISTANCE_MAX, factor)
	if !env_override:
		env.environment.fog_depth_end = fog_defaults.end

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
