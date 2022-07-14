extends Control

onready var viewport := $Viewport
onready var view_window := $viewport_window
onready var object_ref := $Viewport/object_ref

func _process(delta):
	var cam := Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
	object_ref.global_rotate(Vector3.UP, cam.x*delta)
	object_ref.global_rotate(Vector3.RIGHT, -cam.y*delta)

func set_active(active):
	if active:
		viewport.size = view_window.rect_size
	set_process(active)
