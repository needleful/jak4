extends Control

export(String) var label setget set_label, get_label
export(String) var value setget set_value, get_value

onready var marker := $marker_ref

var in_game := false
var targets: Array
var markers: Array
var custom_overlay : Node

func _init():
	targets = []
	markers = []

func _ready():
	var _x = CustomGames.connect("game_started", self, "start_game")
	_x = CustomGames.connect("game_failed", self, "fail_game")
	_x = CustomGames.connect("game_completed", self, "complete_game")
	
	_x = $AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	
	visible = in_game
	remove_child(marker)

func _process(_delta):
	for i in range(targets.size()):
		var t: Spatial = targets[i]
		var m: Sprite = markers[i]
		var cam:Camera = get_viewport().get_camera()
		
		if !cam.is_position_behind(t.global_transform.origin):
			m.show()
			m.global_position = cam.unproject_position(t.global_transform.origin)
		else:
			m.hide()

func cancel_game():
	CustomGames.cancel_game()

func start_game(text: String, _id : int)-> bool:
	set_process(true)
	$AnimationPlayer.play("start")
	show()
	set_label(text)
	if in_game:
		print_debug("Tried to start a game while inside one!")
		return false
	in_game = true
	set_value_visible(false)
	return true

func set_value_visible(vis):
	$values/number.visible = vis
	$values/spacer.visible = vis

func add_target(target: Spatial):
	targets.append(target)
	var m = marker.duplicate()
	add_child(m)
	markers.append(m)
	set_process(true)

func remove_target(target: Spatial):
	var i = targets.find(target)
	if i >= 0:
		targets.remove(i)
		markers[i].queue_free()
		markers.remove(i)
	if targets.empty():
		set_process(false)

func set_overlay(overlay: Node):
	if custom_overlay:
		custom_overlay.queue_free()
	custom_overlay = overlay
	add_child(custom_overlay)

func complete_game(custom_message:= ""):
	var message := "Challenge Completed"
	if custom_message != "":
		message = custom_message
	$values/Label.text = message
	if _end_game(false):
		$AnimationPlayer.play("completed")

func fail_game(custom_message:= ""):
	var message := "Challenge Completed"
	if custom_message != "":
		message = custom_message
	$values/Label.text = message
	if _end_game(false):
		$AnimationPlayer.play("fail")

func _end_game(should_hide := true) -> bool:
	set_process(false)
	if !in_game:
		print_debug("Tried to end game when there was none")
		return false
	in_game = false
	targets = []
	for m in markers:
		m.queue_free()
	markers = []
	set_process(false)
	if should_hide:
		if custom_overlay:
			custom_overlay.queue_free()
			custom_overlay = null
		hide()
	return true

func set_label(val):
	label = val
	$values/Label.text = val

func get_label() -> String:
	return label

func set_value(val):
	value = val
	set_value_visible(true)
	$values/number.text = str(val)

func add_value(change_amount: int):
	set_value(value + change_amount)
	if change_amount != 0:
		if $values/AnimationPlayer.is_playing():
			$values/AnimationPlayer.stop()
		$values/number2.text = ("+ " if change_amount > 0 else '- ') + str(change_amount)
		$values/AnimationPlayer.play("ValueChanged")

func get_value() -> String:
	return value

func _on_animation_finished(anim):
	if anim == "fail" || anim == "completed":
		if custom_overlay:
			custom_overlay.queue_free()
			custom_overlay = null
		hide()
