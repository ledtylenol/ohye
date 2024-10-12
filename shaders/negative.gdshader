shader_type canvas_item;

uniform float alpha: hint_range(0.0, 1.0, 0.1);
uniform bool use_alpha = true;
uniform sampler2D screen: hint_screen_texture;
void fragment() {
	vec4 c = texture(screen, SCREEN_UV);

	if (use_alpha) {
		COLOR.a = alpha;
		COLOR.rgb = 1.0 - c.rgb;
	}
	else {
		COLOR.r *= sin(TIME);
		COLOR.g *= sin(TIME + 2.0);
		COLOR.b *= cos(TIME + 1.2);
		COLOR.rgb = ((1.0 - c.rgb) + (1.0 - COLOR.rgb)) / 2.0;
		COLOR.a *= alpha;
	}
}
