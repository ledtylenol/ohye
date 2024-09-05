shader_type canvas_item;

uniform float alpha: hint_range(0.0, 1.0, 0.1);
uniform sampler2D screen: hint_screen_texture;
void fragment() {
	vec4 c = texture(screen, SCREEN_UV);
	COLOR.rgb = 1.0 - c.rgb;
	COLOR.a = alpha;
}
