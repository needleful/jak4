extends Spatial

export(Dictionary) var slots := {
	"fullbody" : NodePath("Skeleton/fullbody"),
	"hat": NodePath("Skeleton/hat"),
	"shirt": NodePath("Skeleton/shirt"),
	"pants": NodePath("Skeleton/pants"),
	"head":NodePath("Skeleton/head"),
	"eyebrows":NodePath("Skeleton/eyebrows"),
	"hair":NodePath("Skeleton/head_attach/hair")
}
# Nodes will be retrieved from the paths in the slots
var nodes : Dictionary

export(Dictionary) var outfit := {
	"fullbody": null,
	"hat":null,
	"pants":null,
	"shirt":null,
	"head":null,
	"eyebrows":null,
	"hair":null,
	"eyes":null,
	"skin_texture":null,
	"skin_color":Color.green,
	"mouth":null,
	"size":0.0,
	# GradientTexture
	"hair_color":null,
	# Detail texture
	"hair_texture":null
}

# Items which are not meshes and have to be handled specially
const special_items := ["eyes", "hair", "skin_texture", "skin_color", "mouth", "size"]

var defaults: Dictionary
export(Resource) var eye_set
export(Resource) var mouth_set
export(int) var blink_frame: int setget set_blink_frame
export(bool) var defaults_only := false
export(Material) var skin_material
export(Material) var eye_material
export(Material) var hair_material

func _ready():
	defaults = outfit.duplicate()
	for s in slots:
		nodes[s] = get_node(slots[s])

func refresh():
	if defaults_only:
		outfit = defaults
	else:
		for key in defaults.keys():
			if !(key in outfit) or (
				outfit[key] is String and outfit[key] == "default"
			):
				outfit[key] = defaults[key]

	if outfit.hair and !outfit.hat:
		nodes.hat.hide()
		nodes.hair.show()
	else:
		nodes.hair.hide()
		nodes.hat.show()

	if (!outfit.pants and !outfit.shirt):
		nodes.pants.hide()
		nodes.shirt.hide()
		nodes.fullbody.show()
	else:
		nodes.pants.show()
		nodes.shirt.show()
		nodes.fullbody.hide()
	
	if "hair" in outfit:
		var o: PackedScene = outfit["hair"]
		if !o:
			o = defaults["hair"]
		if o:
			var n: Node = nodes["hair"]
			Util.clear(n)
			var hair := o.instance()
			n.add_child(hair)
			hair.mesh.set_surface_material(0, hair_material)

	if "eyes" in outfit:
		var e:EyeSet = outfit["eyes"]
		if !e:
			e = defaults["eyes"]
		if e:
			eye_set = e
			set_blink_frame(0)
			eye_material.set_shader_param(
				"iris_texture", eye_set.iris)
		
	if "skin_texture" in outfit:
		skin_material.set_shader_param("main_texture", outfit.skin_texture)
	if "skin_color" in outfit:
		skin_material.set_shader_param("albedo", outfit.skin_color)
	
	for mesh in outfit:
		if mesh in special_items:
			continue

		if outfit[mesh]:
			nodes[mesh].mesh = outfit[mesh]
		else:
			nodes[mesh].mesh = defaults[mesh]
	
	# Notes on materials
	# Head: surface 0 is skin, surface 1 is eyes, surface 2 is mouth
	# Hat: surface 0 is clothes, surface 1 is hair
	# Hair and eyebrows: surface 0 is hair, surface 1 is accessories
	# Other things: surface 0 is the clothing, surface 1 is skin
	for n in nodes:
		var m := nodes[n] as MeshInstance
		if !m:
			continue
		if n == "head":
			m.set_surface_material(0, skin_material)
			if m.get_surface_material_count() > 1:
				m.set_surface_material(1, eye_material)
		elif n == "hat":
			if m.get_surface_material_count() > 1:
				m.set_surface_material(1, hair_material)
		elif n == "eyebrows":
			m.set_surface_material(0, hair_material)
		elif m.get_surface_material_count() > 1:
			m.set_surface_material(1, skin_material)
	nodes.pants.skin = nodes.fullbody.skin
	nodes.shirt.skin = nodes.fullbody.skin
	

func set_blink_frame(frame: int):
	blink_frame = frame
	if frame >= eye_set.sprites.size():
		frame = 0
	eye_material.set_shader_param(
		"main_texture", eye_set.sprites[frame])
