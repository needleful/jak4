class_name Util

static func clear(parent: Node):
	for c in parent.get_children():
		c.queue_free()

static func multiline_button(text: String, font_override : Font = null) -> Button:
	var b := Button.new()
	b.clip_text = false
	var l := RichTextLabel.new()
	b.add_child(l)
	l.bbcode_enabled = true
	l.fit_to_content = true
	l.anchor_left = 0
	l.anchor_right = 1
	l.anchor_top = 0
	l.anchor_bottom = 1
	l.margin_left = 10
	l.margin_right = -10
	l.margin_top = 5
	l.margin_bottom = -5
	l.bbcode_text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font_override:
		l.add_font_override("font", font_override)
	return b

static func resize_buttons(buttons: Array):
	for b in buttons:
		var l: RichTextLabel = b.get_child(0)
		if l:
			b.rect_min_size.y = l.get_content_height() + l.margin_top*2

static func calculate_bounds(node: Spatial, top_level := true, max_depth := 6) -> AABB:
	var box: AABB = AABB()
	if node is VisualInstance:
		box = node.get_aabb()
	if max_depth > 0:
		for c in node.get_children():
			if c is Spatial:
				var child_bounds := calculate_bounds(c, false, max_depth - 1) 
				box = box.merge(child_bounds)
	if !top_level:
		box = node.transform.xform(box)
	return box
