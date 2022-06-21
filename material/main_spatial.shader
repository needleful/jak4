shader_type spatial;

uniform sampler2D main_texture: hint_albedo;
uniform float light_bias: hint_range(-1, 1);
uniform float softness: hint_range(0, 1) = 1.0;
uniform float specularity: hint_range(1, 16) = 1.0;

void fragment()
{
	vec4 t = texture(main_texture, UV);
	ALBEDO = mix(COLOR.rgb, t.rgb, t.a);
	ROUGHNESS = clamp(2.0/specularity, 0, 1);
}

void light()
{
	// negative. Use as ambient shadow
	if(LIGHT_COLOR.r < 0.0 || LIGHT_COLOR.g < 0.0 || LIGHT_COLOR.b < 0.0) {
		DIFFUSE_LIGHT += LIGHT_COLOR*ATTENUATION*ALBEDO;
	}
	else {
		float smoothness = (specularity + 2.0) / (8.0*3.1416);
		
		float light = 0.5*(1.0-smoothness)*smoothstep(0, softness, dot(NORMAL, LIGHT) + light_bias);
		DIFFUSE_LIGHT += light * LIGHT_COLOR * ATTENUATION * ALBEDO;
		
		// Specular
		vec3 h = normalize(VIEW + LIGHT);
		float cNdotH = max(0.0, dot(NORMAL, h));
		float blinn = 0.5*smoothness*pow(cNdotH, specularity);
		float intensity = blinn; 
		DIFFUSE_LIGHT += intensity * LIGHT_COLOR * ATTENUATION * ALBEDO;
	}
}
