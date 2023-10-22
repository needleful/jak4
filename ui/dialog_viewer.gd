extends Control

signal started
signal exited(state)
signal exited_anim(animation)
signal event(id)
signal event_with_source(id, source)
signal pick_item
signal control_screen(controlled)

class CallFrame:
	var item: DialogItem
	var block_name: String
	var box: Control
	func _init(p_item: DialogItem, p_box: Control, p_block_name: String):
		item = p_item
		box = p_box
		block_name = p_block_name

var shopping := false setget set_shopping
var entered_from := ""

onready var player: PlayerBody = Global.get_player()
var main_speaker: Node
var source_node: Node
var last_speaker: String

var current_item : DialogItem
var sequence: Resource

export(Dictionary) var fonts: Dictionary
export(Dictionary) var colors := {
	"narration": Color.dimgray,
	"you":Color.deeppink
}

onready var replies := $messages/replies
onready var message_container := $messages/messages
onready var messages := $messages/messages/list
onready var message_list := messages
onready var aside_template:Control = $aside_template
onready var difficulty: DifficultySettings = Settings.sub_options["Difficulty"]

const RESULT_SKIP := {"result":"skip"}
const RESULT_PAUSE := {"result":"pause"}
const RESULT_END := {"result":"end"}
const RESULT_NOSKIP := {"result":"noskip"}

var r_interpolate := RegEx.new()
var r_italics := RegEx.new()
var r_special_label := RegEx.new()

var otherwise := false
var talked := 0
var skip_reply := false
var context: Dictionary
var variables: Dictionary
var is_exiting := false
# Stack of IDs for DialogItems
var call_stack: Array
var advance_on_resume := false
var label_conditions : Dictionary
var block_names: Dictionary

const SECONDS_PER_YEAR := 356*24*3600
const SECONDS_PER_MONTH := 30*24*3600
const SECONDS_PER_DAY := 24*3600
const SECONDS_PER_HOUR := 3600
const SECONDS_PER_MINUTE := 60

const item_fallthrough := "item(_)"
# Dictionary of arrays mapping context to messages
var contextual_replies : Dictionary
var sorted_labels : Array

enum LocalBlockState {
	Invalid, # We don't meet the conditions for this label
	Optional, # This item is optional
	Quest, # This item is important
	Completed, # We've completed this before
	Visited # We've visited this block in the current dialog tree
}
var block_states : Dictionary
var block_types : Dictionary

enum BlockState {
	Unvisited,
	Visited,
	Completed
}

func _init():
	sorted_labels = []
	fonts = {}
	call_stack = []
	context = {}
	label_conditions = {}
	contextual_replies = {}
	variables = {}
	block_states = {}
	block_names = {}
	var _x = r_interpolate.compile("#\\{([^\\}]+)\\}")
	_x = r_italics.compile("/")
	_x = r_special_label.compile("@?(item|note)\\(\\s*([^)]+)\\s*\\)\\s*")

func _ready():
	ui_settings_apply()
	var _x = messages.connect("child_entered_tree", self, "_on_message_added", [], CONNECT_DEFERRED)
	_x = Global.connect("anything_changed", self, "_evaluate_labels")
	remove_child(aside_template)
	end()

func _input(event):
	if shopping:
		if event.is_action_pressed("ui_cancel"):
			set_shopping(false)
			resume()
	elif event.is_action_pressed("ui_cancel"):
		fast_exit()
	elif event.is_action_pressed("dialog_item"):
		var c = $"../buttons/trade/indicators/indicator-contextual"
		if c.visible:
			c.get_node("AnimationPlayer").play("RESET")
		emit_signal("pick_item")
		disable_replies()
	elif event.is_action_pressed("skip_to_next_choice"):
		while current_item and current_item.type != DialogItem.Type.REPLY:
			if !get_next():
				break
	elif current_item.type != DialogItem.Type.REPLY and event.is_action_pressed("ui_accept"):
		get_next()

func start(p_source_node: Node, p_sequence: Resource, speaker: Node = null, starting_label:= ""):
	emit_signal("started")
	set_shopping(false)
	clear()
	source_node = p_source_node
	sequence = p_sequence.duplicate()
	label_conditions = {}
	block_names = {}
	sorted_labels = []
	message_list = messages
	for l in sequence.labels:
		var label_ex :String = l
		var block: String = l
		if "->" in l:
			var s =  l.split('->')
			label_ex = s[0]
			block_names[l] = s[1]
			block = s[1]
		if ":-" in label_ex:
			var s = label_ex.split(":-")
			var label = s[0].strip_edges()
			var e = Expression.new()
			var res = e.parse(s[1], ["Global"])
			if res != OK:
				var msg := "Bad expression in %s:%s\n\t %s" % [
					p_sequence.resource_path, label, s[1]]
				insert_label("[Error] "+ msg, "narration")
				print_debug(msg)
			var e2 = _parse_special_label(label, block)
			if e2:
				label_conditions[l] = [e, e2]
			else:
				label_conditions[l] = e
		else:
			var e = _parse_special_label(l, block)
			if e:
				label_conditions[l] = e
	sorted_labels = sequence.labels.keys()
	sorted_labels.sort_custom(self, "_sort_labels")

	if speaker:
		main_speaker = speaker
	else:
		main_speaker = source_node
	talked = Global.stat(get_talked_stat())
	set_process_input(true)
	Global.can_pause = false
	var first_index = INF
	var s: DialogItem
	entered_from = starting_label
	if starting_label != "":
		s = sequence.find_label(starting_label)
		if !s:
			print_debug("No starting label '%s' in file: %s" % [
				starting_label, sequence.resource_path
			])
	if !s:
		for c in sequence.dialog.keys():
			if c < first_index:
				first_index = c
		current_item = sequence.find_index(first_index)
	else:
		current_item = s
	if "friendly_id" in main_speaker and main_speaker.friendly_id != "":
		Global.remember(main_speaker.friendly_id)
	_evaluate_labels()
	advance()

func _parse_special_label(label: String, block: String) -> Expression:
	var ex = Expression.new()
	var m := r_special_label.search(label)
	if !m:
		return null
	
	var type := m.get_string(1)
	var argument := m.get_string(2)
	var quest_type := label.begins_with('@')
	var ex_str := ""
	block_types[block] = type
	if type == "item":
		ex_str = "Global.count('%s')" % argument
	elif type == "note":
		ex_str = "Global.has_note('%s')" % argument
	else:
		print_debug("BUG: unknown label type: ", type)
		return null
	if quest_type:
		ex_str = "_quest(%s)" % ex_str
	var res = ex.parse(ex_str, ["Global"])
	if res != OK:
		print_debug("ERROR: bad special label: `", label, "`, converted to: ", ex_str)
		return null
	return ex

func _quest(b):
	if b and !(b is Dictionary and "_failure" in b):
		return {"_quest": b}
	else:
		return b

func clear():
	last_speaker = ""
	is_exiting = false
	context = {}
	otherwise = false
	call_stack = []
	contextual_replies = {}
	variables = {}
	block_states = {}
	Util.clear(messages)
	clear_replies()

func clear_replies():
	for c in replies.get_children():
		c.queue_free()

func _on_task_completed(_task):
	_evaluate_labels()

func _on_stat_changed(_stat, _value):
	_evaluate_labels()

func _evaluate_labels():
	if !main_speaker:
		return
	for l in sorted_labels:
		var block: String = l
		if l in block_names:
			block = block_names[l]
		var quest := false
		if l in label_conditions:
			var res = _execute_label(l)
			if !res or (res is Dictionary and "_failure" in res):
				block_states[block] = LocalBlockState.Invalid
				continue
			quest = res is Dictionary and "_quest" in res
		var old_state = LocalBlockState.Invalid
		if block in block_states:
			old_state = block_states[block]
		if old_state == LocalBlockState.Completed:
			continue
		var block_name: String = block_names[l] if l in block_names else l
		var block_stat = speaker_stat() + "/" + block_name
		if Global.stat(block_stat) >= BlockState.Completed:
			block_states[block] = LocalBlockState.Completed
		else:
			block_states[block] = LocalBlockState.Optional if !quest else LocalBlockState.Quest
		if old_state < block_states[block]:
			_notify_new_item(l, block_states[block])
	_check_notifications()

func _check_notifications():
	var notifications := {
		"item":[],
		"note":[],
		"_":[]
	}
	for block in block_states:
		if block in block_types:
			var type = block_types[block]
			var state = block_states[block]
			if !(state in notifications[type]):
				notifications[type].append(state)
			if !(state in notifications['_']):
				notifications['_'].append(state)
	for type in notifications:
		if type == '_':
			continue
		for state in LocalBlockState.values():
			if state == LocalBlockState.Visited:
				continue # Nothing to clear
			if !(state in notifications[type]):
				_clear_notifications(type, state,
					 !(state in notifications['_']))

func _notify_new_item(label: String, label_state: int):
	if difficulty.dialog_hints < DifficultySettings.DialogHints.ItemsAndNotes:
		return
	var label_type:String = label.split("(", false)[0].replace("@", "")
	var nodes := _get_notification_nodes(label_type, label_state)
	for n in nodes:
		if !n.get_parent().visible:
			n.play("indicate")

func _get_notification_nodes(type: String, state: int) -> Array:
	var base_node: Node
	match type:
		"item":
			base_node = $"../item_context/VBoxContainer/show_inventory"
		"note":
			base_node = $"../item_context/VBoxContainer/show_journal"
		_:
			return []

	var key := ""
	match state:
		LocalBlockState.Optional:
			key = "indicators/indicator-optional/AnimationPlayer"
		LocalBlockState.Quest:
			key = "indicators/indicator-quest/AnimationPlayer"
		LocalBlockState.Completed:
			key = "indicators/indicator-visited/AnimationPlayer"
		_:
			return []
	
	var indicators := $"../buttons/trade"
	var child_node : AnimationPlayer = base_node.get_node(key)
	var indicator : AnimationPlayer = indicators.get_node(key)
	return [child_node, indicator]

func _clear_notifications(type: String, state: int, clear_main: bool):
	var nodes := _get_notification_nodes(type, state)
	if nodes.empty():
		return
	nodes[0].play("RESET")
	if clear_main:
		nodes[1].play("RESET")

func _notify_contextual_reply():
	if difficulty.dialog_hints < DifficultySettings.DialogHints.OnlyReplies:
		return
	var c = $"../buttons/trade/indicators/indicator-contextual"
	if !c.visible:
		c.get_node("AnimationPlayer").play("indicate")

func _execute_label(l: String):
	var cond = label_conditions[l]
	var conds: Array
	if cond is Expression:
		conds = [cond]
	elif cond is Array:
		conds = cond
	else:
		print_debug("Invalid condition: ", cond)
	var res
	for ex in conds:
		res = ex.execute([Global], self)
		if ex.has_execute_failed():
			print_debug("Execution failed for ", l,
				"\n\t", ex.get_error_text())
			return {"_failure": ex.get_error_text()}
		if !res:
			break
	return res

func _on_message_added(child: Node):
	yield(get_tree(), "idle_frame")
	message_container.scroll_to_child(child)

func get_next():
	var c: DialogItem
	if current_item.type != DialogItem.Type.CONTEXT_REPLY:
		c = sequence.canonical_next(current_item)
	else:
		c = sequence.failed_next(current_item)
	if !c:
		exit()
		return false
	else:
		current_item = c
		var r = advance()
		return !!current_item and r != RESULT_END

func advance():
	if !current_item:
		exit()
		return
	clear_replies()
	var result := false
	var noskip := false
	var font_override := ""
	otherwise = false
	while !result:
		var otherwise_used := false
		if !current_item:
			exit()
			return
		# Conditions on replies are handled in list_replies()
		if current_item.type == DialogItem.Type.REPLY:
			result = true
			break
		result = true
		font_override = ""
		for c in current_item.conditions:
			var r = check_condition(c)
			if r is Dictionary and "_otherwise" in r:
				otherwise_used = true
				r = r["_otherwise"]
			if r is Dictionary:
				if r == RESULT_END:
					return RESULT_END
				elif r == RESULT_PAUSE:
					pause()
					return
				elif r == RESULT_SKIP:
					advance()
					return
				elif r == RESULT_NOSKIP:
					noskip = true
				elif "_format" in r:
					font_override = r._format
			elif !r:
				result = false
				break
		if !result:
			current_item = sequence.failed_next(current_item)
			if sequence.went_up:
				otherwise = false
			elif !otherwise_used:
				otherwise = true
		else:
			otherwise = false
			if current_item.type == DialogItem.Type.CONTEXT_REPLY:
				insert_contextual_reply(current_item, current_item.speaker)
				current_item = sequence.failed_next(current_item)
				result = false
			elif current_item.text == "" and !noskip:
				current_item = sequence.canonical_next(current_item)
				result = false
	
	if current_item.text != "":
		match current_item.type:
			DialogItem.Type.MESSAGE:
				show_message(current_item.text, current_item.speaker, font_override)
			DialogItem.Type.REPLY:
				list_replies()
			DialogItem.Type.NARRATION:
				show_narration(font_override)
			_:
				insert_label("[Error: Unknown message type: %s] %s" % [
					DialogItem.Type.keys()[current_item.type], current_item.text
				], "narration", "", false)
	if !current_item:
		return
	var context_reply:DialogItem = sequence.canonical_next(current_item)
	otherwise = false
	while context_reply and context_reply.type == DialogItem.Type.CONTEXT_REPLY:
		var otherwise_used := false
		current_item = context_reply
		result = true
		for c in context_reply.conditions:
			var r = check_condition(c)
			if r is Dictionary and "_otherwise" in r:
				r = r["_otherwise"]
				otherwise_used = true
			if !r:
				result = false
				break
		if result:
			otherwise = false
			insert_contextual_reply(context_reply, context_reply.speaker)
		elif !otherwise_used:
			otherwise = true
		context_reply = sequence.failed_next(context_reply)

func list_replies():
	var reply: DialogItem = current_item
	otherwise = false
	while reply and reply.type == DialogItem.Type.REPLY:
		var font_override := ""
		skip_reply = false
		var cond = reply.conditions
		var result := true
		var otherwise_used := false
		for c in cond:
			var r = check_condition(c)
			if r is Dictionary and "_otherwise" in r:
				r = r["_otherwise"]
				otherwise_used = true
			if !r:
				result = false
				break
			elif r is Dictionary and "_format" in r:
				font_override = r._format
		if result:
			otherwise = false
			var f: Font
			if font_override in fonts:
				f = fonts[font_override]
			var b := Util.multiline_button(interpolate(reply.text), f)
			replies.add_child(b)
			var r = reply
			var s = skip_reply
			var _x = b.connect("pressed", self, "choose_reply", [r, s])
		elif !otherwise_used:
			otherwise = true
		reply = sequence.next(reply)
	if replies.get_child_count() == 0:
		print_debug("\tNo replies.")
		current_item = reply
		advance()
	else:
		call_deferred("_resize_replies")
	$input_timer.start()

func _resize_replies():
	Util.resize_buttons(replies.get_children())
	yield(get_tree(), "idle_frame")
	Util.resize_buttons(replies.get_children())
	message_container.scroll_to_end()

func _on_input_timer_timeout():
	if shopping:
		if $shop.items_window.get_child_count() >= 3:
			$shop.items_window.get_child(2).grab_focus()
	else:
		if replies.is_visible_in_tree() and replies.get_child_count():
			replies.get_child(0).grab_focus()

func choose_reply(item: DialogItem, skip: bool):
	if !skip:
		show_message(item.text, "You")
		last_speaker = "You"
	current_item = item
	get_next()

func show_context_reply(item: DialogItem):
	if !remove_context_reply(item):
		print_debug("Could not remove context reply: '%d'" % item.text)
	set_process_input(true)
	# TODO: ability to mark contextual replies with unique block names
	var block_name = "_placeholder"
	push_stack(current_item, block_name, true)
	show_message(item.text, "You")
	last_speaker = "You"
	current_item = sequence.canonical_next(item)
	advance()

func remove_context_reply(item: DialogItem):
	for key in contextual_replies:
		for i in contextual_replies[key].size():
			if contextual_replies[key][i] == item:
				contextual_replies[key].remove(i)
				return true
	return false

# tags is an array of strings
func use_note(tags:Array):
	enable_replies()
	var l := _find_item("note", tags, true)
	if !l.empty():
		_goto_special(l[0], l[1])
	else:
		_no_label()

func use_item(id:String, desc: ItemDescription = null):
	enable_replies()
	if id == "coat":
		trade_coats()
		return
	var by_item := _find_item("item", [id], false)
	if !by_item.empty():
		_goto_special(by_item[0], by_item[1])
		return
	var by_tag := _find_item("item", desc.tags if desc else [], true)
	if !by_tag.empty():
		_goto_special(by_tag[0], by_tag[1])
	else:
		_no_label()

func get_speaker_name() -> String:
	if "visual_name" in main_speaker:
		return main_speaker.visual_name
	else:
		return main_speaker.name.capitalize()

func show_message(text: String, speaker: String, font_override:= ""):
	if speaker == "":
		speaker = get_speaker_name()

	if speaker != last_speaker:
		text = "%s: %s" % [speaker, text]
	last_speaker = speaker
	
	insert_label(text, speaker.to_lower(), font_override)

func show_narration(font_override: String):
	insert_label(current_item.text, "narration", font_override)

func insert_label(text: String, format: String, font_override := "", rich_text := true):
	var color:Color = colors["default"]
	var font:Font = fonts["default"]
	
	if font_override in fonts:
		font = fonts[font_override]
	elif format in fonts:
		font = fonts[format]
	
	if format in colors:
		color = colors[format]
	
	var label := RichTextLabel.new()
	label.fit_to_content = true
	label.scroll_active = false
	label.bbcode_enabled = true
	if rich_text:
		label.bbcode_text = interpolate(text)
	else:
		label.text = text
	if color != Color.black:
		label.add_font_override("normal_font", font)
		label.add_color_override("default_color", color)
	message_list.add_child(label)

func interpolate(line: String) -> String:
	var matches := r_interpolate.search_all(line)
	var text := line
	for m in matches:
		var ex = evaluate(m.get_string(1))
		text = text.replace(m.get_string(), str(ex))
	if text.count("/"):
		var italicized := false
		var read_in := text.split("/")
		var out_string = read_in[0]
		for i in range(1, read_in.size()):
			out_string += ("[i]" if !italicized else "[/i]") + read_in[i]
			italicized = !italicized
		text = out_string
	return text

func evaluate(ex_text: String):
	var expr: Expression = Expression.new()
	var err = expr.parse(ex_text, ["Global"])
	if err != OK:
		var msg := "\tFailed to parse {%s}. Code %d" % [ex_text, err]
		insert_label("[Error] "+ msg, "narration", "", false)
		print_debug(msg)
		return true
	
	var r = expr.execute([Global], self)
	
	if expr.has_execute_failed():
		var msg := "\tFailed to execute {%s}.\n\t%s" % [ 
			ex_text, expr.get_error_text()]
		insert_label("[Error] "+ msg, "narration", "", false)
		print_debug(msg)
		return true
	return r

func check_condition(cond: String):
	if cond == "otherwise":
		return {"_otherwise": otherwise}
	
	var result = evaluate(cond)
	return result

func end():
	main_speaker = null
	set_process_input(false)
	Global.can_pause = true
	get_tree().call_group("dialog_indicator", "play", "RESET")

func trade_coats():
	if mentioned("_coat"):
		get_next()
		return
	var coat_item := _find_item("_coat")
	if !coat_item.empty():
		mention("_coat")
		push_stack(current_item, coat_item[1], true)
		current_item = coat_item[0]
		advance()
	else:
		insert_label("[You cannot trade coats at this time]", "narration")

func push_stack(item: DialogItem, block_name: String, special_call := false):
	var m: Control
	if special_call:
		var box = aside_template.duplicate()
		message_list.add_child(box)
		m = box.get_node("container")
		var _x = m.connect("child_entered_tree", self, "_on_message_added", [], CONNECT_DEFERRED)
	else:
		m = message_list
	call_stack.push_back(CallFrame.new(item, message_list, block_name))
	message_list = m

func skip_and_exit():
	if !is_exiting:
		fast_exit()
	while get_next():
		continue

func fast_exit():
	if is_exiting:
		get_next()
	else:
		is_exiting = true
		var exit_item = _find_item("_exit")
		if exit_item.empty():
			exit_item = [null, "_exit"]
		push_stack(current_item, exit_item[1])
		current_item = exit_item[0]
		advance()

func pause():
	print_debug("Pausing dialog...")
	set_process_input(false)

func resume():
	set_process_input(true)
	if advance_on_resume:
		get_next()

func get_talked_stat():
	var s: String = speaker_stat()
	return "talked/" + s

func ui_settings_apply():
	for f in fonts.values():
		if f is DynamicFont:
			f.size = get_theme_default_font().size
	
	fonts["default"] = get_theme_default_font()
	colors["default"] = get_color("font_color", "Label")

func set_shopping(s):
	shopping = s
	$messages.visible = !shopping
	$shop.visible = shopping
	if shopping:
		$input_timer.start()

func _on_item_context_cancelled():
	enable_replies()
	if current_item and current_item.type == DialogItem.Type.REPLY:
		if replies.get_child_count():
			replies.get_child(0).grab_focus()

func _sort_labels(a: String, b: String):
	return sequence.labels[a] < sequence.labels[b]

func disable_replies():
	set_process_input(false)
	for c in replies.get_children():
		if c is Button:
			c.disabled = true
			c.focus_mode = FOCUS_NONE

func enable_replies():
	set_process_input(true)
	for c in replies.get_children():
		if c is Button:
			c.disabled = false
			c.focus_mode = FOCUS_ALL

func _jump_next(item: DialogItem):
	current_item = item
	advance()

func _goto_special(item: DialogItem, label: String):
	var block_name = block_names[label] if label in block_names else label
	push_stack(current_item, block_name, true)
	current_item = item
	advance()

func _find_item(type:String, items = null, fallthrough : bool = true) -> Array:
	var found_label: String
	if items:
		 found_label = "%s(_)" % type if fallthrough else ""
	else:
		found_label = type
	for label in sorted_labels:
		var l: String = label
		var block:String = label if !(label in block_names) else block_names[label]
		if l.begins_with('@'):
			l = l.substr(1)
		if !l.begins_with(type):
			continue
		if block in block_states and block_states[block] == LocalBlockState.Invalid:
			continue
		if items:
			var found := false
			for item in items:
				if l.begins_with("%s(%s)" % [type, item]):
					found = true
					break
			if !found:
				continue
		found_label = label
		break
	if found_label != "" and sequence.has(found_label):
		return [sequence.find_label(found_label), found_label]
	else:
		return []

func _no_label():
	insert_label("[Nothing happened]", "narration")
	if replies.get_child_count():
		replies.get_child(0).grab_focus()

func insert_contextual_reply(message: DialogItem, added_context := ""):
	var key := "--never-remove--"
	if added_context != "":
		mention(added_context)
		key = added_context
	if key in contextual_replies:
		contextual_replies[key].append(message)
	else:
		contextual_replies[key] = [message]
	_notify_contextual_reply()

########################################
## Dialog functions
########################################

func exiting():
	is_exiting = true
	return true

func track_conversation_time():
	Global.set_stat("talk_time"+get_speaker_name(), OS.get_unix_time())
	return true

func seconds_since_conversation() -> int:
	var prev: int = Global.stat("talk_time"+get_speaker_name())
	var now: int = OS.get_unix_time()
	return now - prev

func format(style: String):
	return {"_format":style}

func event(tag: String, should_pause := false, auto_advance_on_resume:= true):
	emit_signal("event", tag)
	emit_signal("event_with_source", tag, main_speaker)
	if main_speaker.has_method(tag):
		main_speaker.call(tag)
	if should_pause:
		advance_on_resume = auto_advance_on_resume
		return RESULT_PAUSE
	else:
		return true

func goto(label: String):
	var item := _find_item(label)
	if item:
		current_item = item[0]
		return RESULT_SKIP
	else:
		return false

func skip():
	skip_reply = true
	# Ironic how skip() does not return RESULT_SKIP
	return true

func noskip():
	return RESULT_NOSKIP

func complete_block(id: String = ""):
	return _set_block(id, BlockState.Completed)

func mark_discussed(id: String = ""):
	return _set_block(id, BlockState.Completed)

func _set_block(id: String, state: int):
	if id == "":
		if call_stack.empty():
			return false
		id = call_stack[call_stack.size() - 1].block_name
	var block_stat = speaker_stat() + "/" + id
	if Global.stat(block_stat) < state:
		Global.set_stat(block_stat, state)
	block_states[id] = LocalBlockState.Visited
	_check_notifications()
	return true

func exit(state := PlayerBody.State.Ground):
	if is_instance_valid(main_speaker) and main_speaker.has_method("exit_dialog"):
		main_speaker.exit_dialog()
	var stat: String = get_talked_stat()
	end()
	var _x = Global.add_stat(stat)
	emit_signal("exited", state)
	return RESULT_END

func exit_anim(animation:String):
	var stat: String = get_talked_stat()
	var _x = Global.add_stat(stat)
	emit_signal("exited_anim", animation)
	end()
	return RESULT_END

func mention(topic):
	context[topic] = true
	_evaluate_labels()
	return true

func mentioned(topic):
	return topic in context

func forget(topic):
	var _x = contextual_replies.erase(topic)
	return context.erase(topic)

func subtopic(label: String):
	push_stack(current_item, block_names[label] if label in block_names else label)
	return goto(label)

func discussed(id: String = "") -> bool:
	return _block_state(id, BlockState.Completed)

func completed(id: String = "") -> bool:
	return _block_state(id, BlockState.Completed)

func _block_state(id: String, min_state: int) -> bool:
	if id == "":
		if call_stack.empty():
			return false 
		var block_name:String = call_stack[call_stack.size() - 1].block_name
		id = block_name
	var block_stat = speaker_stat() + "/" + id
	return Global.stat(block_stat) >= min_state

# 'completed' indicates the player doesn't need to revisit this block
func back(completed := true):
	# If there's nothing on the call stack, we just continue
	if call_stack.empty():
		return true
	if completed:
		complete_block()
	else:
		mark_discussed()
	var call_frame:CallFrame = call_stack.pop_back()
	var caller := call_frame.item
	message_list = call_frame.box
	
	if caller.type == DialogItem.Type.REPLY:
		current_item = caller
	elif caller.type == DialogItem.Type.CONTEXT_REPLY:
		current_item = sequence.failed_next(caller)
	else:
		current_item = sequence.canonical_next(caller)
	return RESULT_SKIP

func coat_trade_stat() -> String:
	return "coat_trade/" + speaker_stat()

func traded_coats():
	return Global.stat(coat_trade_stat())

func swap_coats():
	var _x = Global.add_stat(coat_trade_stat())
	_x = Global.add_stat("trade_coat")
	var player_coat: Coat = player.current_coat
	var speaker_coat: Coat = main_speaker.get_coat()
	main_speaker.set_coat(player_coat)
	Global.add_coat(speaker_coat)
	player.set_current_coat(speaker_coat, true)
	Global.remove_coat(player_coat)
	return true

func set_var(var_name: String, value):
	variables[var_name] = value

func has_var(var_name: String):
	return var_name in variables

func inc_var(var_name: String, value: int = 1):
	if !has_var(var_name):
		set_var(var_name, 0)
	variables[var_name] += value
	return variables[var_name]

func ternary(cond: bool, when_true, when_false):
	if cond:
		return when_true
	else:
		return when_false

func speaker_stat() -> String:
	if !is_instance_valid(main_speaker):
		return "_NO_SPEAKER_"
	if "friendly_id" in main_speaker and main_speaker.friendly_id != "":
		return main_speaker.friendly_id
	else:
		return Global.node_stat(main_speaker)

func general_time(late_morning := false) -> String:
	var s = get_tree().current_scene
	if s.has_method("get_time"):
		var t:float = s.get_time()
		if t > 19 or t < 2.5:
			return "evening"
		elif t > 12:
			return "afternoon"
		elif t > 9.75:
			return "day" if !late_morning else "morning"
		else:
			return "morning"
	return "day"

func exact_time() -> String:
	var s = get_tree().current_scene
	if s.has_method("get_time"):
		return NumberToString.say_time(s.get_time())
	return "noon"

func say_number(v: float) -> String:
	return NumberToString.verbose(v)

func can_discuss(stat: String) -> bool:
	return Global.stat(stat) and !Global.stat("context/" + speaker_stat() + "/" + stat)

func mark_context(stat: String) -> bool:
	var _x = Global.add_stat("context/" + speaker_stat() + "/" + stat)
	return true

func shop():
	set_shopping(true)
	$shop.start_shopping(main_speaker)
	return true

func remember(note: String, subject: String = ""):
	if subject == "":
		subject = speaker_stat()
	Global.remember(subject)
	Global.add_note(note, [subject])
	return true

func knows(person: String):
	return Global.has_note(person)

func task_exists(id):
	return Global.task_exists(id)

func task_is_active(id):
	return Global.task_is_active(id)

func task_is_complete(id):
	return Global.task_is_complete(id)

func stat(s: String):
	return Global.stat(s)

func playing_game() -> bool:
	return CustomGames.is_playing(main_speaker.get_parent())

func has_game_stat(sub_stat) -> bool:
	return CustomGames.has_stat(main_speaker.get_parent(), sub_stat)

func game_stat(sub_stat):
	return CustomGames.stat(main_speaker.get_parent(), sub_stat)

func game_completed():
	return CustomGames.completed(main_speaker.get_parent())

func game_start():
	return main_speaker.get_parent().start()

func control_screen(val := true):
	emit_signal("control_screen", val)
	return true

func note(stat: String, text: String, tags: Array, allow_duplicates := false):
	if not allow_duplicates and Global.stat(stat):
		return false
	if stat != "":
		var _x = Global.add_stat(stat)
		tags.append(stat)
	return Global.add_note(text, tags)
