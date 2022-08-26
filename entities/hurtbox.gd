extends Area

export(Vector3) var direction := Vector3.ZERO
export(int) var damage := 10
export(bool) var active := false
export(bool) var time_sensitive := false

func _ready():
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	print("body entered: ", body.name)
	if !active:
		print("inactive")
		return
	if !body.has_method("take_damage"):
		print("no damage method")
		return
	if time_sensitive and body is PlayerBody and TimeManagement.time_slowed:
		print("time to be epic")
		return
	print("damaged!")
	var dir := direction
	if dir == Vector3.ZERO:
		dir = (body.global_transform.origin - global_transform.origin).normalized()
	body.take_damage(damage, dir, self)
