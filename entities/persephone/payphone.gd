extends Spatial

export(bool) var enabled := false
export(AudioStream) var ring_sound
export(float) var min_player_distance := 80.0
export(Resource) var dialog_sequence
export(String) var location
var visual_name := "Persephone"

onready var dialog_circle := $dialog_circle
onready var dialog_trigger := $dialog_circle/DialogTrigger

const calling_stat := "persephone/calling"

var ringing := false

func _ready():
	dialog_trigger.dialog_sequence = dialog_sequence
	if enabled:
		enable()
		var _x = Global.connect("stat_changed", self, "_on_stat_changed")
		if Global.stat(calling_stat):
			ring()
		else:
			stop_ring()
	else:
		disable()

func _on_stat_changed(stat, value):
	if stat == calling_stat:
		if value:
			ring()
		else:
			stop_ring()

func _exit_tree():
	if !dialog_circle.is_inside_tree():
		dialog_circle.free()

func _process(_delta):
	var p := Global.get_player()
	if !p:
		disable()
		return
	var pos :Vector3 = p.global_transform.origin
	var dist := (pos - global_transform.origin).length()
	var in_range := dist < 80.0
	var playing:bool = $ringer.is_playing()
	if in_range and !playing:
		$ringer.play("Ring")
	elif !in_range and playing:
		$ringer.queue("RESET")

func calling_from(p_location):
	return location == p_location

func enable():
	enabled = true
	if !dialog_circle.is_inside_tree():
		add_child(dialog_circle)

func disable():
	if dialog_circle.is_inside_tree():
		remove_child(dialog_circle)
	stop_ring()

func ring():
	set_process(true)
	dialog_trigger.custom_entry = "called"

func stop_ring():
	set_process(false)
	dialog_trigger.custom_entry = "player_calling"
	$ringer.play("RESET")
