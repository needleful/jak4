extends ImmediateGeometry

export(int, 2, 1024) var segments := 16.0
export(float) var length := 1.0
export(float) var width := 0.03
export(Vector3) var starting_velocity := Vector3.ZERO
export(Vector3) var random_velocity := Vector3.ZERO
export(Gradient) var color: Gradient

var position: PoolVector3Array = []
var velocity: PoolVector3Array = []

func _process(delta):
	if position.size() == 0:
		add_point()
		add_point()
	var d := position[0] - position[1]
	var max_d := length*length/(segments*segments)
	if d.length_squared() > max_d:
		add_point()
	
	for i in position.size():
		position[i] += velocity[i]*delta
	
	var c_pos := get_viewport().get_camera().global_transform.origin
	
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in position.size() - 1:
		var g_pos := global_transform*position[i]
		var g_next := global_transform*position[i+1]
		var dir := g_next - g_pos
		var cam_dir := (c_pos - g_pos)
		var third = dir.cross(cam_dir).normalized()*width*(segments-i)/segments
		var point3 = global_transform.xform_inv(g_pos + third)
		var point4 = global_transform.xform_inv(g_next + third)
		
		add_vertex(position[i])
		add_vertex(position[i+1])
		add_vertex(point3)
		
		add_vertex(point3)
		add_vertex(position[i+1])
		add_vertex(point4)
	end()

func add_point():
	while position.size() > segments:
		position.remove(position.size() - 1)
		velocity.remove(velocity.size() - 1)
		velocity[velocity.size() - 1] *= 0.1
		velocity[velocity.size() - 2] = position[position.size() - 1] - position[position.size() - 2]
	if velocity.size() > 0:
		velocity[0] = starting_velocity + 2*random_velocity*Vector3(
				randf(), randf(), randf()
			) - random_velocity
	position.insert(0, Vector3.ZERO)
	velocity.insert(0, Vector3.ZERO)
