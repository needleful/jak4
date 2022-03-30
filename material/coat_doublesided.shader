shader_type spatial;
render_mode cull_disabled;

uniform sampler2D palette: hint_albedo;
uniform sampler2D gradient;
uniform float light_bias: hint_range(-1, 1);
uniform float softness: hint_range(0, 1) = 1.0;
uniform float specularity: hint_range(1, 16) = 1.0;

void fragment()
{
	float t = texture(palette, UV).r;
	ALBEDO = texture(gradient, vec2(t, 0)).rgb;
	ROUGHNESS = clamp(2.0/specularity, 0, 1);
}

void light()
{
	float light = smoothstep(0, softness, dot(NORMAL, LIGHT) + light_bias);
	DIFFUSE_LIGHT += light * ATTENUATION * ALBEDO;
	
	// Specular
	vec3 h = normalize(VIEW + LIGHT);
	float cNdotH = max(0.0, dot(NORMAL, h));
	float blinn = pow(cNdotH, specularity);
	blinn *= (specularity + 2.0) / (8.0*3.1416);
	float intensity = blinn; 
	DIFFUSE_LIGHT += LIGHT_COLOR * intensity * ATTENUATION * ALBEDO;
}
