extends Area

export(float, 0, 80) var wind_reduction_db := 10.0
export(Color) var custom_fog := Color.black
export(float, 0, 100) var fog_start := 10.0
export(float, 0, 2000) var fog_end := 200.0
export(Color) var indirect_light := Color.white
export(bool) var show_sun := true
export(bool) var override_music := false
export(AudioStream) var default_music
export(AudioStream) var combat_music
export(bool) var no_combat := false
export(bool) var close_cam := false

var wind : WindController
var scene: Node
func _ready():
	scene = get_tree().current_scene
	var a = scene.get_wind_audio()
	if a is WindController:
		wind = a
		var _x = connect("body_entered", self, "_on_body_entered")
		_x = connect("body_exited", self, "_on_body_exited")

func _on_body_entered(_body):
	wind.apply_volume(-wind_reduction_db)
	scene = get_tree().current_scene
	if custom_fog != Color.black:
		scene.set_fog_override(custom_fog, fog_start, fog_end)
	if indirect_light != Color.white:
		scene.indirect_light_override(indirect_light)
	if override_music:
		Music.set_music(default_music, combat_music)
	scene.set_sun_enabled(show_sun)
	for c in get_children():
		if c is ReflectionProbe:
			c.show()
	var p = Global.get_player()
	if no_combat:
		p.do_not_disturb = true
	if close_cam:
		p.cam_rig.set_close_cam(true)

func _on_body_exited(_body):
	wind.apply_volume(0)
	if custom_fog != Color.black:
		scene.clear_fog_override()
	if indirect_light != Color.white:
		scene.clear_indirect_light()
	if override_music:
		Music.reset()
	scene.set_sun_enabled(true)
	for c in get_children():
		if c is ReflectionProbe:
			c.hide()
	var p = Global.get_player()
	if no_combat:
		p.do_not_disturb = false
	if close_cam:
		p.cam_rig.set_close_cam(false)
