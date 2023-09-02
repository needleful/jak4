shader_type spatial;
render_mode unshaded, depth_draw_never, blend_add, cull_disabled;

uniform sampler2D mask;
uniform float strength: hint_range(0.0, 3.0, 0.1);


void fragment() {
	vec3 t = texture(mask, UV).rgb;
	ALBEDO = t*t*COLOR.rgb*strength;
}