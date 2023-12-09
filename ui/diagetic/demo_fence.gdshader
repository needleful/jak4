shader_type spatial;
render_mode blend_add,cull_disabled,unshaded,world_vertex_coords;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;

uniform vec3 world_player;
uniform float min_distance = 2.0;
uniform float max_distance = 5.0;

varying vec3 pos;

void vertex() {
	pos = VERTEX;
}

void fragment() {
	float d = length(world_player - pos);
	float offset = clamp((d-min_distance)/(max_distance-min_distance), 0, 1);
	
	float brightness = clamp(texture(texture_albedo,UV).r - offset, 0, 1);
	ALBEDO = albedo.rgb * brightness;
}
