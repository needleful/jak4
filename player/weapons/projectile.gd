extends KinematicBody

signal contact(node)

var speed := 20.0
var velocity : Vector3
var explode_on_contact := false
var flight_time := 0.0
const MIN_TIME := 0.25

func fire(direction: Vector3):
	explode_on_contact = false
	flight_time = 0.0
	velocity = speed*direction

func _physics_process(delta):
	flight_time += delta
	velocity += Vector3.DOWN*9.8*delta
	if !Input.is_action_pressed("combat_shoot"):
		if flight_time < MIN_TIME:
			explode_on_contact = true
		elif !explode_on_contact:
			emit_signal("contact", self)
			return
	var col = move_and_collide(velocity*delta)
	if col:
		if explode_on_contact:
			emit_signal("contact", self)
		else:
			velocity = -velocity.reflect(col.normal)
