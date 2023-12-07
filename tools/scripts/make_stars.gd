tool
extends EditorScript

var gradient: Gradient = load("res://material/sky/star_gradient.tres")
const star_count := 45000
const min_distance := 10000
const distance_range := 400
const min_scale := 100.0
const max_scale := 800.0

func _run():
	var star_mesh = get_scene().get_node("stars") as MultiMeshInstance
	if !star_mesh:
		return
	
	var m:MultiMesh = star_mesh.multimesh
	m.instance_count = star_count
	m.visible_instance_count = star_count
	
	for i in star_count:
		var scale := pow(randf(), 5)
		var transform := Transform()
		
		var r := rand_range(min_distance, min_distance + distance_range)
		var to := 1-2*randf()
		var theta := (PI if randf() > 0.5 else 0.0) + PI*(sign(to)*pow(abs(to), 1.4))
		var phi := acos(1 - 2 * randf())
		
		var t = Vector3(
			sin(phi) * cos(theta),
			sin(phi) * sin(theta),
			cos(phi) )
		
		transform = transform.looking_at(-t, Vector3.UP).scaled(
			lerp(min_scale, max_scale, scale)
			* Vector3(1,1,1))
		transform.origin = r*t
		m.set_instance_transform(i, transform)
		var brightness := pow(randf(), 3)
		var c: Color = gradient.interpolate(randf())
		c.a = (0.1 + brightness)
		m.set_instance_color(i, c)
		m.visible_instance_count += 1

func sqrtf(v: float):
	return sqrt(v)
