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

	CustomGames.start(self)
	CustomGames.set_spawn($player_start.global_transform)
	player = Global.get_player()
	var _x = player.connect("died", self, "_on_player_died")
	
	timer.start(time_limit)
	set_process(true)
	
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

func _process(_delta):
	overlay.time_remaining = timer.time_left

func _on_player_died():
	_end()

func _on_timeout():
	player.celebrate()
	overlay.time_remaining = 0
	_end()

func _end():
	# TODO: potentially have custom end titles, 
	# like "Player Defeated", "Enemies Defeated", or "Time's Up"
	if CustomGames.active_game == self:
		CustomGames.end(true)
	if player.is_connected("died", self, "_on_player_died"):
		player.disconnect("died", self, "_on_player_died")
	set_process(false)
	overlay = null
	timer.stop()

func end():
	pass
