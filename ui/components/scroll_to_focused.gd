extends ScrollContainer

export(NodePath) var container_path
export(bool) var accept_input := false
onready var container := get_node(container_path) as Container
var active_tween : SceneTreeTween
var scroll_speed := 1200.0

func _ready():
	if !container:
		print_debug("Node must have a linked container! ", get_path())
		return

	var _x = container.connect("child_entered_tree", self, "_on_child_added")
	_x = container.connect("child_exiting_tree", self, "_on_child_removed")
	set_process(false)

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(accept_input and is_visible_in_tree())

func _process(delta):
	scroll_vertical += int(Input.get_axis("ui_scroll_up", "ui_scroll_down")*delta*scroll_speed)

func _on_child_added(node: Node):
	if node is Control:
		var _x = node.connect("focus_entered", self, "_on_child_focused", [node])

func _on_child_removed(node:Node):
	if node.is_connected("focus_entered", self, "_on_child_focused"):
		node.disconnect("focus_entered", self, "_on_child_focused")

func _on_child_focused(child:Control):
	scroll_to_child(child)

func scroll_to_end():
	tween_to(int(get_v_scrollbar().max_value))

func scroll_to_child(child:Control):
	var bottom := (child.rect_global_position.y + child.rect_size.y) - rect_global_position.y
	if bottom > rect_size.y:
		tween_to(scroll_vertical + int((bottom - rect_size.y) * 2))
		return
	var top := child.rect_global_position.y - rect_global_position.y
	if top < 0:
		tween_to(scroll_vertical + int(top * 2))
		return

func tween_to(tscroll: int):
	if active_tween and active_tween.is_running():
		active_tween.kill()
	active_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	var _x = active_tween.tween_property(self, "scroll_vertical", tscroll, 0.4)
