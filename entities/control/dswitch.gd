extends Spatial

signal activated
signal toggled(on)
signal insta_toggled(on)
signal arg_toggled(on, instant)

export(bool) var on := false
export(float) var time_deactivate := 0.0
export(bool) var persistent := false
export(bool) var reset_upon_death := false

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready():
	if persistent and Global.has_stat(get_stat()):
		on = Global.stat(get_stat())
	if reset_upon_death:
		var _x = Global.get_player().connect("died", self, "set_on", [on, true])
	set_on(on, true)

func activate():
	set_on(true)

func deactivate():
	set_on(false, false, true)

func _on_damaged(_damage, dir):
	var switch_on = dir.dot(global_transform.basis.z) > 0.0
	set_on(switch_on)

func set_on(switch_on, force := false, auto := false):
	anim.stop()
	
	if switch_on and on and !force and !auto:
		anim.play("AlreadyOn")
		sound.pitch_scale = 0.7
		sound.play()
	elif !switch_on and !on and !force and !auto:
		anim.play("AlreadyOff")
		sound.pitch_scale = 0.7
		sound.play()
	elif switch_on:
		emit_signal("activated")
		anim.play("SwitchOn")
		if time_deactivate > 0:
			$deactivate_timer.start(time_deactivate)
	else:
		if auto and anim.has_animation("AutoDeactivate"):
			anim.play("AutoDeactivate")
		else:
			anim.play("SwitchOff")
	if force:
		emit_signal("insta_toggled", switch_on)
	elif switch_on != on:
		emit_signal("toggled", switch_on)
		if !auto:
			sound.pitch_scale = 1.0
			sound.play()
		else:
			# play a third sound here
			pass

	if switch_on != on:
		emit_signal("arg_toggled", switch_on, force)
		
	on = switch_on
	if persistent and !force:
		Global.set_stat(get_stat(), on)

func _on_deactivate_timer_timeout():
	set_on(false, false, true)

func get_stat():
	return str(get_path()) + "/on"
