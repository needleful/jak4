shader_type spatial;
render_mode unshaded;

uniform sampler2D hologram: hint_albedo; 

uniform float realness: hint_range(0, 1) = 0.5;
uniform float hologram_uv_scale = 25.0;
uniform vec4 hologram_emission : hint_color;

varying vec3 vert_color;

void fragment()
{
	vec4 h = texture(hologram, UV*hologram_uv_scale);
	ALBEDO = hologram_emission.rgb;
	
	if (h.a < 1.0 - realness) {
		discard;
	}
	vert_color = COLOR.rgb;
}