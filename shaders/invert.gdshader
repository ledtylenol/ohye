shader_type canvas_item;

uniform sampler2D screen: hint_screen_texture;

void fragment() {
	vec4 s_c = texture(screen, SCREEN_UV);
	COLOR.rgb = 1.0 - s_c.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
