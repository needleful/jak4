extends ScrollContainer

func add_child(node: Node, unique_name:=false):
	.add_child(node, unique_name)
	if node is Control:
		var _x = node.connect("focus_entered", self, "_on_child_focused", [node])

func remove_child(node:Node):
	.remove_child(node)
	if node.is_connected("focus_entered", self, "_on_child_focused"):
		node.disconnect("focus_entered", self, "_on_child_focused")

func _on_child_focused(child:Control):
	scroll_vertical = child.rect_position.y
