extends Control

signal exited

var main_speaker: Node
var source_node: Node

var current_item : DialogItem
var sequence: Resource

var otherwise := false
var talked := 0
var skip_reply := false

export(Font) var speaker_font
export(Font) var narration_font
export(Font) var player_font

export(Color) var speaker_color := Color.whitesmoke
export(Color) var narration_color := Color.dimgray
export(Color) var player_color := Color.deeppink

onready var replies := $vbox/replies
onready var messages := $vbox/messages/list

enum Result {
	# Result failed. Skip this, set otherwise
	FALSE,
	# Result is true. Show this.
	TRUE,
	# Result does not return true or false. Show item
	IGNORE,
	# Result does not return true or false. Stop processing
	SKIP,
	# It's the end of the dialog
	END
}

var r_otherwise_if = RegEx.new()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		fast_exit()
	elif current_item.type != DialogItem.Type.REPLY and event.is_action_pressed("ui_accept"):
		get_next()

func _process(_delta):
	var scr = $vbox/messages
	scr.scroll_vertical = scr.get_v_scrollbar().max_value

func _ready():
	r_otherwise_if.compile("^\\s*otherwise\\s+if\\s+")
	end()

func start(source_node: Node, p_sequence: Resource, speaker: Node):
	sequence = p_sequence
	main_speaker = speaker
	set_process(true)
	clear()
	if !main_speaker:
		main_speaker = self
	show()
	set_process_input(true)
	Global.can_pause = false
	var first_index = INF
	# I forgot to specify a first item and I'm not going to bother lol
	for c in sequence.dialog.keys():
		if c < first_index:
			first_index = c
	current_item = sequence.get(first_index)
	advance()

func clear():
	for c in messages.get_children():
		c.queue_free()
	clear_replies()

func clear_replies():
	for c in replies.get_children():
		c.queue_free()

func get_next():
	var c = sequence.canonical_next(current_item)
	if !c:
		exit()
	else:
		current_item = c
		advance()

func advance():
	clear_replies()
	if !current_item:
		exit()
		return
	var result := false
	while !result:
		if !current_item:
			exit()
			return
		var cond: Array = current_item.conditions
		result = true
		for c in cond:
			var r = evaluate(c)
			if r == Result.FALSE:
				result = false
				break
			elif r == Result.SKIP:
				advance()
				return
			elif r == Result.END:
				return
		if !result:
			current_item = sequence.failed_next(current_item)
		elif current_item.text == "":
			current_item = sequence.canonical_next(current_item)

	match current_item.type:
		DialogItem.Type.MESSAGE:
			show_message()
		DialogItem.Type.REPLY:
			list_replies()
		DialogItem.Type.NARRATION:
			show_narration()

func list_replies():
	var reply: DialogItem = current_item
	while reply and reply.type == DialogItem.Type.REPLY:
		skip_reply = false
		var cond = reply.conditions
		var result := true
		for c in cond:
			print("> {%s}" % cond)
			if evaluate(c) == Result.FALSE:
				result = false
				print("\tFALSE")
				break
		if result:
			var b := Button.new()
			b.text = reply.text
			replies.add_child(b)
			var r = reply
			var s = skip_reply
			var _x = b.connect("pressed", self, "choose_reply", [r, s])
		reply = sequence.next(reply)
	if replies.get_child_count() == 0:
		current_item = reply
		advance()
	$reply_timer.start()

func _on_reply_timer_timeout():
	replies.get_child(0).grab_focus()

func choose_reply(item: DialogItem, skip: bool):
	if !skip:
		insert_label("You: %s" % item.text, player_font, player_color)
	current_item = item
	get_next()

func show_message():
	var speaker = current_item.speaker
	if speaker == "":
		speaker = main_speaker.name.capitalize()
	if speaker == "You":
		insert_label("%s: %s" % [speaker, current_item.text],
			player_font, player_color)
	else:
		insert_label("%s: %s" % [speaker, current_item.text],
			speaker_font, speaker_color)

func show_narration():
	insert_label(current_item.text, narration_font, narration_color)

func insert_label(text: String, font: Font, color: Color):
	var label := Label.new()
	label.autowrap = true
	label.text = text
	label.add_font_override("font", font)
	label.add_color_override("font_color", color)
	messages.add_child(label)

func evaluate(cond: String):
	var oim: RegExMatch = r_otherwise_if.search(cond)
	var otherwise_if := false
	if oim:
		cond = cond.replace(oim.get_string(), "")
		otherwise_if = true
	
	if otherwise_if and !otherwise:
		return Result.FALSE
	
	var expr: Expression = Expression.new()
	var err = expr.parse(cond, ["Global"])
	if err != OK:
		print_debug("\tFailed to parse {%s}. Code %d" % [cond, err])
		return Result.IGNORE
	
	var r = expr.execute([Global], self)
	
	if expr.has_execute_failed():
		print_debug("\tFailed to execute {%s}.\n\t%s" 
			% [cond, expr.get_error_text()])
		return Result.IGNORE
	
	var result: int
	if r is int:
		result = r
	elif r:
		result = Result.TRUE
	else:
		result = Result.FALSE
	
	if otherwise_if:
		otherwise = result == Result.TRUE
	else:
		otherwise = result != Result.TRUE
	return result

func format(style: String):
	return Result.TRUE

func animation(anim: String):
	return Result.TRUE

func event(tag: String):
	return Result.TRUE

func goto(label: String):
	current_item = sequence.get(label)
	return Result.SKIP

func skip():
	skip_reply = true
	return Result.TRUE

func exit():
	emit_signal("exited")
	return Result.END

func end():
	hide()
	set_process(false)
	set_process_input(false)
	Global.can_pause = true

func fast_exit():
	current_item = sequence.get("_exit")
	advance()
