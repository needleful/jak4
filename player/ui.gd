extends Control

enum State {
	Free,
	Paused,
	Map
}

var state = null

func _ready():
	set_state(State.Free)

func _input(event):
	match state:
		State.Free:
			if event.is_action_pressed("map_toggle"):
				set_state(State.Map)
			elif event.is_action_pressed("pause"):
				set_state(State.Paused)
		State.Map:
			if event.is_action_pressed("map_toggle") or event.is_action_pressed("pause"):
				set_state(State.Free)
		State.Paused:
			if event.is_action_pressed("pause"):
				set_state(State.Free)

func show_map() -> bool:
	if state == State.Paused:
		return false
	else:
		set_state(State.Map)
		return true

func unpause() -> bool:
	if state != State.Paused:
		return false
	else:
		set_state(State.Free)
		return true

func set_state(new_state):
	if new_state == state:
		return
	match new_state:
		State.Free:
			get_tree().paused = false
			$pause_menu.set_active(false)
			$map.set_active(false)
		State.Map:
			get_tree().paused = true
			$pause_menu.set_active(false)
			$map.set_active(true)
		State.Paused:
			get_tree().paused = true
			$pause_menu.set_active(true)
			$map.set_active(false)
	state = new_state
