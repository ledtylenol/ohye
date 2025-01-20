shader_type spatial;

uniform float q = 5.;
uniform sampler2D text: hint_screen_texture;
void vertex() {
	// Called for every vertex the material is visible on.
}
vec3 rot(vec3 v,float anglex, float angley) {
	mat3 mx = mat3(vec3(1., 0., 0.),
			  vec3(0., cos(anglex), -sin(anglex)),
			  vec3(0., sin(anglex), cos(anglex)));
	mat3 my = mat3(
				    vec3(cos(angley), 0.0, sin(angley)),
				    vec3(0.0, 1.0, 0.0),
				    vec3(-sin(angley), 0.0, cos(angley)));
	return mx * my * v;
}
void fragment() {
	float t = round(TIME * q) / q;
	vec3 n = rot(NORMAL, t, -t / 2.);
	vec3 nn = rot(NORMAL, TIME, -TIME / 2.);
	ALBEDO = ALBEDO * n;
	NORMAL = n;
	vec4 sc_c = texture(text, SCREEN_UV + sin(t));
	ALPHA =dot(NORMAL, VERTEX);
	ALBEDO = mix(sc_c.rgb, ALBEDO, 1.0 - ALPHA);
	EMISSION = rot(ALBEDO * nn, TIME / 1.5, 0.) * 3. * rot(TANGENT, TIME / 5., -TIME / 6.);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
