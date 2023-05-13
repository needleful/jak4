extends RigidBody

export(float, 0, 10) var delay := 1.0
export(float, 0, 10) var reset_time := 3.0

export(ShaderMaterial) var discard_material
export(ShaderMaterial) var hologram_material

const time_to_unlock := 1.0

var falling := false
onready var starting_position := global_transform

func _ready():
	var p = Global.get_player()
	if p is PlayerBody:
		p.connect("died", self, "_on_player_died")

func _on_body_entered(body):
	if body is PlayerBody and body.velocity.y > 1.0 && body.global_transform.origin.y < global_transform.origin.y:
		return
	fall()

func fall():
	can_sleep = false
	if falling:
		return
	falling = true
	yield(get_tree().create_timer(delay), "timeout")
	if !falling:
		return
	sleeping = false
	mode = RigidBody.MODE_RIGID
	if !reset_time:
		return
	yield(get_tree().create_timer(reset_time), "timeout")
	if !falling:
		return
	visual_reset()

func _on_player_died():
	reset()

func reset():
	can_sleep = true
	mode = RigidBody.MODE_KINEMATIC
	global_transform = starting_position
	falling = false

func visual_reset():
	$AnimationPlayer.play("vis_reset")
