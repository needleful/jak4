tool
extends Skeleton

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
	"hair":null
}

export(Array, Texture) var eye_textures

var defaults: Dictionary
var nodes : Dictionary

func _ready():
	for slot in slots:
		nodes[slot] = get_node(slots[slot])
		if slot == "hair":
			defaults[slot] = nodes[slot].get_child(0)
		else:
			defaults[slot] = nodes[slot].mesh

func refresh():
	if outfit.hat:
		nodes.hair.hide()
		nodes.hat.show()
	else:
		nodes.hat.hide()
		nodes.hair.show()

	if (!outfit.pants and !outfit.shirt):
		nodes.pants.hide()
		nodes.shirt.hide()
		nodes.full_body.show()
	else:
		nodes.pants.show()
		nodes.shirt.show()
		nodes.full_body.hide()
	
	for mesh in outfit:
		if mesh == "hair":
			var o: Node = outfit[mesh]
			if !o:
				o = defaults[mesh]
			var n: Node = nodes[mesh]
			if o and !o.is_inside_tree():
				Util.clear(n)
				n.add_child(o)
			continue

		if outfit[mesh]:
			nodes[mesh].mesh = outfit[mesh]
		else:
			nodes[mesh].mesh = defaults[mesh]
