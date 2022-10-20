tool
extends Chunk

export(String) var safe_stat := "112_safe"
var tracked_stats := ["capacitor_113", "hdw_gate"]

func _ready():
	var _x = Global.connect("stat_changed", self, "_on_stat_changed")

func _on_stat_changed(stat, _value):
	if stat in tracked_stats:
		var safe_gate = Global.stat("hdw_gate") and !Global.stat("capacitor_113")
		Global.set_stat(safe_stat, safe_gate)
