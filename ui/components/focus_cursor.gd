extends Control

var tracked_item : Control
const padding = Vector2(6,6)
onready var tween: SceneTreeTween
var target_position := Vector2()
var target_size := Vector2()

func _ready():
	var _x = get_viewport().connect("gui_focus_changed", self, "track_item", [], CONNECT_DEFERRED)

func _process(_delta):
	if !is_instance_valid(tracked_item) or !tracked_item:
		hide()
		set_process(false)
		tracked_item = null
		return
	visible = tracked_item.is_inside_tree() and tracked_item.is_visible_in_tree()
	if visible and tracked_item.rect_global_position != target_position or tracked_item.rect_size != target_size:
		if tween:
			tween.kill()
		tween = create_tween().set_trans(
			Tween.TRANS_EXPO).set_ease(
			Tween.EASE_IN_OUT).set_parallel(true)
		target_position = tracked_item.rect_global_position
		target_size = tracked_item.rect_size
		var _x = tween.tween_property(self, "rect_global_position", target_position - padding, 0.15)
		_x = tween.tween_property(self, "rect_size", tracked_item.rect_size + padding*2, 0.15)

func track_item(item: Control):
	if !item:
		hide()
		return
	if tracked_item:
		remove_item()
	tracked_item = item
	set_process(true)
	
	var _x = tracked_item.connect("focus_exited", self, "remove_item")
	_x = tracked_item.connect("tree_exiting", self, "remove_item")
	show()

func remove_item():
	if is_instance_valid(tracked_item):
		tracked_item.disconnect("focus_exited", self, "remove_item")
		tracked_item.disconnect("tree_exiting", self, "remove_item")
	tracked_item = null
	hide()
