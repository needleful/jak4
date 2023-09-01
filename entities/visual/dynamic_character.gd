tool
extends Spatial

# A dictionary of names to mesh instances
export(Dictionary) var slots := {
	"full_body" : NodePath("fullbody"),
	"hat": NodePath("hat"),
	"shirt": NodePath("shirt"),
	"pants": NodePath("pants"),
	"head":NodePath("head"),
	"eyebrows":NodePath("eyebrows"),
	"hair":NodePath("head_attach/hair")
}

# A dictionary of slots to meshes?
export(Dictionary) var outfit := {
	"full_body": null,
	"hat":null,
	"pants":null,
	"shirt":null,
	"head":null,
	"eyebrows":null,
	"hair":null,
	"eyes":null
}
export(Dictionary) var defaults: Dictionary

export(Resource) var eye_set
export(int) var blink_frame: int setget set_blink_frame
export(bool) var defaults_only := false

var nodes : Dictionary

func _ready():
	for slot in slots:
		nodes[slot] = get_node(slots[slot])

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
		nodes.full_body.show()
	else:
		nodes.pants.show()
		nodes.shirt.show()
		nodes.full_body.hide()
	
	for mesh in outfit:
		if mesh == "hair":
			var o: PackedScene = outfit[mesh]
			if !o or defaults_only:
				o = defaults[mesh]
			if o:
				var n: Node = nodes[mesh]
				Util.clear(n)
				n.add_child(o.instance())
			continue
		
		if mesh == "eyes":
			var e:EyeSet = outfit[mesh]
			if !e or defaults_only:
				e = defaults[mesh]
			if e:
				eye_set = e
				set_blink_frame(0)
				var m = nodes["head"] as MeshInstance
				if m:
					m.get_surface_material(1).set_shader_param(
						"iris_texture", eye_set.iris)
			continue

		if outfit[mesh] and !defaults_only:
			nodes[mesh].mesh = outfit[mesh]
		else:
			nodes[mesh].mesh = defaults[mesh]

func set_blink_frame(frame: int):
	blink_frame = frame
	if frame >= eye_set.sprites.size():
		frame = 0
	var m := nodes["head"] as MeshInstance
	if m:
		m.get_surface_material(1).set_shader_param(
			"main_texture", eye_set.sprites[frame])
