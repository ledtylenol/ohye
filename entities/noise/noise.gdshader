shader_type spatial;
render_mode world_vertex_coords, alpha_to_coverage;

instance uniform float time;
instance uniform float real_time;
uniform float quant_factor = 10.0;
uniform float vert_power: hint_range(0.0, 1.0, 0.1);
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}
void vertex() {
	vec2 constructed = vec2(VERTEX.x + VERTEX.y - VERTEX.z, VERTEX.z - VERTEX.x - VERTEX.y);
	vec2 round_vert = round(constructed * 10.0) / 10.0;
	VERTEX.xz += vert_power *(rand(round_vert + time) - 0.5);
}

void fragment() {
	vec2 round_uv = round(UV * quant_factor) / quant_factor;
	vec3 rv = vec3(rand(round_uv + real_time / 10.0));
	ALBEDO.rgb = rv;
	ALPHA = rv.r * 2.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
