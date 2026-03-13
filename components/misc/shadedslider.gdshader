shader_type canvas_item;

uniform sampler2D screen: hint_screen_texture;
uniform sampler2D noise: repeat_enable;

uniform sampler2D gradient;
instance uniform float heat;
instance uniform float time;
uniform vec2 offset_speed = vec2(0.1, 0.0);
uniform vec2 uv_scale = vec2(0.1, 10.0);
uniform float quant_factor = 10.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uvpush = step(0.5, COLOR.r) * vec2(time) * offset_speed;
	uvpush = round(uvpush * quant_factor) / quant_factor;
	COLOR.a *= step(0.5, COLOR.r);
	vec2 uvquant = round(SCREEN_UV * quant_factor) / quant_factor;
	vec4 n = texture(noise, uv_scale * uvquant + uvpush);
	vec3 col = texture(gradient, vec2(heat)).rgb;
	COLOR.rgb = n.rgb * col;
	COLOR.a *= n.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
