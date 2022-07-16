extends Spatial

export(float) var bronze_seconds: float
export(float) var silver_seconds: float
export(float) var gold_seconds: float
export(int) var bronze_reward := 3
export(int) var silver_reward := 5
export(int) var gold_reward := 10
export(bool) var gold_gives_coat := true
export(Coat.Rarity) var min_rarity := Coat.Rarity.Uncommon
export(Coat.Rarity) var max_rarity := Coat.Rarity.Rare

const DANGER_TIME := 10.0
const DANGER_COLOR := Color.gold
const EXPIRED_COLOR := Color.salmon
const WON_COLOR := Color.aquamarine

onready var race_start: Spatial = $race_start
onready var race_end: Area = $race_end
onready var timer: Timer = $Timer

const race_overlay: PackedScene = preload("res://ui/games/race_overlay.tscn")

var active := false
var player: PlayerBody
var overlay : Node

func _ready():
	var _x = timer.connect("timeout", self, "_on_timeout")
	_x = race_end.connect("body_entered", self, "_on_race_end")
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
	var res = player.game_ui.start_game("Time")
	if !res:
		return
	player.teleport_to(race_start.global_transform)
	player.game_ui.add_target(race_end)
	overlay = race_overlay.instance()
	player.game_ui.set_overlay(overlay)
	
	overlay.gold = gold_seconds
	overlay.silver = silver_seconds
	overlay.bronze = bronze_seconds
	
	active = true
	set_process(true)
	timer.start(bronze_seconds)

func _on_timeout():
	if active:
		overlay.color_bronze(EXPIRED_COLOR)
		overlay.color_silver(EXPIRED_COLOR)
		overlay.color_gold(EXPIRED_COLOR)
		active = false
		player.game_ui.fail_game()
		set_process(false)
		overlay = null

func _on_race_end(body):
	if active and body == player:
		active = false
		player.game_ui.complete_game()
		set_process(false)
		if timer.time_left > bronze_seconds - gold_seconds:
			overlay.color_gold(WON_COLOR)
			var _x = Global.add_item("bug", gold_reward)
			if gold_gives_coat:
				_x = Global.add_coat(Coat.new(true, min_rarity, max_rarity))
		elif timer.time_left > bronze_seconds - silver_seconds:
			overlay.color_silver(WON_COLOR)
			var _x = Global.add_item("bug", silver_reward)
		else:
			overlay.color_bronze(WON_COLOR)
			var _x = Global.add_item("bug", bronze_reward)
		timer.stop()
		overlay = null
