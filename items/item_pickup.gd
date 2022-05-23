tool
extends KinematicBody
class_name ItemPickup

signal gravity_stun(stun)

export(String) var item_id
export(int) var quantity := 1
export(PackedScene) var preview
export(bool) var persistent := true
export(bool) var gravity = false
export(String) var friendly_name = ""
export(bool) var from_kill := false

const sq_distance_visible := 30000

var gravity_stun_time := 0.0
var fall_velocity := 0.0

func _ready():
	if preview:
		add_child(preview.instance())
	if Engine.editor_hint:
		return
	if persistent and Global.is_picked(get_path()):
		queue_free()
		return
	if from_kill:
		$area/CollisionShape.disabled = true
		$pickup_timer.start()
	if has_node("AnimationPlayer"):
		$AnimationPlayer.seek(rand_range(0, $AnimationPlayer.current_animation_length))

func _physics_process(delta):
	if gravity:
		if gravity_stun_time > 0:
			gravity_stun_time -= delta
			fall_velocity *= clamp(1.0 - delta, 0.1, 0.995)
			fall_velocity += delta*Global.gravity_stun_velocity
			if gravity_stun_time <= 0:
				emit_signal("gravity_stun", false)
		else:
			fall_velocity -= 9.8*delta
		var col = move_and_collide(delta*Vector3.UP*fall_velocity)
		if col:
			fall_velocity = 0.0

func _on_area_body_entered(body):
	var _x = Global.add_item(item_id, quantity)
	body.get_item(item_id)
	if persistent:
		Global.mark_picked(get_path())
		if friendly_name != "":
			_x = Global.add_stat(friendly_name)
	queue_free()

func gravity_stun(_damage):
	gravity = true
	gravity_stun_time = Global.gravity_stun_time
	fall_velocity = 3
	emit_signal("gravity_stun", true)

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

func _on_pickup_timer_timeout():
	$area/CollisionShape.disabled = false
