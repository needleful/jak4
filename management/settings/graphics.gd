extends Node

export(bool) var bloom := true setget set_bloom, get_bloom
export(bool) var high_quality_shadows := true setget set_hq_shadows, get_hq_shadows
export(float, 0.1, 2.0) var render_distance := 1.0 setget set_render_distance
export(bool) var render_distant_objects := true setget set_far_render

func get_name():
	return "Graphics"

func set_bloom(b):
	bloom = b
	if is_inside_tree() and get_tree().current_scene.has_node("WorldEnvironment"):
		var we: WorldEnvironment = get_tree().current_scene.get_node("WorldEnvironment")
		we.environment.glow_enabled = bloom

func get_bloom():
	if is_inside_tree() and get_tree().current_scene.has_node("WorldEnvironment"):
		var we: WorldEnvironment = get_tree().current_scene.get_node("WorldEnvironment")
		return we.environment.glow_enabled
	else:
		return bloom

func set_hq_shadows(hq):
	high_quality_shadows = hq
	if high_quality_shadows: 
		ProjectSettings["rendering/quality/directional_shadow/size"] = 8192
		ProjectSettings["rendering/quality/directional_shadow/size"] = 4096
	else:
		ProjectSettings["rendering/quality/directional_shadow/size"] = 2048
		ProjectSettings["rendering/quality/directional_shadow/size"] = 1024

func get_hq_shadows():
	return high_quality_shadows

func set_render_distance(d):
	render_distance = d
	if is_inside_tree():
		Global.render_distance = render_distance
	if "default_far_plane" in get_viewport().get_camera():
		var cam := get_viewport().get_camera()
		cam.far = Global.render_distance*cam.default_far_plane

func set_far_render(far):
	render_distant_objects = far
	Global.show_lowres = render_distant_objects
