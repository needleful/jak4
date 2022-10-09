extends Node
class_name Door

signal opened
signal closed
signal toggled(value)

export(int) var required_power := 1
# Only for triggering doors through events persistently
export(String) var tracked_stat = ""
export(bool) var generate_stat = false
export(bool) var open := false
export(bool) var deactivate_upon_death := false

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
		add_power(stat_power, true)
		var _x = Global.connect("stat_changed", self, "_on_stat_changed")
	if open:
		open = false
		add_power(required_power, true)
	else:
		if anim and anim.has_animation("Deactivate"):
			anim.play("Deactivate")
			anim.advance(anim.current_animation_length)
	if deactivate_upon_death:
		var _x = Global.get_player().connect("died", self, "clear_power", [true])
	assert(anim != null, get_path())

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

func _on_toggled(active, instant := false):
	add_power(1 if active else -1, instant)

func clear_power(instant := false):
	add_power(-power, instant)

func add_power(amount:= 1, instant := false):
	power += amount
	if power <= 0:
		# Dumb bug I introduced
		power = 0
	var should_open := power >= required_power
	if open_stat != "":
		Global.set_stat(open_stat, should_open)
	
	if should_open and !open:
		if anim.has_animation("Activate"):
			anim.play("Activate")
			if instant:
				anim.advance(anim.current_animation_length)
		else:
			anim.play_backwards("Deactivate")
			if instant:
				anim.seek(0)
		emit_signal("opened")
		emit_signal("toggled", true)
		print("opening ", name)
	elif !should_open and open:
		print("deactivating")
		if anim.has_animation("Deactivate"):
			anim.play("Deactivate")
			if instant:
				anim.advance(anim.current_animation_length)
		else:
			anim.play_backwards("Activate")
			if instant:
				anim.seek(0)
		emit_signal("closed")
		emit_signal("toggled", false)
		print("closing ", name)
	open = should_open
