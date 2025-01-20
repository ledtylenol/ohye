shader_type canvas_item;

uniform sampler2D screen: hint_screen_texture;
uniform float time;
uniform float magnitude = 1.0;
void fragment() {
    vec2 uv = UV + sin(max(UV.x, UV.y) * 10.0 + time) * magnitude
	+ cos (max(UV.x, UV.y) * 10.0 + time * 0.885) * magnitude;
	COLOR.rgb = texture(screen, uv).rgb;
	//COLOR *= effect(TEXTURE_PIXEL_SIZE, uv);
}