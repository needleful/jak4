extends Area

export(int) var random_seed = -1
export(bool) var persistent := true

var coat: Coat

func _ready():
	if persistent and Global.is_picked(get_path()):
		queue_free()
		return
	if random_seed < 0:
		random_seed = randi()
	coat = Global.get_coat(random_seed)
	$MeshInstance.material_override = coat.generate_material()
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(b):
	Global.add_coat(coat)
	if b is PlayerBody:
		b.set_current_coat(coat)
	if persistent:
		Global.mark_picked(get_path())
	queue_free()
