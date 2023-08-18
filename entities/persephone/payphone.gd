extends Spatial

export(bool) var enabled := false
export(AudioStream) var ring_sound
export(float) var min_player_distance := 80.0
export(Resource) var dialog_sequence
export(String) var location
var visual_name := "Persephone"

onready var dialog_circle := $dialog_circle
onready var dialog_trigger := $dialog_circle/DialogTrigger

var active := false

func _ready():
	dialog_trigger.dialog_sequence = dialog_sequence
	if enabled and Global.stat("persephone/calling"):
		activate()
	else:
		deactivate()

func _exit_tree():
	if !dialog_circle.is_inside_tree():
		dialog_circle.free()

func _process(_delta):
	var p := Global.get_player()
	if !p:
		deactivate()
		return
	var pos :Vector3 = p.global_transform.origin
	var dist := (pos - global_transform.origin).length()
	var in_range := dist < 80.0
	var ringing:bool = $ringer.is_playing()
	if in_range and !ringing:
		$ringer.play("Ring")
	elif !in_range and ringing:
		$ringer.queue("RESET")

func calling_from(p_location):
	return location == p_location

func activate():
	if !enabled:
		return
	active = true
	set_process(true)
	if !dialog_circle.is_inside_tree():
		add_child(dialog_circle)

func deactivate():
	active = false
	set_process(false)
	if dialog_circle.is_inside_tree():
		remove_child(dialog_circle)
	$ringer.play("RESET")
