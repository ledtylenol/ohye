shader_type canvas_item;

uniform sampler2D SCREEN_TEX: hint_screen_texture;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	vec3 sc_col = texture(SCREEN_TEX, SCREEN_UV).rgb;
	if (col.a == 0.0) discard;
	float l1 = length(sc_col - col.rgb);
	float l2 = length(col.rgb - sc_col);
	if (l1 > l2) 
		COLOR.rgb = sc_col - col.rgb;
	else
		COLOR.rgb = col.rgb - sc_col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
