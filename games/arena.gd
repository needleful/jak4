extends Spatial
class_name GameArena

signal game_started
signal game_ended

export(String) var friendly_id := ""
const arena_overlay: PackedScene = preload("res://ui/games/arena_overlay.tscn")
var timer : Timer
var player : PlayerBody
var overlay: Control
var respawn := true
var dialog_allowed := false

var title := "Arena Score"
onready var id := hash(get_path())
var spawns: Node
var scenarios : Dictionary
var scenario : ArenaScenario
var cs : CombatScenario

var score := 0
var current_wave := 0

const PLAYER_DEATH_PENALTY := -500
const POINTS_PER_HP := {
	"default":1,
	"deathgnat":2.5
}

const COMBO_DRAIN := 0.07
const COMBO_DAMAGE_DRAIN := 0.25
const WON_COLOR := Color.aquamarine

var scenes := {
	"crawly": load("res://entities/enemies/crawly.tscn"),
	"deathgnat": load("res://entities/enemies/deathgnat.tscn")
}

func _ready():
	if has_node("Timer"):
		timer = $Timer
	else:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
	var _x = timer.connect("timeout", self, "_on_timeout")
	set_process(false)
	clear_scenarios(false)

func clear_scenarios(clear_base: bool):
	for c in get_children():
		if c is ArenaScenario:
			remove_child(c)
			scenarios[c.name] = c
		elif c.name == "base":
			if clear_base:
				remove_child(c)
			else:
				c.show()
			scenarios[c.name] = c

func start_game(p_scenario: String):
	if CustomGames.is_active():
		return
	Music.play_track("tension2.ogg")
	current_wave = 0
	scenario = scenarios[p_scenario]
	player = Global.get_player()
	Global.save_checkpoint(player.global_transform)
	
	CustomGames.start(self)
	var _x = player.connect("died", self, "_on_player_died")
	_x = player.connect("damaged", self, "_on_player_damaged")
	
	clear_scenarios(true)
	cs = scenario.scenario
	_recursive_ready(scenario)
	add_child(scenario)
	scenario.show()
	spawns = scenario.get_node("spawns")
	player.teleport_to(scenario.get_node("player_start").global_transform)
	
	timer.start(scenario.time_limit)
	set_process(true)
	
	score = 0
	
	overlay = arena_overlay.instance()
	overlay.gold = scenario.gold_score
	overlay.silver = scenario.silver_score
	overlay.bronze = scenario.bronze_score
	if CustomGames.has_stat(self, best_stat()):
		var best: float = CustomGames.stat(self, best_stat())
		overlay.set_best(best)
	player.game_ui.set_overlay(overlay)
	overlay.combo = 0
	overlay.combo_countdown = 0
	player.game_ui.set_value(0)
	call_deferred("spawn_wave")
	emit_signal("game_started")

func _recursive_ready(n: Node):
	n.request_ready()
	for c in n.get_children():
		_recursive_ready(c)

func _process(delta):
	overlay.time_remaining = timer.time_left
	overlay.combo_countdown -= COMBO_DRAIN*delta
	if overlay.combo_countdown <= 0:
		overlay.combo = 0

func add_points(points: int):
	var combo_mult := 1 + 0.12*max(overlay.combo, 0)
	var added_points := int(points*combo_mult)
	score += added_points
	player.game_ui.add_value(added_points)
	if score > scenario.bronze_score:
		overlay.color_bronze(WON_COLOR)
	if score > scenario.silver_score:
		overlay.color_silver(WON_COLOR)
	if score > scenario.gold_score:
		overlay.color_gold(WON_COLOR)

func _on_enemy_died(enemy_id, path):
	var e:EnemyBody = get_tree().current_scene.get_node(path)
	var p:int = POINTS_PER_HP["default"]
	if enemy_id in POINTS_PER_HP:
		p = POINTS_PER_HP[enemy_id]
	var hp := e.starting_health
	add_points(hp*p)
	e.remove_from_group("arena_enemy")
	overlay.combo_countdown = 1
	overlay.combo += 1
	var active_enemies := get_tree().get_nodes_in_group("arena_enemy").size()
	if active_enemies <= scenario.min_enemies:
		current_wave += 1
		spawn_wave()
	ObjectPool.timed_delete(e.get_path(), 10)

func spawn_wave():
	var wave = scenario.get_wave(current_wave)
	var spawn_index := 0
	for enemy in wave:
		var eid: String = enemy.replace("+", "")
		if !(eid in scenes):
			continue
		var count = wave[enemy]
		var properties := {}
		var spawn_group := eid
		if count is Dictionary:
			properties = count
			if "_count" in properties:
				count = properties._count
			else:
				count = 1
			if "_spawn" in properties:
				spawn_group = properties._spawn
		
		if !(count is int) and !(count is float):
			print_debug("BAD COUNT for file: ", scenario.scenario.resource_path, "\n\t=>", count)
			count = 5
		for i in count:
			var index:int = spawn_index % spawns.get_child_count()
			while !spawns.get_child(index).is_in_group(spawn_group):
				spawn_index += 1
				index = spawn_index % spawns.get_child_count()
			spawn_index += 1
			
			var spawn_loc := spawns.get_child(index)
			var node:EnemyBody = scenes[eid].instance()
			for field in properties:
				if !field.begins_with("_"):
					node.set(field, properties[field])

			spawn_loc.add_child(node)
			node.global_transform = spawn_loc.global_transform
			if scenario.aggro_automatically:
				node.call_deferred("aggro_to", player)
			node.add_to_group("arena_enemy")
			var _x = node.connect("died", self, "_on_enemy_died")

func _on_player_died():
	overlay.combo = 0
	add_points(PLAYER_DEATH_PENALTY)
	_end()

func _on_player_damaged():
	overlay.combo_countdown -= COMBO_DAMAGE_DRAIN

func _on_timeout():
	player.celebrate()
	overlay.time_remaining = 0
	_end()
	player.teleport_to($base/player_start.global_transform)

func _end():
	CustomGames.add_stat(self, "completed")
	var award := 0
	if score > scenario.gold_score:
		award = CustomGames.Award.Gold
	elif score > scenario.silver_score:
		award = CustomGames.Award.Silver
	elif score > scenario.bronze_score:
		award = CustomGames.Award.Bronze
	var previous_award = CustomGames.stat(self, award_stat())
	if award > previous_award:
		# Add awards for every rank
		for i in range(previous_award+1, award+1):
			var a = ["bronze", "silver", "gold"][i-1]
			print_debug("Awarded: ", a)
			CustomGames.add_stat(self, a)
		CustomGames.set_stat(self, award_stat(), award)

	if award:
		CustomGames.end(true)
	else:
		CustomGames.end(false)

func end():
	Music.stop_music()
	var previous_best = CustomGames.stat(self, best_stat())
	if score > previous_best:
		CustomGames.set_stat(self, best_stat(), score)
		overlay.new_best(score)
	get_tree().call_group("arena_enemy", "disconnect", "died", self, "_on_enemy_died")
	get_tree().call_group("arena_enemy", "queue_free")
	if player.is_connected("died", self, "_on_player_died"):
		player.disconnect("died", self, "_on_player_died")
	if player.is_connected("damaged", self, "_on_player_damaged"):
		player.disconnect("damaged", self, "_on_player_damaged")
	set_process(false)
	overlay = null
	timer.stop()
	clear_scenarios(true)
	add_child(scenarios["base"])
	emit_signal("game_ended")

func get_custom_message():
	return "Final Score: "+ str(score)

func award_stat():
	return "award/"+scenario.name

func best_stat():
	return "best/"+scenario.name

func award_name(p_scenario):
	if CustomGames.has_stat(self, "award/"+p_scenario):
		return CustomGames.Award.keys()[CustomGames.stat(self, "award/"+p_scenario) - 1]
	else:
		return "Never Completed"

func completed(p_scenario = ""):
	if p_scenario == "":
		return CustomGames.has_stat(self, "completed")
	return CustomGames.has_stat(self, "best/"+p_scenario)

func scenario_text(p_scenario):
	if completed(p_scenario):
		return "(Best Rank: %s)" % award_name(p_scenario)
	else:
		return "(New!)"

func rank(x: int):
	return CustomGames.stat(self, "silver") >= x
