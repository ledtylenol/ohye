shader_type canvas_item;

uniform float base;
uniform float step_th;

uniform sampler2D noise;
uniform sampler2D SCREEN_TEX: hint_screen_texture;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(TEXTURE, (1.0 - UV) * 2.0 - 1.0 + vec2(TIME * 0.01, sin(TIME * 0.1) * 10.0));
	COLOR.rgb = tex.rgb;
	COLOR.a = smoothstep(tex.r, base, base + step_th);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
