extends Spatial

export(Material) var flag_material
onready var body := $SoftBody

func _ready():
	if flag_material:
		body.material_override = flag_material
