tool
extends Spatial

signal activated
signal deactivated
signal endgame
export(bool) var preview setget set_preview

var visual_name := "Mum"

func sit():
	var p:PlayerBody = Global.get_player()
	p.set_visual_position($chair.global_transform)
	p.anim_play("M_Sitting-loop", "M_Sitting-loop")
	return true

# Eventually there will be multiple exit animations 
func exit(_fast:bool = false):
	var p:PlayerBody = Global.get_player()
	p.set_visual_position($chair.global_transform.translated(-global_transform.basis.z*0.5))
	p.anim_exit("M_Sitting-loop")
	$activator.play("Deactivate")
	emit_signal("deactivated")
	$DialogTrigger.show()
	$mum.bye()
	return true

func activate():
	var _x = Global.add_stat("medium/activated")
	$activator.play("Activate")
	emit_signal("activated")
	$DialogTrigger.hide()
	return true

func show_mum():
	$mum.hello()

func set_preview(p):
	if !Engine.editor_hint:
		return
	preview = p
	if preview:
		$activator.play("Activate")
	else:
		$activator.play("Deactivate")

func end_game():
	$DialogTrigger.deactivate()
	emit_signal("endgame")
