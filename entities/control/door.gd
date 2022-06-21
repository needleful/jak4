extends Node

export(int) var required_power := 1
# Only for triggering doors through events persistently
export(String) var tracked_stat = ""
export(bool) var generate_stat = false
export(bool) var open := false

var open_stat := ""

var power := 0

func _ready():
	if generate_stat:
		tracked_stat = str(get_path())
	if tracked_stat != "":
		open_stat = tracked_stat + "/open"
		var stat_power = Global.stat(tracked_stat)
		add_power(stat_power)
		var _x = Global.connect("stat_changed", self, "_on_stat_changed")
	if open:
		open = false
		add_power(required_power)

func _on_stat_changed(stat, value):
	if stat == tracked_stat:
		power = 0
		add_power(value)

func _on_signal(_arg):
	add_power()

func _on_activated():
	add_power()

func _on_toggled(active):
	print("Toggled: ", active)
	add_power(1 if active else -1)

func add_power(amount:= 1):
	power += amount
	if power <= 0:
		# Dumb bug I introduced
		power = 0
	var should_open := power >= required_power
	if open_stat != "":
		Global.set_stat(open_stat, should_open)
	
	if should_open and !open:
		if has_node("AnimationPlayer"):
			print("Opening...")
			$AnimationPlayer.play("Activate")
		else:
			print("ERROR: %s has no AnimationPlayer" % name)
	elif !should_open and open:
		if has_node("AnimationPlayer"):
			print("Closing...")
			$AnimationPlayer.play_backwards("Activate")
	open = should_open
