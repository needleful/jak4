extends SpringArm

export(NodePath) var laser_geometry = NodePath("../laser_geometry")
onready var lgeo: ImmediateGeometry = get_node(laser_geometry)

func update():
	var l = get_hit_length()
	if l < spring_length:
		for c in get_children():
			c.show()
		#var normal = get_hit_normal()
		#var y = laser_end.global_transform.basis.y
		#var m_axis = y.cross(normal).normalized()
		#if m_axis.is_normalized():
		#	var m_angle = y.angle_to(normal)
		#	laser_end.global_rotate(m_axis, m_angle)
	else:
		for c in get_children():
			c.hide()
	lgeo.clear()
	lgeo.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	lgeo.add_vertex(Vector3(0.012, 0.01, 0.0))
	lgeo.add_vertex(Vector3(0.01, 0.01, l))
	lgeo.add_vertex(Vector3(0.012, -0.01, 0.0))
	lgeo.add_vertex(Vector3(0.01, -0.01, l))
	lgeo.add_vertex(Vector3(-0.012, 0.01, 0.0))
	lgeo.add_vertex(Vector3(-0.01, 0.01, l))
	lgeo.end()
