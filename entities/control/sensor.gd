extends Area

signal toggled(value)
signal locked

export(String) var key_item := ""
export(String) var stat := "tablet_key/used"

const sound_locked := preload("res://audio/env/door_locked.ogg")
const sound_opened := preload("res://audio/env/door_open.ogg")

onready var audio := $audio as AudioStreamPlayer3D

var active := false

func _ready():
	var _x = connect("body_entered", self, "_on_body_entered", [], CONNECT_DEFERRED)
	_x = connect("body_exited", self, "_on_body_exited", [], CONNECT_DEFERRED)
	assert(audio)

func _on_body_entered(body):
	if body is PlayerBody and !Global.count(key_item):
		audio.stop()
		audio.stream = sound_locked
		audio.play()
		emit_signal("locked")
		return
	if !active:
		audio.stop()
		audio.stream = sound_opened
		audio.play()
		emit_signal("toggled", true)
		if stat != "":
			var _x = Global.add_stat(stat)
	active = true

func _on_body_exited(_body):
	var should_be_active = !get_overlapping_bodies().empty()
	if active and !should_be_active:
		emit_signal("toggled", false)
		active = false
