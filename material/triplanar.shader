shader_type spatial;
render_mode cull_back, depth_draw_opaque;

uniform sampler2D wall: hint_albedo;
uniform sampler2D ground: hint_albedo;
uniform sampler2D ceiling: hint_albedo;
uniform float uv_scale = 0.125;
uniform float power = 5.0;

varying vec3 position;
varying vec3 normal;

void vertex() {
	position = (WORLD_MATRIX*vec4(VERTEX, 1.0)).xyz;
	normal = normalize((WORLD_MATRIX*vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec4 color_x = texture(wall, position.zy*uv_scale);
	vec4 color_z = texture(wall, position.xy*uv_scale);
	vec4 color_y_up = texture(ground, position.xz*uv_scale);
	vec4 color_y_down = texture(ceiling, position.xz*uv_scale);
	vec4 color_y = mix(color_y_down, color_y_up, 0.5*normal.y + 0.5);
	
	vec4 color_wall = mix(color_z, color_x, abs(normal.x));
	ALBEDO = mix(color_wall, color_y, pow(abs(normal.y), power)).rgb;
}