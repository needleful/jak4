shader_type spatial;
render_mode cull_back, depth_draw_opaque, world_vertex_coords, async_hidden;


uniform sampler2D wall: hint_albedo;
uniform sampler2D ground: hint_albedo;
uniform sampler2D ceiling: hint_albedo;
uniform float uv_scale = 0.125;
uniform float power = 5.0;

varying vec3 position;
varying vec3 normal;

void vertex() {
	position = VERTEX.xyz;
	normal = NORMAL;
	//normal /= dot(normal, vec3(1.0));
}

void fragment() {
	vec4 color_x = texture(wall, position.zy*uv_scale);
	vec4 color_z = texture(wall, position.xy*uv_scale);
	vec4 color_y_up = texture(ground, position.xz*uv_scale);
	vec4 color_y_down = texture(ceiling, position.xz*uv_scale);
	
	float y_pow = sign(normal.y)*pow(abs(normal.y), power);
	
	vec4 color =
		color_x*abs(normal.x) 
		+ color_z*abs(normal.z)
		+ color_y_up*max(y_pow, 0.0)
		+ color_y_down*max(-y_pow, 0.0);
	ALBEDO = clamp(color.rgb, vec3(0.0), vec3(1.0));
}