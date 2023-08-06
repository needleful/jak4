extends Node

const INPUT_EPSILON := 0.1
var input_buffer := {
	"mv_jump":INF,
	"mv_crouch":INF,
	"combat_lunge":INF,
	"combat_spin":INF,
	"hover_toggle":INF,
}

var using_gamepad := true
var ui: Node

func _input(event):
	if !get_tree().paused:
		for e in input_buffer.keys():
			if event.is_action_pressed(e):
				input_buffer[e] = 0.0
	var ogg := using_gamepad
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_gamepad = true
	elif event is InputEventMouse or event is InputEventKey:
		using_gamepad = false
	
	if ( ogg != using_gamepad and 
		Settings.sub_options["Controls"].button_prompts == ControlsSettings.Prompts.AutoDetect
	):
		get_tree().call_group("input_prompt", "_refresh")

func _physics_process(delta):
	for e in input_buffer.keys():
		input_buffer[e] += delta

func pressed(action:String):
	if action in input_buffer:
		var res = input_buffer[action] < INPUT_EPSILON
		input_buffer[action] = INF
		return res and !ui.input_blocked
	else:
		return Input.is_action_just_pressed(action) and !ui.input_blocked

func released(action:String):
	return Input.is_action_just_released(action) and !ui.input_blocked

func holding(action:String):
	return Input.is_action_pressed(action)

func get_action_input_string(action: String, override = null):
	var gamepad
	if override != null:
		gamepad = override
	else:
		gamepad = using_gamepad
		
	var input: InputEvent
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
		return key_str

	return get_input_string(input)

func get_input_string(input:InputEvent):
	if input is InputEventJoypadButton:
		return "gamepad"+str(input.button_index)
	elif input is InputEventMouseButton:
		return "mouse"+str(input.button_index)
	elif input is InputEventJoypadMotion:
		return "axis"+str(input.axis)
	return str(input)

func get_mouse_zoom_axis() -> float:
	return 15*( float(Input.is_action_just_released("mouse_zoom_in"))
			- float(Input.is_action_just_released("mouse_zoom_out")) )
