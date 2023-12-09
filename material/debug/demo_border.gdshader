shader_type spatial;
render_mode cull_disabled, unshaded, blend_add;

uniform vec4 albedo: hint_color;
uniform float max_distance: hint_range(0.1, 500.0, 0.1);
uniform float power: hint_range(0.1, 3.0, 0.1) = 1.0;
varying vec3 pos;
void vertex(){
	pos = VERTEX;
}
void fragment() {
	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0).r;
	vec3 ndcoord = vec3(SCREEN_UV * 2.0 - 1.0, depth*2.0 - 1.0);
	
	vec4 viewpos = INV_PROJECTION_MATRIX * vec4(ndcoord, 1.0);
	viewpos.xyz /= viewpos.w;
	float viewdepth = -viewpos.z;
	
	float diffy = abs(viewdepth - pos.z);
	float strength = pow(clamp((max_distance - diffy)/max_distance, 0, 1), power);
	ALBEDO = strength*albedo.rgb;
}