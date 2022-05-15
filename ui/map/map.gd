extends Control

onready var scroll_area := $scrollable_map
onready var reticle := $reticle

var active := false

var snap_timer := 0
var snap_direction := Vector2.ZERO
var zoom_scale := 1.0

var last_moved_dir := Vector2.ZERO

func _ready():
	set_active(false)

func _process(delta: float):
	# Snap
	if snap_timer > 0:
		var ratio = clamp(delta*10, 0.0, 0.1)
		snap_timer *= 1 - ratio
		var snap_move = ratio*snap_direction
		snap_direction *= 1 - ratio
		if snap_timer < 0.01:
			snap_timer = 0
		scroll_area.position -= snap_move
	# Zoom
	var zoom := Input.get_axis("map_zoom_out", "map_zoom_in")
	if zoom != 0:
		var rel_pos = reticle.global_position - scroll_area.global_position
		var zoom_change =  pow(1 + delta, zoom)
		var new_zoom = clamp(zoom_scale*zoom_change, 1, 4)
		zoom_change = new_zoom/zoom_scale
		zoom_scale = new_zoom
		scroll_area.scale = Vector2(zoom_scale, zoom_scale)
		scroll_area.translate(rel_pos - zoom_change*rel_pos)
	# Movement
	var max_pos :Vector2 = OS.window_size/2 + zoom_scale*scroll_area.texture.get_size()/2
	var min_pos:Vector2 = -zoom_scale*scroll_area.texture.get_size()/2 + OS.window_size/2
	var movement = Input.get_vector("mv_left", "mv_right", "mv_up", "mv_down")
	if movement != Vector2.ZERO:
		last_moved_dir = movement
	scroll_area.translate(-delta*400*movement)
	scroll_area.position.x = clamp(scroll_area.position.x, min_pos.x, max_pos.x)
	scroll_area.position.y = clamp(scroll_area.position.y, min_pos.y, max_pos.y)
	
	# Find snap target
	var best_dist := 60
	reticle.get_node("Label").hide()
	for g in scroll_area.get_children():
		if !(g is KinematicBody2D) or !g.visible:
			continue
		var dir = g.global_transform.origin - reticle.global_transform.origin
		
		var dist = dir.length()
		if dist < best_dist and dist < 40:
			reticle.get_node("Label").show()
			reticle.get_node("Label").text = g.visual_name
		if dir.dot(last_moved_dir) <= 0:
			continue
		if dist < best_dist and dist > 10:
			print("Snap to ", g.name)
			best_dist = dist
			snap_direction = dir
			snap_timer = 1.0

func set_active(a):
	reticle.global_position = OS.window_size/2
	zoom_scale = 1
	scroll_area.scale = Vector2(1, 1)
	active = a
	visible = active
	set_process(active)
