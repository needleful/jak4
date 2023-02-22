extends Spatial

export(NodePath) var target_node
export(float, 0.01, 1.0, 0.01) var max_distance := 0.02
export(float, 0.00, 1.00, 0.001) var damp := 0.2

const max_rel_velocity := 0.0

onready var target := get_node(target_node)
onready var player := Global.get_player()

var velocity := Vector3.ZERO
var player_vel := Vector3.ZERO
var max_velocity := 30.0

func _ready():
	global_transform = target.global_transform

func _physics_process(delta):
	var md2 := max_distance*max_distance
	var rel:Vector3 = target.global_transform.origin - global_transform.origin
	var d:float = rel.length_squared()
	
	var added_velocity := rel*md2/(clamp(md2 - d, 0.00005, md2))
	velocity += added_velocity
	if velocity.length_squared() > max_velocity*max_velocity:
		velocity = velocity.normalized()*max_velocity
	player_vel = lerp(player_vel, player.velocity, 0.2)
	
	global_transform.origin += (0.9*player_vel + velocity)*delta
	velocity *= 1.0 - damp
	
	var t :Vector3 = global_transform.origin - target.global_transform.origin
	if t.length_squared() > md2:
		var newt = t.normalized()*max_distance
		global_transform.origin = target.global_transform.origin + newt

