shader_type canvas_item;
uniform sampler2D distort_curve;
uniform sampler2D threshold_curve;
uniform sampler2D screen;
uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D noise: repeat_enable;
uniform sampler2D thres_noise: repeat_enable;

instance uniform bool use_screen = false;
instance uniform float threshold: hint_range(0.0, 1.0, 0.01);
instance uniform float offset: hint_range(0.0, 1.0, 0.01);
instance uniform float noise_intensity: hint_range(0.0, 10.0, 0.01);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 rad_uv = UV - 0.5;
	vec3 screen_tex = texture(screen_texture, SCREEN_UV).rgb;
	float screen_avg = screen_tex.r + screen_tex.g + screen_tex.b;
	screen_avg /= 3.0;
	float thr = texture(threshold_curve, vec2(threshold)).r;
	float d_curve = texture(distort_curve, vec2(threshold)).r;

	vec3 n = texture(noise, SCREEN_UV).rgb;
	float thr_n = texture(thres_noise, SCREEN_UV).r;
	vec3 sc;
	if (!use_screen) {
		sc = texture(screen, SCREEN_UV + (n.rg * 2.0 - 1.0)  * noise_intensity * d_curve).rgb;
	}
	else {
		sc = texture(screen_texture, SCREEN_UV + (n.rg * 2.0 - 1.0)  * noise_intensity * d_curve).rgb;
	}
	COLOR.rgb = sc;
	COLOR.a = smoothstep(thr, thr + offset, thr_n);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
