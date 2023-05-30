extends Control

export(NodePath) var tracking_node
export(String) var value_property
export(String) var max_property
export(float) var time_to_hide := 0.0

export(float) var speed := 40.0
export(float) var acceleration := 10.0
export(float) var deceleration := 0.5

onready var n := get_node(tracking_node)
onready var mat:ShaderMaterial = $fancy.material

var vel := 0.0
var hide_timer := 0.0

func _process(delta):
	var v:float = mat["shader_param/value"]
	var value:float = n.get(value_property)
	var max_value:float = n.get(max_property)
	
	if v == 1.0 and value == max_value:
		if time_to_hide and visible:
			hide_timer += delta
			if hide_timer > time_to_hide:
				queue_hide()
		return
	elif !visible:
		queue_show()

	var tv:float = value/max_value
	var d := tv-v
	vel = move_toward(vel, sign(d)*speed, abs(delta*d*acceleration))
	vel = move_toward(vel, 0, abs(delta*vel*deceleration))
	mat['shader_param/value'] = move_toward(v, tv, abs(vel))

func queue_show():
	hide_timer = -0.5
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
