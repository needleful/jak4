extends Control

onready var viewport := $Viewport
onready var object_ref := $Viewport/object_ref
onready var ref_cam_arm := $Viewport/SpringArm

onready var view_window := $box/viewport_window
onready var item_name := $box/viewport_window/Panel/MarginContainer/item/name
onready var item_desc := $box/viewport_window/Panel/MarginContainer/item/description
onready var sub_items := $box/viewport_window/Panel/MarginContainer/item/sub_items

onready var item_viewer := $box/items/item_list
var show_background := true

export(Resource) var player_description

const MIN_ZOOM := 0.1
const MAX_ZOOM := 10.0
const ZOOM_SPEED := 3.0

var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT):
		mouse_accum += event.relative

func _ready():
	set_active(false)

func _process(delta):
	var cam := Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
	mouse_accum.y *= -1
	cam += mouse_accum*mouse_sns
	var player = Global.get_player()
	if player:
		if player.invert_x:
			cam.x *= -1
		if player.invert_y:
			cam.y *= -1
	mouse_accum = Vector2.ZERO
	
	object_ref.global_rotate(Vector3.UP, cam.x*delta)
	object_ref.global_rotate(Vector3.RIGHT, -cam.y*delta)
	var zoom := Input.get_axis("map_zoom_in", "map_zoom_out") - Global.get_mouse_zoom_axis()
	var c_zoom: float = ref_cam_arm.spring_length
	c_zoom = clamp(
		c_zoom + delta * ZOOM_SPEED * c_zoom * zoom * 0.5,
		MIN_ZOOM, MAX_ZOOM)
	ref_cam_arm.spring_length = c_zoom

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_active(is_visible_in_tree())

func set_active(active):
	if active:
		var p = Global.get_player()
		if p:
			mouse_sns = 60*p.sensitivity*p.cam_rig.mouse_sns
		viewport.size = view_window.rect_size
		player_description.id = 'you'
		item_viewer.insert_item('you', player_description)
		item_viewer.view_items(Global.get_fancy_inventory())
	else:
		item_viewer.clear()
	set_process(active)
	set_process_input(active)

func _on_item_focused(item: ItemDescription):
	Util.clear(sub_items)
	Util.clear(object_ref)
	if item.preview_3d:
		object_ref.add_child(item.preview_3d.instance())
	else:
		pass # todo: placeholder
	item_name.text = item.full_name
	item_desc.text = item.description
	for i2 in item.extra_items.keys():
		if Global.count(i2) > 0:
			var l1 := Label.new()
			l1.text = item.extra_items[i2] + ":"
			var l2 := Label.new()
			l2.text = str(Global.count(i2))
			sub_items.add_child(l1)
			sub_items.add_child(l2)
