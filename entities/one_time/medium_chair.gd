extends Spatial

signal activated
signal deactivated

var visual_name := "Mum"

func sit():
	var p:PlayerBody = Global.get_player()
	p.set_visual_position(global_transform)
	p.anim_play("M_Sitting-loop", "M_Sitting-loop")
	return true

# Eventually there will be multiple exit animations 
func exit(_fast:bool = false):
	var p:PlayerBody = Global.get_player()
	p.set_visual_position(global_transform.translated(-global_transform.basis.z*0.5))
	p.anim_exit("M_Sitting-loop")
	emit_signal("deactivated")
	return true

func activate():
	var _x = Global.add_stat("medium/activated")
	emit_signal("activated")
	return true
