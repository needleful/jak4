extends Spatial

signal endgame
signal endgame_completed

export(Material) var hologram_material
var mum_material: Material
var detail_material: Material
var friendly_id := 'mum'

func _ready():
	if Global.stat("mum/end"):
		queue_free()
	mum_material = $Armature/Skeleton/mum.material_override
	detail_material = $Armature/Skeleton/mum_deatail.material_override
	if !Global.stat("mum/info/appearance"):
		$Armature/Skeleton/mum.material_override = hologram_material
		$Armature/Skeleton/mum_deatail.material_override = hologram_material
	var _x = Global.connect("stat_changed", self, "_on_stat_changed")

func _on_stat_changed(stat, _val):
	if stat == "mum/info/appearance":
		$Armature/Skeleton/mum.material_override = mum_material
		$Armature/Skeleton/mum_deatail.material_override = detail_material

func end_game():
	$mum_dialog.deactivate()
	emit_signal("endgame")

func _on_epic_boss_killed():
	var _x = Global.add_stat("mum/end")
	emit_signal("endgame_completed")
	Global.get_player().teleport_to(
		get_tree().current_scene.get_node(
			"endgame_teleport_marker").global_transform)
	get_tree().current_scene.set_time(5.5)
	queue_free()
