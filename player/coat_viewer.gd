extends MeshInstance

var meshes := {
	"double-breasted": preload("res://_glb/characters/jackie/base_mesh_coat.mesh"),
	"flight_jacket": preload("res://_glb/characters/jackie/coats/flight-jacket_mesh.mesh")
}

onready var skin_material:Material = $"../jackie".get_surface_material(0)

onready var materials := {
	"double-breasted": skin_material,
	"flight_jacket": [
		preload("res://material/coat/mat2/flight_jacket.material"),
		skin_material
	]
}

func set_coat_type(type: String):
	mesh = meshes[type]
	if type in materials:
		if materials[type] is Array:
			for i in materials[type].size():
				set_surface_material(1+i, materials[type][i])
		else:
			set_surface_material(1, materials[type])
