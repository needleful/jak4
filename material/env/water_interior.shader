shader_type spatial;
render_mode world_vertex_coords, cull_front, depth_test_disable, unshaded, blend_mul;

stencil {
	value 0;
	test equal;
}

uniform vec4 surface_albedo : hint_color;
uniform vec4 deep_albedo : hint_color;
uniform float max_depth : hint_range(0.1, 10.0);

void fragment() {
	ALBEDO = surface_albedo.rgb;
}