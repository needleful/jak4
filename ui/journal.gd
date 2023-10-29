extends Control

signal note_chosen(tags)
signal note_hovered(button, tags)
signal cancelled(passthrough)

export(StyleBox) var hrule_style
export(bool) var buttons := false

onready var list:Container = $hbox/sidebar/items.container
onready var subject_name := $hbox/notes/text/name
onready var subject_image := $hbox/notes/sidebar/picture
onready var subject_notes:Container = $hbox/notes/text/scroll.container
onready var subject_headline := $hbox/notes/text
onready var notes := $hbox/notes
onready var sort_label := $hbox/notes/sidebar/sort/label

const image_path := "res://ui/notes/%s/%s.png"
var show_background := true

var starting_item : Node
var temp_notes: Array

var selected_subject: Control

enum NoteType {
	People,
	Places,
	ActiveTasks,
	CompletedTasks
}

enum Sort {
	Subject,
	Recency,
	Chronological
}
var sort = Sort.Subject

func _init():
	temp_notes = []

func _ready():
	$close.visible = buttons
	set_process_input(false)

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_active(is_visible_in_tree())

func _input(event):
	if buttons and event.is_action_pressed("ui_cancel"):
		if selected_subject:
			release_subject(selected_subject)
		else:
			emit_signal("cancelled", false)
	elif buttons and event.is_action_pressed("dialog_item"):
		emit_signal("cancelled", true)
	elif event.is_action_pressed("ui_sort"):
		sort += 1
		sort = sort % Sort.size()
		set_sort(sort)
		call_deferred("draw_list")

func set_active(active):
	set_process_input(active)
	if active:
		set_sort(sort)
		draw_list()
	else:
		Util.clear(list)
		Util.clear(subject_notes)
		set_sort(Sort.Subject)

func draw_list():
	starting_item = null
	selected_subject = null
	Util.clear(list)
	if sort == Sort.Subject:
		populate_list(NoteType.People)
		populate_list(NoteType.Places)
		populate_list(NoteType.ActiveTasks)
		populate_list(NoteType.CompletedTasks)
	else:
		var n := Global.game_state.journal.duplicate()
		if sort == Sort.Recency:
			n.invert()
		write_notes(n)
	focus_first_button()

func set_sort(new_sort):
	sort = new_sort
	sort_label.text = "Sorting by: " + Sort.keys()[sort]
	match sort:
		Sort.Subject:
			$hbox/sidebar.show()
			$hbox/spacer.show()
			subject_image.show()
		Sort.Recency:
			$hbox/spacer.hide()
			$hbox/sidebar.hide()
			subject_image.hide()
			subject_name.text = "All Notes"

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
				ids = s.duplicate()
		NoteType.Places:
			category = "places"
			var s = Global.stat(category)
			if s:
				ids = s.duplicate()
		NoteType.ActiveTasks:
			category = "tasks"
			ids = Global.game_state.active_tasks.duplicate()
		NoteType.CompletedTasks:
			category = "completed"
			ids = Global.game_state.completed_tasks.duplicate()
	for tag in ids.duplicate():
		if Global.get_notes_by_tag(tag).empty():
			ids.erase(tag)
	if ids.empty():
		return
	var label := Label.new()
	label.text = category.capitalize()
	list.add_child(label)
	var previous_button : Button
	for key in ids:
		if key == "":
			print_debug("WARNING: empty key in ", category)
			continue
		var button := Button.new()
		button.text = key.capitalize()
		list.add_child(button)
		if !starting_item:
			starting_item = button
		
		var _x = button.connect("focus_entered", self, "_on_subject_focused", [type, key])
		if buttons:
			_x = button.connect("pressed", self, "_on_subject_pressed", [button])
		if previous_button:
			previous_button.focus_next = button.get_path()
			button.focus_previous = previous_button.get_path()
			previous_button.focus_neighbour_bottom = button.get_path()
			button.focus_neighbour_top = previous_button.get_path()
		previous_button = button
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
	
	write_notes(n)

func write_notes(n: Array):
	Util.clear(subject_notes)
	if buttons:
		for note_pair in n:
			var note_text:String = note_pair[0]
			if sort != Sort.Subject:
				note_text += '\n\t[i]%s[/i]' % _tag_list(note_pair[1])
			var b := Util.multiline_button(note_text)
			if !starting_item:
				starting_item = b
			var _x = b.connect("pressed", self, "emit_signal", ["note_chosen", note_pair[1]], CONNECT_ONESHOT)
			if sort == Sort.Subject:
				b.focus_mode = FOCUS_CLICK
			subject_notes.add_child(b)
		call_deferred("_resize_note_buttons")
	else:
		for note_pair in n:
			var l := Label.new()
			l.autowrap = true
			l.text = note_pair[0]
			l.size_flags_horizontal = SIZE_EXPAND_FILL
			if sort != Sort.Subject:
				var v:= VBoxContainer.new()
				v.size_flags_horizontal = SIZE_EXPAND_FILL
				v.add_constant_override("separation", 0)
				
				var tag_list := Label.new()
				tag_list.autowrap = true
				var tc := get_color("font_color", "Label")
				if "abolished" in note_pair[1]:
					var lc := tc
					lc.a = 0.4
					l.add_color_override("font_color", lc)
					tc.a = 0.4
				else:
					tc.a = 0.75
				tag_list.add_color_override("font_color", tc)
				tag_list.text = _tag_list(note_pair[1])
				
				var m := MarginContainer.new()
				m.add_child(tag_list)
				m.add_constant_override("margin_left", 80)
				
				v.add_child(l)
				v.add_child(m)
				subject_notes.add_child(v)
			else:
				subject_notes.add_child(l)

func _tag_list(t_list: Array) -> String:
	var s := "tags: "
	var tags_added := 0
	for tag in t_list:
		if tag == "abolished":
			continue
		if Global.has_stat(tag):
			continue
		var t:String = tag.capitalize()
		if tags_added > 0:
			s += ", " + t
		else:
			s += " " + t
		tags_added += 1
	return s

func _on_subject_pressed(subject:Button):
	if subject_notes.get_child_count() == 0:
		return
	selected_subject = subject
	for c in list.get_children():
		c.focus_mode = FOCUS_CLICK
	for c in subject_notes.get_children():
		c.focus_mode = FOCUS_ALL
	subject_notes.get_child(0).grab_focus()

func release_subject(subject:Button):
	selected_subject = null
	for c in list.get_children():
		if c is Button:
			c.focus_mode = FOCUS_ALL
	for c in subject_notes.get_children():
		c.focus_mode = FOCUS_CLICK
	subject.grab_focus()

func _resize_note_buttons():
	Util.resize_buttons(subject_notes.get_children())
	yield(get_tree(), "idle_frame")
	Util.resize_buttons(subject_notes.get_children())

func focus_first_button():
	if starting_item:
		starting_item.grab_focus()

func _on_close_pressed():
	emit_signal("cancelled", false)
