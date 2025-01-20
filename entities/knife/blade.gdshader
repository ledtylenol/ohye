shader_type spatial;
varying vec3 norm;
void vertex() {
	norm = NORMAL;
}

void fragment() {
	ALBEDO  = norm;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
