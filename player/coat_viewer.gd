extends MeshInstance

var meshes := {
	"double-breasted": preload("res://_glb/characters/jackie/base_mesh_coat.mesh"),
	"flight_jacket": preload("res://_glb/characters/jackie/coats/flight-jacket_mesh.mesh")
}

func set_coat_type(type: String):
	mesh = meshes[type]
