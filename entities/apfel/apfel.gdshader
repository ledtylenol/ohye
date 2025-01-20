shader_type spatial;

uniform float normal_infl: hint_range(0.0, 1.0, 0.1);
uniform float tan_infl: hint_range(0.0, 1.0, 0.1);
uniform float bi_infl: hint_range(0.0, 1.0, 0.1);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 n = NORMAL * normal_infl;
	vec3 t = TANGENT * tan_infl;
	vec3 bi = BINORMAL * bi_infl;
	ALBEDO = n + t * bi;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
