extends Control

signal exited

var main_speaker: Node
var source_node: Node
var last_speaker: String

var current_item : DialogItem
var sequence: Resource

var otherwise := false
var talked := 0
var skip_reply := false
var discussed := {}
var exiting := false

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
	# Result does not return true or false. Stop processing this item
	SKIP,
	# Pause() is called and processing stopped.
	# On resume(), the item is shown and dialog resumes from there
	PAUSE,
	# It's the end of the dialog
	END
}

var r_otherwise_if := RegEx.new()
var r_interpolate := RegEx.new()

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
	r_interpolate.compile("#\\{([^\\}])\\}")
	end()

func start(p_source_node: Node, p_sequence: Resource, speaker: Node = null):
	clear()
	show()
	source_node = p_source_node
	sequence = p_sequence
	if speaker:
		main_speaker = speaker
	else:
		main_speaker = source_node
	talked = Global.stat("talked"+speaker.get_path())
	set_process(true)
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
	exiting = false
	discussed = {}
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
	if !current_item:
		exit()
		return
	clear_replies()
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
			result = false
	
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
			if evaluate(c) == Result.FALSE:
				result = false
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
		last_speaker = "You"
	current_item = item
	get_next()

func show_message():
	var speaker: String = current_item.speaker	
	if speaker == "":
		speaker = main_speaker.name.capitalize()

	var text := ""
	if speaker != last_speaker:
		text = "%s: %s" % [speaker, current_item.text]
	else:
		text = current_item.text
	last_speaker = speaker
	
	if speaker == "You":
		insert_label(text, player_font, player_color)
	else:
		insert_label(text, speaker_font, speaker_color)

func show_narration():
	insert_label(current_item.text, narration_font, narration_color)

func insert_label(text: String, font: Font, color: Color):
	var label := Label.new()
	label.autowrap = true
	label.text = interpolate(text)
	label.add_font_override("font", font)
	label.add_color_override("font_color", color)
	messages.add_child(label)

func interpolate(line: String):
	var matches := r_interpolate.search_all(line)
	var text := line
	for m in matches:
		var ex = eval_expression(m.get_string(1))
		text = text.replace(m.get_string(), str(ex))
	return text

func eval_expression(ex_text: String):
	var expr: Expression = Expression.new()
	var err = expr.parse(ex_text, ["Global"])
	if err != OK:
		print_debug("\tFailed to parse {%s}. Code %d" % [ex_text, err])
		return Result.IGNORE
	
	var r = expr.execute([Global], self)
	
	if expr.has_execute_failed():
		print_debug("\tFailed to execute {%s}.\n\t%s" 
			% [ex_text, expr.get_error_text()])
		return Result.IGNORE
	return r

func evaluate(cond: String):
	var oim: RegExMatch = r_otherwise_if.search(cond)
	if oim:
		if !otherwise:
			return Result.FALSE
		cond = cond.replace(oim.get_string(), "")
	
	var r = eval_expression(cond)
	
	var result: int
	if r is int:
		result = r
	elif r:
		result = Result.TRUE
	else:
		result = Result.FALSE
	
	otherwise = result == Result.FALSE
	return result

# TODO
func format(_style: String):
	return Result.TRUE

# TODO
func animation(_anim: String):
	return Result.TRUE

# TODO
func event(_tag: String, should_pause := true):
	if should_pause:
		pause()
	return Result.TRUE

func goto(label: String):
	current_item = sequence.get(label)
	return Result.SKIP

func skip():
	skip_reply = true
	return Result.TRUE

func exit():
	Global.add_stat("talked"+main_speaker.get_path())
	emit_signal("exited")
	return Result.END

func mention(topic):
	discussed[topic] = true
	return Result.IGNORE

func mentioned(topic):
	if topic in discussed:
		return Result.TRUE
	else:
		return Result.FALSE

#TODO
func subtopic(_label):
	return Result.IGNORE

#TODO
func back():
	return Result.IGNORE

func end():
	hide()
	set_process(false)
	set_process_input(false)
	Global.can_pause = true

func fast_exit():
	if exiting:
		get_next()
	else:
		exiting = true
		current_item = sequence.get("_exit")
		advance()

func pause():
	hide()
	set_process_input(false)
	set_process(false)

func resume():
	show()
	set_process_input(true)
	set_process(true)
