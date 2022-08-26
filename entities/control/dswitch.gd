extends Spatial

signal activated
signal toggled(on)

export(bool) var on := false
export(float) var time_deactivate := 0.0
export(bool) var persistent := false

onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	if persistent and Global.has_stat(get_stat()):
		on = Global.stat(get_stat())
	set_on(on, true)

func _on_damaged(_damage, dir):
	$AudioStreamPlayer3D.play()
	var switch_on = dir.dot(global_transform.basis.z) > 0.0
	set_on(switch_on)

func set_on(switch_on, force := false, auto := false):
	anim.stop()
	
	if switch_on and on and !force and !auto:
		anim.play("AlreadyOn")
	elif !switch_on and !on and !force and !auto:
		anim.play("AlreadyOff")
	elif switch_on:
		emit_signal("activated")
		emit_signal("toggled", true)
		anim.play("SwitchOn")
		if time_deactivate > 0:
			$deactivate_timer.start(time_deactivate)
	else:
		emit_signal("toggled", false)
		if auto and anim.has_animation("AutoDeactivate"):
			anim.play("AutoDeactivate")
		else:
			anim.play("SwitchOff")
	
	on = switch_on
	if persistent and !force:
		Global.set_stat(get_stat(), on)

func _on_deactivate_timer_timeout():
	set_on(false, false, true)

func get_stat():
	return str(get_path()) + "/on"
