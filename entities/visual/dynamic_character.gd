extends Spatial

export(Dictionary) var slots := {
	"fullbody" : NodePath("fullbody"),
	"hat": NodePath("hat"),
	"shirt": NodePath("shirt"),
	"pants": NodePath("pants"),
	"head":NodePath("head"),
	"eyebrows":NodePath("eyebrows"),
	"hair":NodePath("head_attach/hair")
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
	"size":0.0
}

# Items which are not meshes and have to be handled specially
const special_items := ["eyes", "hair", "skin_texture", "skin_color", "mouth", "size"]

var defaults: Dictionary
export(Resource) var eye_set
export(Resource) var mouth_set
export(int) var blink_frame: int setget set_blink_frame
export(bool) var defaults_only := false
export(Material) var skin_material

func _ready():
	for slot in slots:
		nodes[slot] = get_node(slots[slot])
		if nodes[slot] is MeshInstance:
			defaults[slot] = nodes[slot].mesh
	defaults.eyes = eye_set
	defaults.hair = null
	defaults.skin_texture = skin_material.get_shader_param("main_texture")
	defaults.skin_color = skin_material.get_shader_param("albedo")
	defaults.size = 0.0

func refresh():
	if outfit.hair and !outfit.hat and !defaults_only:
		nodes.hat.hide()
		nodes.hair.show()
	else:
		nodes.hair.hide()
		nodes.hat.show()

	if (!outfit.pants and !outfit.shirt) or defaults_only:
		nodes.pants.hide()
		nodes.shirt.hide()
		nodes.fullbody.show()
	else:
		nodes.pants.show()
		nodes.shirt.show()
		nodes.fullbody.hide()
	
	if "hair" in outfit:
		var o: PackedScene = outfit["hair"]
		if !o or defaults_only:
			o = defaults["hair"]
		if o:
			var n: Node = nodes["hair"]
			Util.clear(n)
			n.add_child(o.instance())

	if "eyes" in outfit:
		var e:EyeSet = outfit["eyes"]
		if !e or defaults_only:
			e = defaults["eyes"]
		if e:
			eye_set = e
			set_blink_frame(0)
			var m = nodes["head"] as MeshInstance
			if m:
				m.get_surface_material(1).set_shader_param(
					"iris_texture", eye_set.iris)
		
	if "skin_texture" in outfit:
		skin_material.set_shader_param("main_texture", outfit.skin_texture)
	if "skin_color" in outfit:
		skin_material.set_shader_param("albedo", outfit.skin_color)
	
	for mesh in outfit:
		if mesh in special_items:
			continue

		if outfit[mesh] and !defaults_only:
			nodes[mesh].mesh = outfit[mesh]
		else:
			nodes[mesh].mesh = defaults[mesh]
	
	# Notes on materials
	# Head: surface 0 is skin, surface 1 is eyes, surface 2 is mouth
	# Other things: surface 0 is the clothing, surface 1 is skin
	for n in nodes:
		var m := nodes[n] as MeshInstance
		if !m:
			continue
		if n == "head":
			m.set_surface_material(0, skin_material)
		elif m.get_surface_material_count() > 1:
			m.set_surface_material(1, skin_material)
	nodes.pants.skin = nodes.fullbody.skin
	nodes.shirt.skin = nodes.fullbody.skin
	

func set_blink_frame(frame: int):
	blink_frame = frame
	if frame >= eye_set.sprites.size():
		frame = 0
	var m := nodes["head"] as MeshInstance
	if m:
		print("Blink: ", frame)
		m.get_surface_material(1).set_shader_param(
			"main_texture", eye_set.sprites[frame])
	else:
		print_debug("No head mesh!")
