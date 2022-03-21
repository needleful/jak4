extends Spatial

var anim: AnimationPlayer
var active := false

func _ready():
	if has_node("AnimationPlayer"):
		anim = $AnimationPlayer
	if Global.valid_game_state:
		if Global.is_activated(self):
			print("Auto activate")
			activate(true)
		else:
			print("NOT activated")

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
