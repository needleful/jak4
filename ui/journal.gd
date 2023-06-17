extends Control

signal note_chosen(tags)

export(StyleBox) var hrule_style
export(bool) var buttons := false

onready var list := $panel/hbox/items/list
onready var subject_name := $panel/hbox/notes/header/text/name
onready var subject_image := $panel/hbox/notes/header/TextureRect
onready var subject_notes := $panel/hbox/notes/header/text/scroll/notes
onready var subject_headline := $panel/hbox/notes/header/text
onready var notes := $panel/hbox/notes

const image_path := "res://ui/notes/%s/%s.png"
var show_background := true

var starting_item : Node
var temp_notes: Array

enum NoteType {
	People,
	Places,
	ActiveTasks,
	CompletedTasks
}

func _init():
	temp_notes = []

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_active(is_visible_in_tree())

func set_active(active):
	if active:
		notes.hide()
		starting_item = null
		clear(list)
		populate_list(NoteType.People)
		populate_list(NoteType.Places)
		populate_list(NoteType.ActiveTasks)
		populate_list(NoteType.CompletedTasks)
		if starting_item:
			call_deferred("show_notes")

func get_image(category: String, subject: String) -> Texture:
	# Competed tasks have the same image as active
	if category == "completed":
		category = "tasks"
	var path: String = (image_path % [category, subject]).to_lower()
	if ResourceLoader.exists(path):
		var r = ResourceLoader.load(path) as Texture
		if r:
			return r
	return null
	
func populate_list(type: int):
	var category := ""
	var ids := []
	match type:
		NoteType.People:
			category = "people"
			var s = Global.stat(category)
			if s:
				ids = s
		NoteType.Places:
			category = "places"
			var s = Global.stat(category)
			if s:
				ids = s
		NoteType.ActiveTasks:
			category = "tasks"
			ids = Global.game_state.active_tasks
		NoteType.CompletedTasks:
			category = "completed"
			ids = Global.game_state.completed_tasks
	if ids.empty():
		return
	
	var label := Label.new()
	label.text = category.capitalize()
	list.add_child(label)
	
	for key in ids:
		if key == "":
			print("WARNING: empty key in ", category)
			continue
		var button := Button.new()
		button.text = key.capitalize()
		list.add_child(button)
		if !starting_item:
			starting_item = button
		
		var _x = button.connect("focus_entered", self, "_on_subject_focused", [type, key])
		if buttons:
			_x = button.connect("pressed", self, "_on_subject_pressed")
	var panel := Panel.new()
	panel.rect_min_size.y = 20
	panel.add_stylebox_override("panel", hrule_style)
	list.add_child(panel)

func _on_subject_focused(type: int, subject: String):
	var category := ""
	var n : Array = Global.get_notes_by_tag(subject, type == NoteType.CompletedTasks)
	match type:
		NoteType.People:
			category = "people"
		NoteType.Places:
			category = "places"
		NoteType.ActiveTasks:
			category = "tasks"
		NoteType.CompletedTasks:
			category = "tasks"
	subject_name.text = subject.capitalize()
	subject_image.texture = get_image(category, subject)
	
	clear(subject_notes)
	if buttons:
		for note_pair in n:
			var b := Util.multiline_button(note_pair[0])
			var _x = b.connect("pressed", self, "emit_signal", ["note_chosen", note_pair[1]], CONNECT_ONESHOT)
			subject_notes.add_child(b)
		call_deferred("_resize_note_buttons")
	else:
		for note_pair in n:
			var l := Label.new()
			l.autowrap = true
			l.text = note_pair[0]
			l.size_flags_horizontal = SIZE_EXPAND_FILL
			subject_notes.add_child(l)

func _on_subject_pressed():
	subject_notes.get_child(0).grab_focus()

func _resize_note_buttons():
	Util.resize_buttons(subject_notes.get_children()) 

func show_notes():
	notes.show()
	if starting_item:
		starting_item.grab_focus()

func clear(node: Node):
	for c in node.get_children():
		c.queue_free()
