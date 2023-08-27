extends Skeleton

# A dictionary of names to mesh instances
export(Dictionary) var slots := {
	"full_body" : NodePath("fullbody"),
	"hair": NodePath("hat"),
	"shirt": NodePath("shirt"),
	"pants": NodePath("pants"),
	"head":NodePath("head"),
	"eyebrows":NodePath("eyebrows")
}

# A dictionary of slots to meshes?
export(Dictionary) var outfit := {
	"full_body": null,
	"hair":null,
	"pants":null,
	"shirt":null,
	"head":null,
	"eyebrows":null
}

export(Array, Texture) var eye_textures

var defaults: Dictionary
var nodes : Dictionary

func _ready():
	for slot in slots:
		nodes[slot] = get_node(slots[slot])
		defaults[slot] = nodes[slot].mesh

func refresh():
	if (!outfit.pants and !outfit.shirt):
		nodes.pants.hide()
		nodes.shirt.hide()
		nodes.full_body.show()
	else:
		nodes.pants.show()
		nodes.shirt.show()
		nodes.full_body.hide()
	
	for mesh in outfit:
		if outfit[mesh]:
			nodes[mesh].mesh = outfit[mesh]
		else:
			nodes[mesh].mesh = defaults[mesh]
