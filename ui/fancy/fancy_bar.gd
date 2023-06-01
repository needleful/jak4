extends Control

export(NodePath) var tracking_node: NodePath
export(String) var value_property: String
export(String) var max_property: String
export(String) var extension_item: String
export(float) var extension_interval : float
export(float) var time_to_hide := 0.0

export(float) var speed := 40.0
export(float) var acceleration := 10.0
export(float) var deceleration := 0.5

onready var n := get_node(tracking_node)
onready var mat:ShaderMaterial = $fancy.material

var vel := 0.0
var hide_timer := 0.0
var extensions := 0

func _process(delta):
	var v:float = mat["shader_param/value"]
	var value:float = n.get(value_property)
	var max_value:float = n.get(max_property)
	var e :int = Global.count(extension_item)
	var tv:float = value/max_value
	var d := tv-v
	vel = move_toward(vel, sign(d)*speed, delta*max(abs(d), 1)*acceleration + delta)
	vel = move_toward(vel, 0, abs(delta*vel*deceleration))
	
	if ( extensions == e and abs(d) <= 0.001
		and abs(vel) < 0.005 and value >= max_value
	):
		if !visible:
			return
		elif time_to_hide:
			hide_timer += delta
			if hide_timer > time_to_hide:
				queue_hide()
	elif !visible:
		queue_show()

	mat['shader_param/value'] = move_toward(v, tv, abs(vel))
	
	if e != extensions:
		var i := 0
		for c in $extensions.get_children():
			if e > i:
				c.show()
			else:
				c.hide()
			i += 1
		extensions = e
	var ext_value:float = (v - 1.0)*max_value/extension_interval
	for i in extensions:
		var vis := $extensions.get_child(i)
		vis.material["shader_param/value"] = ext_value - i

func queue_show():
	hide_timer = -1.5
	if !visible:
		modulate = Color(1,1,1,0)
	show()
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "modulate", Color.white, 0.5)

func queue_hide():
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
	yield(get_tree().create_timer(0.5), "timeout")
	if hide_timer > time_to_hide:
		hide()
