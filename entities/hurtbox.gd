extends Area

export(Vector3) var direction := Vector3.ZERO
export(int) var damage := 10

func _ready():
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if !body.has_method("take_damage"):
		return
	var dir := direction
	if dir == Vector3.ZERO:
		dir = (body.global_transform.origin - global_transform.origin).normalized()
	body.take_damage(damage, dir)
