shader_type canvas_item;

uniform float thres: hint_range(0.0, 1.0, 0.01);
uniform float thres2: hint_range(0.0, 1.0, 0.01);
uniform float thres_offset: hint_range(0.0, 1.0, 0.01);
uniform float thres_offset2: hint_range(0.0, 1.0, 0.01);
uniform float linear_offset: hint_range(0.0, 1.0, 0.01);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float sz= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	float dist = 1.0 - distance(vec2(UV.x , UV.y * sz), vec2(0.5, 0.5 * sz ) );
	float step1 = smoothstep(thres - linear_offset, thres- linear_offset + thres_offset, dist);
	float step2 = (1.0 - smoothstep(1.0 - thres2 - linear_offset, 1.0 - thres2 - linear_offset + thres_offset2, dist));
	COLOR.rgb = vec3(step1 * step2);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
