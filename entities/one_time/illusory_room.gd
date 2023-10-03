tool
extends Spatial

signal activated
signal deactivated
signal endgame
export(bool) var preview setget set_preview
export(bool) var rooms_visible setget set_rooms_visible
export(String) var dialog_entry := ""

var visual_name := "Mum"

func _ready():
	if dialog_entry != "":
		$DialogTrigger.custom_entry = dialog_entry

func sit():
	var p:PlayerBody = Global.get_player()
	p.set_visual_position($chair.global_transform)
	p.anim_play("M_SitLeft", "M_Sitting-loop")
	return true

# Eventually there will be multiple exit animations 
func exit():
	var p:PlayerBody = Global.get_player()
	var pos :Transform= $chair.global_transform.translated(Vector3(0,0,0.5))
	p.set_visual_position(pos)
	$activator.play("Deactivate")
	emit_signal("deactivated")
	$DialogTrigger.show()
	if $mum.visible:
		$mum.bye()
	return true

func activate(mode := "default"):
	match mode:
		"primordial":
			$primordial_room.show()
			$hologram.hide()
		_:
			$primordial_room.hide()
			$hologram.show()
	var _x = Global.add_stat("medium/activated")
	$activator.play("Activate")
	emit_signal("activated")
	$DialogTrigger.hide()
	return true

func play(anim: String):
	var o := $orchestrator
	if !o.has_animation(anim):
		print_debug("Missing animation: ", anim)
	else:
		$orchestrator.play(anim)

func mum_track_target():
	$mum.track($look_target)

func set_preview(p):
	if !Engine.editor_hint or !has_node("activator"):
		return
	preview = p
	if preview:
		$activator.play("Activate")
	else:
		$activator.play("Deactivate")

func end_game():
	$DialogTrigger.deactivate()
	emit_signal("endgame")

func set_rooms_visible(v):
	rooms_visible = v
	if v:
		if $hologram.visible:
			$hologram.real_object_visible = true
		elif $primordial_room.visible:
			$primordial_room.real_object_visible = true
	else:
		$hologram.real_object_visible = false
		$primordial_room.real_object_visible = false 

func hide_room():
	$hologram.hide()
	$primordial_room.hide()
