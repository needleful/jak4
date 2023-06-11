class_name Util

static func clear(parent: Node):
	for c in parent.get_children():
		c.queue_free()
