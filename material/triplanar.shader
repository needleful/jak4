shader_type spatial;
render_mode cull_back, depth_draw_opaque, world_vertex_coords, async_hidden;


uniform sampler2D wall: hint_albedo;
uniform sampler2D ground: hint_albedo;
uniform sampler2D ceiling: hint_albedo;
uniform float uv_scale = 0.125;
uniform float power = 5.0;
uniform float softness = 0.5;
uniform float specularity_ground = 1.0;
uniform float specularity_wall = 1.0;
uniform float specularity_ceiling = 1.0;
uniform float light_bias = 0.0;

varying vec3 position;
varying vec3 normal;
varying float specularity;

void vertex() {
	position = VERTEX.xyz;
	normal = NORMAL;
}

void fragment() {
	vec3 n = normalize(normal);
	vec4 color_x = texture(wall, position.zy*uv_scale);
	vec4 color_z = texture(wall, position.xy*uv_scale);
	vec4 color_y_up = texture(ground, position.xz*uv_scale);
	vec4 color_y_down = texture(ceiling, position.xz*uv_scale);
	
	float y_pow = sign(n.y)*pow(abs(n.y), power);
	
	vec4 color =
		color_x*abs(n.x) 
		+ color_z*abs(n.z)
		+ color_y_up*max(y_pow, 0.0)
		+ color_y_down*max(-y_pow, 0.0);
	specularity = 
		specularity_wall*(abs(n.z) + abs(n.x))
		+ specularity_ground*max(y_pow, 0.0)
		+ specularity_ceiling*max(-y_pow, 0.0);
	ALBEDO = clamp(color.rgb, vec3(0.0), vec3(1.0));
	ROUGHNESS = clamp(2.0/(specularity + 0.01), 0, 1);
}

void light()
{
	// negative. Use as ambient shadow
	if(LIGHT_COLOR.r < 0.0 || LIGHT_COLOR.g < 0.0 || LIGHT_COLOR.b < 0.0) {
		DIFFUSE_LIGHT += (DIFFUSE_LIGHT + AMBIENT_LIGHT*ALBEDO)*LIGHT_COLOR*ATTENUATION;
	}
	else {
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
}
