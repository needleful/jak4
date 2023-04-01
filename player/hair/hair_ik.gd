extends Spatial

export(NodePath) var skeleton_node : NodePath

onready var skeleton := get_node(skeleton_node)

func _ready():
	if !Global.get_player():
		return
	for c in skeleton.get_children():
		if c is SkeletonIK:
			c.start()
