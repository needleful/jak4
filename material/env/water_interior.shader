shader_type spatial;
render_mode world_vertex_coords, cull_disabled, depth_test_disable;

stencil front {
	value 0;
	test greater;
}

uniform vec4 surface_albedo : hint_color;
uniform vec4 deep_albedo : hint_color;
uniform float max_depth : hint_range(0.1, 10.0);
uniform float refraction : hint_range(-1,1) = 0.004;
varying vec3 pos;

void vertex() {
	pos = VERTEX;
}

void fragment() {
	vec3 ref_normal = NORMAL;
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction;
	float ref_amount = 1.0;
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	vec4 color = texture(SCREEN_TEXTURE, ref_ofs);
	
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
	vec4 wpos = CAMERA_MATRIX*upos;
	vec3 pixel_position = wpos.xyz / wpos.w;
	
	float diffy = pos.y - pixel_position.y;
	float amount = clamp(diffy/max_depth, 0, 1);
	EMISSION = mix(color * surface_albedo, deep_albedo, amount).rgb;
	
	ALBEDO = vec3(0);
	SPECULAR = 0.0;
	METALLIC = 0.0;
	ROUGHNESS = 1.0;
	TRANSMISSION = EMISSION;
}

void light()
{
	// negative. Use as ambient shadow
	if(LIGHT_COLOR.r < 0.0 || LIGHT_COLOR.g < 0.0 || LIGHT_COLOR.b < 0.0) {
		DIFFUSE_LIGHT += (DIFFUSE_LIGHT + AMBIENT_LIGHT*ALBEDO)*LIGHT_COLOR*ATTENUATION;
	}
	else {
		float light = dot(NORMAL, LIGHT);
		DIFFUSE_LIGHT += light * ATTENUATION * ALBEDO;
		
		// Specular
		vec3 h = normalize(VIEW + LIGHT);
		float cNdotH = max(0.0, dot(NORMAL, h));
		float blinn = pow(cNdotH, (1.0/(ROUGHNESS + 0.01)));
		DIFFUSE_LIGHT += LIGHT_COLOR * blinn * ATTENUATION * ALBEDO;
	}
}
