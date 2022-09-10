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
		if active or Global.is_activated(self):
			activate(true)
		else:
			deactivate()

func _on_Area_body_entered(_body):
	if active:
		return
	if Global.remove_item("capacitor"):
		activate()

func activate(auto: bool = false):
	$capacitor.show()
	active = true
	if anim:
		anim.play("Activate")
		if auto:
			anim.seek(anim.current_animation_length)
	if !auto: 
		Global.mark_activated(self)
	emit_signal("activated")
	emit_signal("toggled", active)

func deactivate():
	active = false
	$capacitor.hide()
	emit_signal("deactivated")
	emit_signal("toggled", active)
