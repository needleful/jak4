extends Spatial

signal activated

export(bool) var active := false
var anim: AnimationPlayer

func _ready():
	if has_node("AnimationPlayer"):
		anim = $AnimationPlayer
	if Global.valid_game_state:
		if active or Global.is_activated(self):
			activate(true)

func _on_Area_body_entered(_body):
	if active:
		return
	if Global.remove_item("capacitor"):
		activate()

func activate(auto: bool = false):
	$capacitor.visible = true
	active = true
	if anim:
		anim.play("Activate")
		if auto:
			anim.seek(anim.current_animation_length)
	if !auto: 
		Global.mark_activated(self)
	emit_signal("activated")
