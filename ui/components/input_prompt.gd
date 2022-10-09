extends Control

export(String) var action setget set_action

var default_size = rect_size

# device/input event
const prompt_path := "res://ui/prompts/%s/%s.png"

func _ready():
	default_size = rect_size
	var _x = connect("visibility_changed", self, "_refresh")

func _refresh():
	set_action(action)

func set_action(a):
	action = a
	if action == "":
		$texture.hide()
		$key_prompt.hide()
		return

	if !InputMap.has_action(action):
		print_debug("MISSING_ACTION: ", action, " FOR NODE: ", get_path())
		show_text(action)
		return
	
	var input: InputEvent
	
	var gamepad = Global.using_gamepad
	for event in InputMap.get_action_list(action):
		if gamepad and (
			event is InputEventJoypadButton
			or event is InputEventJoypadMotion
		):
			input = event
			break
		elif !gamepad and (
			event is InputEventKey
			or event is InputEventMouseButton
		):
			input = event
			break
	
	if input is InputEventKey:
		var scancode = input.physical_scancode
		if !scancode:
			scancode = input.scancode
		var key_str = OS.get_scancode_string(scancode)
		if key_str == "":
			key_str = "<unbound>"
		show_text(key_str)
	else:
		var device = "pad_generic"
		if !gamepad:
			device = "keyboard"
		var event_str = get_input_string(input)
		var prompt = prompt_path % [device, event_str]
		if ResourceLoader.exists(prompt):
			var t = load(prompt)
			show_image(t)
		else:
			show_text(event_str)

func show_image(image: Texture):
	$key_prompt.hide()
	$texture.show()
	$texture.texture = image
	rect_size = image.get_size()
	$texture.rect_min_size = image.get_size()

func show_text(text):
	$texture.hide()
	$key_prompt.show()
	$key_prompt/Label.text = text
	rect_size = default_size

func get_input_string(input:InputEvent):
	if input is InputEventJoypadButton:
		return "gamepad"+str(input.button_index)
	elif input is InputEventMouseButton:
		return "mouse"+str(input.button_index)
	elif input is InputEventJoypadMotion:
		return "axis"+str(input.axis)
	return str(input)
