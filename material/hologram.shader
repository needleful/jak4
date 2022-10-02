shader_type spatial;
render_mode cull_back, blend_add, unshaded;

uniform sampler2D main_texture;
uniform float normal_deformation :hint_range(0, 10) = 0.1;
varying vec2 uv_deform;

void vertex() {
	float normal_deform = sin(0.7*TIME + 5.13*VERTEX.x*VERTEX.z) + sin(1.2*TIME + 2.3*(VERTEX.y));
	VERTEX += NORMAL*normal_deformation*normal_deform;
	uv_deform = 0.5*vec2(
		sin(0.2*TIME + 0.1*VERTEX.y),
		cos(0.5*TIME + 0.3*(VERTEX.x*VERTEX.z + VERTEX.y)));
}

void fragment() {
	ALBEDO = texture(main_texture, UV+uv_deform).rgb;
}