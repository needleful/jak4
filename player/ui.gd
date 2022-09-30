extends Control

enum Mode {
	Gameing,
	Dialog,
	Paused,
	DebugConsole,
	Custom
}

var mode:int = Mode.Gameing setget set_mode
var mode_before_pause:int = Mode.Gameing

onready var game := $gameing
onready var dialog := $dialog_viewer
onready var status := $status_menu
var custom_ui : Control
var loaded_ui : PackedScene


func _ready():
	set_mode(Mode.Gameing)
	set_process_input(true)

func _input(event):
	match mode:
		Mode.Gameing:
			if event.is_action_pressed("pause"):
				set_mode(Mode.Paused)
			elif event.is_action_pressed("debug_console"):
				set_mode(Mode.DebugConsole)
		Mode.Paused:
			if event.is_action_pressed("pause"):
				var _x = unpause()
			elif event.is_action_pressed("ui_page_up"):
				status.next()
			elif event.is_action_pressed("ui_page_down"):
				status.prev()
			elif event.is_action_pressed("debug_console"):
				set_mode(Mode.DebugConsole)
		Mode.Custom:
			if event.is_action_pressed("pause"):
				set_mode(Mode.Gameing)
			elif event.is_action_pressed("debug_console"):
				set_mode(Mode.DebugConsole)
		Mode.DebugConsole:
			if event.is_action_pressed("debug_console"):
				var _x = unpause()

func start_dialog(source: Node, sequence: Resource, speaker: Node, starting_label := ""):
	set_mode(Mode.Dialog)
	dialog.start(source, sequence, speaker, starting_label)

func set_mode(m):
	if m < 0 or m >= get_child_count():
		print_debug("Bad mode! ", m)
		return
	
	var should_pause: bool = (m == Mode.Paused or m == Mode.DebugConsole)
	if should_pause and !get_tree().paused:
		mode_before_pause = mode
	get_tree().paused = should_pause
	
	mode = m
	var i = 0
	for c in get_children():
		if !(c is Control):
			continue
		c.visible = i == mode
		if c.has_method("set_active"):
			c.set_active(c.visible)
		i += 1

func show_status() -> bool:
	set_mode(Mode.Paused)
	return true

func unpause() -> bool:
	$post_pause_timer.start()
	set_mode(mode_before_pause)
	return true

func recently_paused():
	return !$post_pause_timer.is_stopped()

func play_game() -> bool:
	set_mode(Mode.Gameing)
	return true

func open_custom(scene: PackedScene) -> bool:
	if !scene:
		return false

	if loaded_ui == scene:
		set_mode(Mode.Custom)
		return true

	var cui := scene.instance() as Control
	if !cui:
		return false

	if custom_ui:
		remove_child(custom_ui)
		custom_ui.queue_free()
	custom_ui = cui
	add_child(custom_ui)

	if custom_ui.has_signal("exited"):
		var _x = custom_ui.connect("exited", self, "play_game")
	
	loaded_ui = scene
	
	set_mode(Mode.Custom)
	return true
