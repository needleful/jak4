shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform float refraction : hint_range(-5,5);
uniform float brightness : hint_range(0, 2);

void fragment() {
	ALBEDO = albedo.rgb;
	SPECULAR = 1.0;
	METALLIC = 1.0;
	ROUGHNESS = 0.0;
	vec3 ref_normal = NORMAL;
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction;
	float ref_amount = 1.0;
	EMISSION = texture(SCREEN_TEXTURE, ref_ofs).rgb * ALBEDO;
	TRANSMISSION = EMISSION;
	ALBEDO *= brightness;
}
