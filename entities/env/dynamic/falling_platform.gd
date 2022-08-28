extends RigidBody

export(float, 0, 10) var delay := 1.0
export(Vector3) var random_movement := Vector3(0.2, 0.2, 0.2)
export(float) var max_random_speed := 2.0

var falling := false
onready var starting_position := global_transform

func _ready():
	var p = Global.get_player()
	if p is PlayerBody:
		p.connect("died", self, "_on_player_died")

func _physics_process(delta):
	if !falling:
		var target := starting_position.origin + random_movement*Vector3(randf(), randf(), randf()) - random_movement
		var vel = target - global_transform.origin
		global_translate(max_random_speed*vel*delta)

func _on_body_entered(_body):
	if !falling:
		print("falling!")
		falling = true
		$Timer.start(delay)

func _on_timeout():
	mode = RigidBody.MODE_RIGID

func _on_player_died():
	mode = RigidBody.MODE_KINEMATIC
	global_transform = starting_position
	falling = false
