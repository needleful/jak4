extends KinematicBody

export(String) var item_id
export(int) var quantity = 1
export(PackedScene) var preview
export(bool) var persistent := true
export(bool) var gravity = false
export(String) var friendly_name = ""

const sq_distance_visible := 30000

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
		if friendly_name != "":
			_x = Global.add_stat(friendly_name)
	queue_free()

func process_player_distance(origin: Vector3):
	var sq_dist = (origin - global_transform.origin).length_squared()
	var vis = sq_dist < sq_distance_visible
	if visible != vis:
		visible = vis
		if has_node("AnimationPlayer"):
			if visible:
				$AnimationPlayer.play()
			else:
				$AnimationPlayer.stop(false)
	return INF
