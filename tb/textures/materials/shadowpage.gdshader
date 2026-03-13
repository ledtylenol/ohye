shader_type spatial;

uniform sampler2D noise: repeat_enable, filter_nearest_mipmap;
uniform float threshold: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform vec2 time_scale = vec2(0.1);
uniform vec2 scale = vec2(0.1);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 c = texture(noise, vec2(UV.x, UV.y) * scale + TIME * time_scale).rgb;
	
	if (c.r + c.g + c.b < threshold * 3.0) discard;
	ALBEDO.rgb = c;
	float d = length(UV);
	ALPHA = smoothstep(1.5, 0.4, d);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
