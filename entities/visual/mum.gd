extends Spatial

export(Material) var hologram_material
var mum_material: Material
var detail_material: Material

func _ready():
	mum_material = $Armature/Skeleton/mum.material_override
	detail_material = $Armature/Skeleton/mum_deatail.material_override
	if !Global.stat("mum/info"):
		$Armature/Skeleton/mum.material_override = hologram_material
		$Armature/Skeleton/mum_deatail.material_override = hologram_material
	var _x = Global.connect("stat_changed", self, "_on_stat_changed")

func _on_stat_changed(stat, _val):
	if stat == "mum/info":
		$Armature/Skeleton/mum.material_override = mum_material
		$Armature/Skeleton/mum_deatail.material_override = detail_material
