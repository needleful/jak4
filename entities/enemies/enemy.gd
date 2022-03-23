extends KinematicBody
class_name KinematicEnemy

export(bool) var respawns := true
export(bool) var drops_coat := false
export(int) var gem_drop_max = 5
export(int) var health = 15
export(int) var attack_damage = 10

var coat_scene:PackedScene = load("res://items/coat_pickup.tscn")
var gem_scene:PackedScene = load("res://items/gem_pickup.tscn")

var target: Spatial
var damaged:= []

var coat = null

func prepare():
	if !respawns and Global.is_picked(get_path()):
		queue_free()
		return
	if drops_coat:
		coat = Global.get_coat()

func damage_direction(hitbox: Area, dir: Vector3):
	for c in hitbox.get_overlapping_bodies():
		if !(c in damaged) and c.has_method("take_damage"):
			c.take_damage(attack_damage, dir)
		damaged.append(c)

func look_at_target(turn_amount: float):
	if !target:
		return
	var forward := global_transform.basis.z
	var desired_f := target.global_transform.origin - global_transform.origin
	desired_f.y = 0
	desired_f = desired_f.normalized()
	var axis = forward.cross(desired_f).normalized()
	if axis.is_normalized():
		var angle = forward.angle_to(desired_f)
		var rot = sign(angle)*min(abs(angle), turn_amount)
		global_rotate(axis, rot)

func die():
	if drops_coat:
		var c = coat_scene.instance()
		c.coat = coat
		c.persistent = false
		get_parent().add_child(c)
		c.global_transform = global_transform
	var gems = int(rand_range(0, gem_drop_max))
	if gems > 0:
		var g = gem_scene.instance()
		g.quantity = gems
		get_parent().add_child(g)
		g.global_transform = global_transform
	if !respawns:
		Global.mark_picked(get_path())
