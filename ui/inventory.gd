extends Control

onready var viewport := $Viewport
onready var view_window := $viewport_window
onready var object_ref := $Viewport/object_ref
onready var ref_cam_arm := $Viewport/SpringArm

onready var items_list := $large_items/ScrollContainer/rows
onready var item_name := $viewport_window/Panel/MarginContainer/item/name
onready var item_desc := $viewport_window/Panel/MarginContainer/item/description
onready var sub_items := $viewport_window/Panel/MarginContainer/item/sub_items

export(Resource) var player_description

var preview_path := "res://ui/items/%s.tres"

const MIN_ZOOM := 0.1
const MAX_ZOOM := 10.0
const ZOOM_SPEED := 3.0

func _process(delta):
	var cam := Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
	object_ref.global_rotate(Vector3.UP, cam.x*delta)
	object_ref.global_rotate(Vector3.RIGHT, -cam.y*delta)
	var zoom := Input.get_axis("map_zoom_in", "map_zoom_out")
	var c_zoom: float = ref_cam_arm.spring_length
	c_zoom = clamp(
		c_zoom + delta * ZOOM_SPEED * c_zoom * zoom * 0.5,
		MIN_ZOOM, MAX_ZOOM)
	ref_cam_arm.spring_length = c_zoom

func _ready():
	set_process(false)

func set_active(active):
	if active:
		viewport.size = view_window.rect_size
		clear(items_list)
		var items := {}
		for c in Global.game_state.inventory.keys():
			var path: String = preview_path % c
			if Global.count(c) > 0 and ResourceLoader.exists(path):
				var r := ResourceLoader.load(path) as ItemDescription
				if !r:
					print_debug("Invalid item: ", path)
				else:
					items[c] = r
		view_items(items)
	set_process(active)

func view_items(items: Dictionary):
	var button = Button.new()
	button.rect_min_size = Vector2(100, 100)
	button.icon_align = HALIGN_CENTER
	
	var row := HBoxContainer.new()
	
	var spacer_width := 15
	var max_width:int = items_list.rect_size.x
	var button_count := 0
	var working_width := 0
	while working_width - spacer_width < max_width:
		button_count += 1
		working_width += button.rect_min_size.x + spacer_width
	var remainder:float = max_width - working_width
	spacer_width += int(remainder/(button_count - 1))
	row.add_constant_override("separation", spacer_width)
	
	
	var working_row: HBoxContainer = row.duplicate()
	
	var player_button: Button = button.duplicate()
	player_button.icon = player_description.icon
	var _y = player_button.connect("focus_entered", self, "_on_item_focused", [player_description])
	working_row.add_child(player_button)
	
	var in_row := 1
	for k in items.keys():
		var item: ItemDescription = items[k]
		var b: Button = button.duplicate()
		b.icon = item.icon
		var _x = b.connect("focus_entered", self, "_on_item_focused", [item])
		working_row.add_child(b)
		in_row += 1
		if in_row >= button_count:
			items_list.add_child(working_row)
			working_row = row.duplicate()
	if working_row and working_row.get_child_count() > 0:
		items_list.add_child(working_row)
	player_button.call_deferred("grab_focus")

func _on_item_focused(item: ItemDescription):
	clear(sub_items)
	clear(object_ref)
	object_ref.add_child(item.preview_3d.instance())
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

func clear(node: Node):
	for c in node.get_children():
		c.queue_free()
