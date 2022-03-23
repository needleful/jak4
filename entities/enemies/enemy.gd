extends KinematicBody
class_name KinematicEnemy

export(bool) var respawns := true
export(bool) var drops_coat := false
export(int) var gem_drop_max = 5
export(int) var health = 15
export(int) var attack_damage = 10
export(float) var damaged_speed = 5.0

enum AI {
	Idle,
	Alerted,
	Chasing,
	Windup,
	Attacking,
	Damaged,
	Dead
}
var ai = AI.Idle

const GRAVITY := Vector3.DOWN*24

var coat_scene:PackedScene = load("res://items/coat_pickup.tscn")
var gem_scene:PackedScene = load("res://items/gem_pickup.tscn")

var target: Spatial
var velocity := Vector3.ZERO
var move_dir: Vector3
var damaged:= []

var coat = null

func _ready():
	set_state(ai)
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
		c.from_kill = true
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

func take_damage(damage: int, dir: Vector3):
	health -= damage
	move_dir = dir*damaged_speed
	if health <= 0:
		set_state(AI.Dead)
	else:
		set_state(AI.Damaged)

func walk(delta, speed):
	var hvel = global_transform.basis.z*speed
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	velocity = move_and_slide(velocity + GRAVITY*delta)

# Implemented by subclasses
func set_state(_ai: int):
	pass
