extends Node
class_name Door

export(int) var required_power := 1
# Only for triggering doors through events persistently
export(String) var tracked_stat = ""
export(bool) var generate_stat = false
export(bool) var open := false

var open_stat := ""

var power := 0
onready var anim = $AnimationPlayer

func _ready():
	if !is_in_group("dynamic"):
		add_to_group("dynamic")
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

func _on_deactivated():
	add_power(-1)

func _on_toggled(active):
	add_power(1 if active else -1)

func add_power(amount:= 1):
	power += amount
	if power <= 0:
		# Dumb bug I introduced
		power = 0
	var should_open := power >= required_power
	if open_stat != "":
		Global.set_stat(open_stat, should_open)
	
	if is_inside_tree():
		if should_open and !open:
			if anim.has_animation("Activate"):
				anim.play("Activate")
			else:
				anim.play_backwards("Deactivate")
		elif !should_open and open:
			if anim.has_animation("Deactivate"):
				anim.play("Deactivate")
			else:
				anim.play_backwards("Activate")
	open = should_open
