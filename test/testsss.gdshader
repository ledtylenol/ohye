shader_type spatial;

uniform sampler2D tex;
uniform sampler2D noise;
uniform float t: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float x_off = 0.0;
uniform float col_off = 0.0;
uniform vec4 col: source_color;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 text = texture(tex, UV);
	ALBEDO = text.rgb;
	ALPHA = text.a;
	float a = texture(noise, UV).r;
	float s = smoothstep(t, t+ x_off * t, a);
	float s2 = smoothstep(t, t+ col_off * t, a);
	ALPHA *= s;
	ALBEDO = mix(ALBEDO, col.rgb, 1.0 - s2);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
