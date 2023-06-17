class_name Util

static func clear(parent: Node):
	for c in parent.get_children():
		c.queue_free()

static func multiline_button(text: String, font_override : Font = null) -> Button:
	var b := Button.new()
	b.clip_text = false
	var l := Label.new()
	b.add_child(l)
	l.anchor_left = 0
	l.anchor_right = 1
	l.anchor_top = 0
	l.anchor_bottom = 1
	l.margin_left = 10
	l.margin_right = -10
	l.margin_top = 5
	l.margin_bottom = -5
	l.autowrap = true
	l.text = text
	if font_override:
		l.add_font_override("font", font_override)
	return b

static func resize_buttons(buttons: Array):
	for b in buttons:
		var l: Label = b.get_child(0)
		b.rect_min_size.y = l.get_line_count()*l.get_line_height()*1.25 + l.margin_top + l.margin_bottom
