shader_type spatial;
render_mode cull_disabled, world_vertex_coords;

uniform sampler2D main_texture: hint_albedo;
uniform vec4 subsurface_color: hint_color;
uniform float softness: hint_range(0, 1) = 1.0;
uniform float specularity: hint_range(0.0, 32) = 1.0;
uniform float movement_amount : hint_range(0.001, 2.0) = 0.4;
uniform float speed : hint_range(0.01, 10.0) = 1.4;
uniform float x_variation : hint_range(1.0, 40.0) = 5.0;
uniform float z_variation : hint_range(1.0, 40.0) = 5.0;

void vertex() {
	float t = TIME*speed + VERTEX.x/x_variation + sin(VERTEX.z/z_variation);
	float move = COLOR.r*movement_amount;
	VERTEX.xz += move*vec2(sin(t), cos(t));
}

void fragment()
{
	vec4 tex = texture(main_texture, UV);
	ALBEDO = tex.rgb;
	ROUGHNESS = 1.0;
}

void light()
{
	// negative. Use as ambient shadow
	if(LIGHT_COLOR.r < 0.0 || LIGHT_COLOR.g < 0.0 || LIGHT_COLOR.b < 0.0) {
		DIFFUSE_LIGHT += (DIFFUSE_LIGHT + AMBIENT_LIGHT*ALBEDO)*LIGHT_COLOR*ATTENUATION;
	}
	else {
		float smoothness = specularity/32.0;
		
		float ndotl = dot(NORMAL, LIGHT);
		float light = 0.4*(1.0-smoothness)*smoothstep(0, softness, ndotl);
		vec3 diffuse = light * LIGHT_COLOR * ATTENUATION * ALBEDO;
		
		// Specular
		vec3 h = normalize(VIEW + LIGHT);
		float cNdotH = max(0.0, dot(NORMAL, h));
		float blinn = 0.4*smoothness*pow(cNdotH, specularity);
		float intensity = blinn;
		vec3 specular = intensity * LIGHT_COLOR * ATTENUATION * ALBEDO;
		
		float subsurface_scattering = 2.0*subsurface_color.a - 1.0;
		// subsurface
		vec3 subsurface = 0.2*ATTENUATION*LIGHT_COLOR*subsurface_color.rgb*clamp(ndotl + subsurface_scattering, 0, 1);
		DIFFUSE_LIGHT += specular + diffuse + subsurface;
	}
}
