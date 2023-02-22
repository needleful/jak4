extends Spatial

export(NodePath) var skeleton_node : NodePath

onready var skeleton := get_node(skeleton_node)

func _ready():
	for c in skeleton.get_children():
		if c is SkeletonIK:
			c.start()
