extends Control

export(NodePath) var tracking_node: NodePath
export(String) var value_property: String
export(String) var segment_property: String
export(float) var segment_interval: float

export(float) var speed := 20.0
export(float) var acceleration := 2.0
export(float) var deceleration := 1.0

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
	var s:int = n.get(segment_property)
	var change_size := s != segments.size()
	
	while s > segments.size():
		var seg = segment_template.duplicate()
		seg.material = segment_template.material.duplicate()
		seg.material["shader_param/value"] = 0
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
	for segment in segments:
		var segment_value := amount - i
		segment.material["shader_param/value"] = segment_value
		if s <= i and segment_value <= 0:
			segment.queue_free()
			removed += 1
		i += 1
	for _r in removed:
		var _x = segments.pop_back()
