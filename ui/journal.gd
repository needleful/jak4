extends Control

export(StyleBox) var hrule_style

onready var list := $panel/hbox/items/list
onready var subject_name := $panel/hbox/notes/header/text/name
onready var subject_image := $panel/hbox/notes/header/TextureRect
onready var subject_notes := $panel/hbox/notes/notes/list
onready var notes := $panel/hbox/notes

const image_path := "res://ui/notes/%s/%s.png"

var starting_item : Node

func set_active(active):
	if active:
		notes.hide()
		starting_item = null
		clear(list)
		populate_list("tasks")
		populate_list("people")
		populate_list("places")
		populate_list("completed")
		if starting_item:
			call_deferred("show_notes")

func clear(node: Node):
	for c in node.get_children():
		c.queue_free()

func get_image(category: String, subject: String) -> Texture:
	var path: String = image_path % [category, subject]
	if ResourceLoader.exists(path):
		var r = ResourceLoader.load(path) as Texture
		if r:
			return r
	
	var default_path: String= image_path % [category, "default"]
	if ResourceLoader.exists(default_path):
		var r = ResourceLoader.load(default_path) as Texture
		if r:
			return r
	print_debug("No default image for notes category: ", category)
	return null
	
func populate_list(category: String):
	var items: Dictionary = Global.get_notes(category)
	if !items or items.empty():
		return
	
	var label := Label.new()
	label.text = category.capitalize()
	list.add_child(label)
	
	for key in items.keys():
		var subject = items[key]
		if !(subject is Array):
			print_debug("Bad subject %s in %s: %s" % [key, category, subject])
			continue
		var button := Button.new()
		button.text = key.capitalize()
		list.add_child(button)
		if !starting_item:
			starting_item = button
		
		var _x = button.connect("focus_entered", self, "_on_subject_focused", [category, key])
	
	var panel := Panel.new()
	panel.rect_min_size.y = 20
	panel.add_stylebox_override("panel", hrule_style)

func _on_subject_focused(category: String, subject: String):
	subject_name.text = subject.capitalize()
	subject_image.texture = get_image(category, subject)
	
	clear(subject_notes)
	
	for note in Global.get_notes(category, subject):
		var l := Label.new()
		l.autowrap = true
		l.text = note
		l.size_flags_horizontal = SIZE_EXPAND_FILL
		subject_notes.add_child(l)

func show_notes():
	notes.show()
	if starting_item:
		starting_item.grab_focus()
