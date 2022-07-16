extends Control

export(String) var label setget set_label, get_label
export(int) var value setget set_value, get_value

onready var 

var in_game := false
var targets := []
var markers := []

func _ready():
	visible = in_game

func start_game(label: String)-> bool:
	show()
	set_label(label)
	if in_game:
		print_debug("Tried to start a game while inside one!")
		return false
	in_game = true
	return true

func add_target(target: Spatial):
	targets.append(target)
	set_process(true)

func remove_target(target: Spatial):
	var i = targets.find(target)
	if i >= 0:
		targets.remove(i)
	if targets.empty():
		set_process(false)

func end_game() -> bool:
	if !in_game:
		print_debug("Tried to end game when there was none")
		return false
	in_game = false
	hide()
	targets = []
	set_process(false)
	return true

func set_label(val):
	label = val
	$Label.text = val

func get_label() -> String:
	return label

func set_value(val: int):
	value = val
	$number.text = str(val)

func get_value() -> int:
	return value
