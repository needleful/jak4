extends Spatial
class_name GameArena

export(int) var bronze_score := 10
export(int) var silver_score := 20
export(int) var gold_score := 40
export(float) var time_limit := 60.0
export(String) var friendly_id := ""
const arena_overlay: PackedScene = preload("res://ui/games/arena_overlay.tscn")
var timer : Timer
var player : PlayerBody
var overlay: Control
var respawn := false
var dialog_allowed := false

var title := "Arena Score"
onready var id := hash(get_path())
onready var spawns := $spawns

var active_enemies := 0
var score := 0

const PLAYER_DEATH_PENALTY := -75
const POINTS_PER_HP := {
	"default":1
}

const COMBO_DRAIN := 0.1
const COMBO_DAMAGE_DRAIN := 0.5
const WON_COLOR := Color.aquamarine

var crawly_scene: PackedScene = load("res://entities/enemies/crawly.tscn")

func _ready():
	if has_node("Timer"):
		timer = $Timer
	else:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
	var _x = timer.connect("timeout", self, "_on_timeout")
	set_process(false)

func start_game():
	if CustomGames.is_active():
		return

	player = Global.get_player()
	Global.save_checkpoint(player.global_transform)
	
	CustomGames.start(self)
	player.teleport_to($player_start.global_transform)
	var _x = player.connect("died", self, "_on_player_died")
	_x = player.connect("damaged", self, "_on_player_damaged")
	
	timer.start(time_limit)
	set_process(true)
	
	active_enemies = 0
	score = 0
	
	overlay = arena_overlay.instance()
	overlay.gold = gold_score
	overlay.silver = silver_score
	overlay.bronze = bronze_score
	if CustomGames.has_stat(self, "best"):
		var best: float = CustomGames.stat(self, "best")
		overlay.set_best(best)
	player.game_ui.set_overlay(overlay)
	overlay.combo = 0
	overlay.combo_countdown = 0
	player.game_ui.set_value(0)
	spawn_wave(5)

func _process(delta):
	overlay.time_remaining = timer.time_left
	overlay.combo_countdown -= COMBO_DRAIN*delta
	if overlay.combo_countdown <= 0:
		overlay.combo = 0

func add_points(points: int):
	score += int(points*max(overlay.combo, 1))
	player.game_ui.set_value(score)
	if score > bronze_score:
		overlay.color_bronze(WON_COLOR)
	if score > silver_score:
		overlay.color_silver(WON_COLOR)
	if score > gold_score:
		overlay.color_gold(WON_COLOR)

func _on_enemy_died(enemy_id, path):
	var e:EnemyBody = get_tree().current_scene.get_node(path)
	if e:
		var p:int = POINTS_PER_HP["default"]
		if enemy_id in POINTS_PER_HP:
			p = POINTS_PER_HP[enemy_id]
		var hp := e.starting_health
		add_points(hp*p)
	overlay.combo_countdown = 1
	overlay.combo += 1
	active_enemies -= 1
	if active_enemies < 2:
		spawn_wave(5)

func spawn_wave(count:int):
	for i in count:
		var index:int = i % spawns.get_child_count()
		var spawn_loc := spawns.get_child(index)
		var crawly := crawly_scene.instance()
		spawn_loc.add_child(crawly)
		crawly.global_transform = spawn_loc.global_transform
		crawly.extra_chase_time = time_limit
		crawly.call_deferred("aggro_to", player)
		crawly.add_to_group("arena_enemy")
		var _x = crawly.connect("died", self, "_on_enemy_died")
	active_enemies += count

func _on_player_died():
	add_points(PLAYER_DEATH_PENALTY)
	_end()

func _on_player_damaged():
	overlay.combo_countdown -= COMBO_DAMAGE_DRAIN

func _on_timeout():
	player.celebrate()
	overlay.time_remaining = 0
	_end()

func _end():
	# TODO: potentially have custom end titles, 
	# like "Player Defeated", "Enemies Defeated", or "Time's Up"
	CustomGames.end(true)

func end():
	var previous_best = CustomGames.stat(self, "best")
	var previous_award = CustomGames.stat(self, "award")
	if score > previous_best:
		CustomGames.set_stat(self, "best", score)
		overlay.new_best(score)
	get_tree().call_group("arena_enemy", "queue_free")
	if player.is_connected("died", self, "_on_player_died"):
		player.disconnect("died", self, "_on_player_died")
	set_process(false)
	overlay = null
	timer.stop()

func award_name():
	return CustomGames.Award.keys()[CustomGames.stat("award") - 1]

func completed():
	return CustomGames.has_stat(self, "best")
