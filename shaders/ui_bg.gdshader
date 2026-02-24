shader_type canvas_item;

uniform int quantize : hint_range(1, 64) = 8;
uniform float uv_quant : hint_range(1, 64) = 10;
uniform float quantize_mix: hint_range(0.0, 1.0) = 0.0;
uniform float spread : hint_range(0.0, 1.0) = 0.125;
uniform sampler2D screen: hint_screen_texture, filter_nearest;
uniform float time;
uniform float magnitude = 1.0;
void fragment() {
	vec2 q_uv = round(UV * uv_quant) / uv_quant;
	float sins = sin(max(q_uv.x, q_uv.y) * 10.0 + time) * magnitude;
	float coss = cos (max(q_uv.x, q_uv.y) * 10.0 + time * 0.885) * magnitude;
	float sins2 = sin(max(UV.x, UV.y) * 10.0 + time) * magnitude;
	float coss2 = cos (max(UV.x, UV.y) * 10.0 + time * 0.885) * magnitude;
    vec2 uv = UV + sins + coss + sins2 + coss2;
	    mat4 bayer = mat4(
        vec4(0, 8, 2, 10),
        vec4(12, 4, 14, 6),
        vec4(3, 11, 1, 9),
        vec4(15, 7, 13, 5)
    );
    
    vec4 sc_c = texture(screen, uv);
	COLOR = texture(screen, uv);
    float offset = bayer[int(FRAGCOORD.x) % 4][int(FRAGCOORD.y) % 4] / 16.0 - 0.5;
    COLOR += (spread * offset);
    // Quantize
    COLOR = mix(sc_c, floor(COLOR * float(quantize - 1) + 0.5) / float(quantize - 1), quantize_mix);
	//COLOR *= effect(TEXTURE_PIXEL_SIZE, uv);
}