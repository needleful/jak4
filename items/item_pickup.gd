extends KinematicBody

export(String) var item_id
export(int) var quantity = 1
export(PackedScene) var preview
export(bool) var persistent := true
export(bool) var gravity = false

func _ready():
	if persistent and Global.is_picked(get_path()):
		queue_free()
		return
	if has_node("AnimationPlayer"):
		$AnimationPlayer.seek(rand_range(0, $AnimationPlayer.current_animation_length))

func _physics_process(delta):
	if gravity:
		var _c = move_and_collide(delta*Vector3.DOWN*15)

func _on_area_body_entered(body):
	var _x = Global.add_item(item_id, quantity)
	body.get_item(item_id)
	if persistent:
		Global.mark_picked(get_path())
	queue_free()
