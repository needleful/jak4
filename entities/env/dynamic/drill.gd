extends Spatial

export(bool) var active := true
export(Material) var active_material
export(Material) var inactive_material

func _ready():
	set_active(active)

func set_active(a: bool):
	active = a
	$hurtbox/CollisionShape.disabled = !active
	if active:
		$MeshInstance.material_override = active_material
	else:
		$MeshInstance.material_override = inactive_material

func _on_toggled(a: bool):
	set_active(a)
