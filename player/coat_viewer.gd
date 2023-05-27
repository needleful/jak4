extends MeshInstance

var meshes := {
	"double-breasted": preload("res://_glb/characters/jackie/base_mesh_coat.mesh"),
	"flight_jacket": preload("res://_glb/characters/jackie/coats/flight-jacket_mesh.mesh")
}

var materials := {
	"flight_jacket": preload("res://material/coat/mat2/flight_jacket.material")
}

func set_coat_type(type: String):
	mesh = meshes[type]
	if type in materials:
		set_surface_material(1, materials[type])
