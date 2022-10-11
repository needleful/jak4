extends Spatial

signal activated
signal deactivated

signal toggled(active)

export(bool) var active := false
var anim: AnimationPlayer

func _ready():
	if has_node("AnimationPlayer"):
		anim = $AnimationPlayer
	if Global.valid_game_state:
		if Global.has_stat(stat()):
			if Global.stat(stat()):
				activate(true)
			else:
				deactivate(true)
		else:
			Global.set_stat(stat(), active)

func _on_Area_body_entered(_body):
	if active:
		return
	if Global.remove_item("capacitor"):
		activate()

func activate(auto: bool = false):
	active = true
	$capacitor.show()
	if anim:
		anim.play("Activate")
		if auto:
			anim.advance(anim.current_animation_length)
	if !auto:
		Global.set_stat(stat(), active)
	emit_signal("activated")
	emit_signal("toggled", active)

func deactivate(auto := false):
	active = false
	$capacitor.hide()
	if !auto:
		Global.set_stat(stat(), active)
	emit_signal("deactivated")
	emit_signal("toggled", active)

func stat():
	return str(get_path()) + "/activated"
