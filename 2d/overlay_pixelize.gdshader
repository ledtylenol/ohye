shader_type canvas_item;

uniform sampler2D overlay_tex: repeat_enable, filter_nearest;

uniform float scale = 0.00694444;
uniform float quant_factor = 10.0;
uniform float shift_speed = 2.0;
varying vec2 world_pos;
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float q = quant_factor;
	float mix_amount = floor(COLOR.r + 0.5);
	vec2 world_pos_quant = world_pos;
	world_pos_quant += sin(TIME);
	world_pos_quant = floor(world_pos_quant * q) / q;
	vec4 overlay_col = texture(overlay_tex, world_pos_quant * scale);
	COLOR = mix(COLOR, overlay_col, mix_amount);
}
