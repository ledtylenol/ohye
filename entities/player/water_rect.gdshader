shader_type canvas_item;

uniform sampler2D displace_noise1: repeat_enable;
uniform sampler2D displace_noise2: repeat_enable;
uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;

uniform sampler2D dissolve_noise1: repeat_enable;
uniform sampler2D dissolve_noise2: repeat_enable;

uniform float offset = 0.02;
uniform sampler2D color_gradient;
instance uniform float time = 0.0;
uniform float alpha = 0.0;
uniform float intensity = 0.1;
uniform vec2 dp_noise1_push;
uniform vec2 dp_noise2_push;
uniform vec2 noise1_push;
uniform vec2 noise2_push;
uniform vec2 dissolve_noise1_push;
uniform vec2 dissolve_noise2_push;
uniform sampler2D screen: hint_screen_texture, repeat_enable;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 push1 = texture(displace_noise1, UV + time * dp_noise1_push).rg * 2.0 - 1.0;
	vec2 push2 = texture(displace_noise2, UV + time * dp_noise2_push).rg * 2.0 - 1.0;
	vec2 push = push1 + push2;
	float p = texture(noise1, UV + time * noise1_push).r;
	float p2 = texture(noise2, UV + time * noise2_push).r;
	p *= p2;
	
	float d1 = texture(dissolve_noise1, UV + time * dissolve_noise1_push).r;
	float d2 = texture(dissolve_noise2, UV + time * dissolve_noise2_push).r;
	d1 *= d2;
	vec3 sc = texture(screen, SCREEN_UV + push * p * intensity).rgb;
	vec4 col = texture(color_gradient, vec2(p));
	COLOR.rgb = mix(sc, col.rgb, p * col.a);
	float a = 1.0 - alpha;
	COLOR.a = smoothstep(a, a+offset, d1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
