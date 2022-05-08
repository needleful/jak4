extends Spatial

var custom_coat_stat = ""

onready var hat = $Armature/Skeleton/attach_hat/ref_hat/MeshInstance

func _ready():
	var p = get_parent()
	if p and ("friendly_id" in p) and (p.friendly_id != ""):
		custom_coat_stat = p.friendly_id + "/coat"
	if p and "accessory" in p and p.accessory:
		hat.mesh = p.accessory
	var coat = Global.stat(coat_stat())
	if !coat:
		coat = Global.set_stat(coat_stat(), Coat.new(true))
	show_coat(coat)

func coat_stat() -> String:
	if custom_coat_stat == "":
		return str(get_path()) + "/coat"
	else:
		return custom_coat_stat

func show_coat(coat: Coat):
	var mat = coat.generate_material(false)
	$Armature/Skeleton/body.set_surface_material(1, mat)
	hat.material_override = mat
