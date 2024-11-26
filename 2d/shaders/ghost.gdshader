shader_type canvas_item;
varying vec2 world_pos;
varying vec2 v_pos;
uniform float alpha: hint_range(0.0, 1.0, 0.1);
uniform float time = 1.0;
uniform float deformation_amount = 100.0;
void vertex() {

	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 0.0)).xy;
	float outp = (1.0 + sin(time + world_pos.y - exp(world_pos.x)));
	VERTEX.x *= deformation_amount * floor(outp * 3.0) / 3.0;
	VERTEX.y *= deformation_amount * floor(cos(outp) * 3.0) / 3.0;
	v_pos = VERTEX;
}

void fragment() {

	COLOR.a *= alpha;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
