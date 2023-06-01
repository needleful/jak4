extends Control

export(NodePath) var tracking_node: NodePath
export(String) var value_property: String
export(String) var segment_property: String
export(float) var segment_interval: float

export(float) var speed := 20.0
export(float) var acceleration := 2.0
export(float) var deceleration := 1.0
export(bool) var reversed := false

onready var segment_template := $segment
onready var n := get_node(tracking_node)

var segments : Array
var amount : float
var vel := 0.0

func _init():
	segments = []

func _ready():
	remove_child(segment_template)

func _process(delta):
	if visible and !is_visible_in_tree():
		return
	var s:int = n.get(segment_property)
	var change_size := s != segments.size()
	
	while s > segments.size():
		var seg = segment_template.duplicate()
		seg.material = segment_template.material.duplicate()
		seg.material["shader_param/value"] = 0
		if reversed and get_child_count():
			add_child_below_node(get_child(get_child_count() - 1), seg)
		else:
			add_child(seg)
		segments.append(seg)
	
	var value:float = n.get(value_property)
	var v := value/segment_interval
	if amount == v and !change_size:
		return

	var d := amount - v
	
	vel = move_toward(vel, sign(d)*speed, abs(delta*d*acceleration))
	vel = move_toward(vel, 0, abs(delta*vel*deceleration))
	
	amount = move_toward(amount, v, abs(vel))
	var i := 0
	var removed := 0
	var seglen := segments.size() - 1
	for segment in segments:
		var index:int = i if !reversed else seglen - i
		var segment_value:float = amount - index
		segment.material["shader_param/value"] = segment_value
		if s <= index and segment_value <= 0:
			segment.queue_free()
			removed += 1
		i += 1
	for _r in removed:
		var _x = segments.pop_back() if !reversed else segments.pop_front()
