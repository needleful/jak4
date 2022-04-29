shader_type spatial;
render_mode cull_back, blend_add, unshaded;

uniform sampler2D main_texture;
varying vec2 uv_deform;

void vertex() {
	uv_deform = 0.5*vec2(
		sin(0.2*TIME + 0.1*VERTEX.y),
		cos(0.5*TIME + 0.3*(VERTEX.x*VERTEX.z + VERTEX.y)));
}

void fragment() {
	ALBEDO = texture(main_texture, UV+uv_deform).rgb;
}