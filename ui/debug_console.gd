extends Control

onready var line_edit := $ScrollContainer/VBoxContainer/LineEdit
onready var logs := $ScrollContainer/VBoxContainer/logs

func set_active(a: bool):
	if a:
		line_edit.call_deferred("grab_focus")
		line_edit.text = ""

func _on_text_entered(new_text):
	line_edit.text = ""
	var ex = Expression.new()
	var label := Label.new()
	label.autowrap = true
	logs.add_child(label)
	var res = ex.parse(new_text, ["Global"])
	if res != OK:
		label.text = ex.get_error_text()
	
	var output = ex.execute([Global], self)
	if ex.has_execute_failed():
		label.text = ex.get_error_text()
	else:
		label.text = str(output)

func clear():
	for l in logs.get_children():
		l.queue_free()
