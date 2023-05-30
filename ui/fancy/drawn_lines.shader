shader_type canvas_item;

uniform sampler2D gradient;
uniform float value: hint_range(0.0, 1.1, 0.01);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if(value <= tex.r) {
		discard;
	}
	else {
		COLOR = vec4(texture(gradient, vec2(tex.g, 0)).rgb, tex.a);
	}
}