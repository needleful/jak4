extends Spatial

export(int) var required_power := 1
# Only for triggering doors through events persistently
export(String) var tracked_stat = ""
export(bool) var generate_stat = false

var power := 0
var open := false

func _ready():
	if tracked_stat != "" or generate_stat:
		if generate_stat:
			tracked_stat = str(get_path())+"/opened"
		var stat_power = Global.stat(tracked_stat)
		add_power(stat_power)
		var _x = Global.connect("stat_changed", self, "_on_stat_changed")

func _on_stat_changed(stat, value):
	if stat == tracked_stat:
		power = 0
		add_power(value)

func _on_activated():
	add_power()

func add_power(amount:= 1):
	power += amount
	var should_open := power >= required_power
	if should_open and !open:
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("Activate")
	elif !should_open and open:
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play_backwards("Activate")
	open = should_open
