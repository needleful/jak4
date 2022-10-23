extends Spatial
class_name GameRace

enum Award {
	Bronze = 1,
	Silver = 2,
	Gold = 3
}

export(float) var bronze_seconds: float
export(float) var silver_seconds: float
export(float) var gold_seconds: float
export(int) var bronze_reward := 3
export(int) var silver_reward := 5
export(int) var gold_reward := 10
export(bool) var gold_gives_coat := true
export(Coat.Rarity) var min_rarity := Coat.Rarity.Uncommon
export(Coat.Rarity) var max_rarity := Coat.Rarity.Rare
export(String) var friendly_id := ""
export(bool) var hover_scooter := false
export(Array, String) var required_items := []
export(Array, NodePath) var checkpoints := []

const DANGER_TIME := 10.0
const DANGER_COLOR := Color.gold
const EXPIRED_COLOR := Color.salmon
const WON_COLOR := Color.aquamarine

onready var race_start: Spatial = $race_start
onready var race_end: Area = $race_end
onready var timer: Timer

var remaining_points := []
var next_point : Area

const race_overlay: PackedScene = preload("res://ui/games/race_overlay.tscn")
const coat_scene : PackedScene = preload("res://items/coat_pickup.tscn")

var active := false
var player: PlayerBody
var overlay : Node

func _ready():
	if has_node("Timer"):
		timer = $Timer
	else:
		timer = Timer.new()
		add_child(timer)
	timer.one_shot = true
	var _x = timer.connect("timeout", self, "_fail")
	set_process(false)

func _process(_delta):
	var running_time := bronze_seconds - timer.time_left
	player.game_ui.value = "%.2f" % running_time
	
	if running_time > gold_seconds:
		overlay.color_gold(EXPIRED_COLOR)
	elif running_time + DANGER_TIME > gold_seconds:
		overlay.color_gold(DANGER_COLOR)
	
	if running_time > silver_seconds:
		overlay.color_silver(EXPIRED_COLOR)
	elif running_time + DANGER_TIME > silver_seconds:
		overlay.color_silver(DANGER_COLOR)
	
	if running_time + DANGER_TIME > bronze_seconds:
		overlay.color_bronze(DANGER_COLOR)

func start_race():
	player = Global.get_player()
	if hover_scooter and Global.count("hover_scooter"):
		player.call_deferred("set_state", player.State.Hover)
	else:
		player.can_use_hover_scooter = false
	var res = player.game_ui.start_game("Time")
	if !res:
		return
	remaining_points = []
	for point in checkpoints:
		if has_node(point):
			remaining_points.append(get_node(point))

	Global.save_checkpoint(race_start.global_transform.origin)
	player.teleport_to(race_start.global_transform)
	
	overlay = race_overlay.instance()
	overlay.gold = gold_seconds
	overlay.silver = silver_seconds
	overlay.bronze = bronze_seconds
	if Global.has_stat(get_stat() + "/best"):
		var best: float = Global.stat(get_stat() + "/best")
		overlay.set_best(best)
	
	connect_next_point(null)
	var _x = player.game_ui.connect("cancelled", self, "_fail")
	player.game_ui.set_overlay(overlay)
	
	active = true
	set_process(true)
	timer.start(bronze_seconds)

func connect_next_point(_body):
	if next_point:
		print("Passed ", next_point.name)
		player.game_ui.remove_target(next_point)
	if remaining_points.empty():
		player.game_ui.add_target(race_end)
		var _x = race_end.connect("body_entered", self, "_on_race_end", [], CONNECT_ONESHOT)
	else:
		next_point = remaining_points.pop_front()
		player.game_ui.add_target(next_point)
		var _x = next_point.connect("body_entered", self, "connect_next_point", [], CONNECT_ONESHOT)

func _fail():
	if active:
		var _x = Global.add_stat(get_stat() + "/failed")
		player.game_ui.fail_game()
		overlay.color_bronze(EXPIRED_COLOR)
		overlay.color_silver(EXPIRED_COLOR)
		overlay.color_gold(EXPIRED_COLOR)
		_end()

func _end():
	player.can_use_hover_scooter = true
	print("game ended")
	player.game_ui.disconnect("cancelled", self, "_on_timeout")
	active = false
	set_process(false)
	overlay = null
	timer.stop()

func _on_race_end(body):
	if !active or body != player:
		return

	var _x = Global.add_stat(get_stat() + "/won")
	var last_award: int = Global.stat(get_stat() + "/award")
	var best_time: float = Global.stat(get_stat() + "/best")
	var race_time = bronze_seconds - timer.time_left
	
	if best_time == 0 or race_time < best_time:
		Global.set_stat(get_stat() + "/best", race_time)
		overlay.new_best(race_time)

	player.game_ui.complete_game()
	player.celebrate("", null)
	
	var award: int
	if race_time <= gold_seconds:
		overlay.color_gold(WON_COLOR)
		award = Award.Gold
	elif race_time <= silver_seconds:
		overlay.color_silver(WON_COLOR)
		award = Award.Silver
	else:
		overlay.color_bronze(WON_COLOR)
		award = Award.Bronze
	
	_end()
	
	if award <= last_award:
		return
	Global.set_stat(get_stat() +"/award", award)
	
	if award >= Award.Bronze and last_award < Award.Bronze:
		_x = Global.add_item("bug", bronze_reward)
		_x = Global.add_item("bronze_medal")
	if award >= Award.Silver and last_award < Award.Silver:
		_x = Global.add_item("bug", silver_reward)
		_x = Global.add_item("silver_medal")
	if award >= Award.Gold and last_award < Award.Gold:
		_x = Global.add_item("bug", gold_reward)
		_x = Global.add_item("gold_medal")
		if gold_gives_coat:
			var c = coat_scene.instance()
			c.coat = Coat.new(true, min_rarity, max_rarity)
			c.gravity = true
			race_end.add_child(c)
			c.global_transform = race_end.global_transform

func get_stat():
	if friendly_id != "":
		return friendly_id 
	else:
		return str(get_path())

func has_required_items():
	for c in required_items:
		var stats = c.split("*")
		var count := 1
		if stats.size() > 1:
			count = int(stats[1])
		if !Global.count(stats[0]) >= count:
			return false
	return true
