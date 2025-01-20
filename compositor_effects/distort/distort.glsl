#[compute]
#version 450

// Invocations in the (x, y, z) dimension.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 1, binding = 0) uniform sampler2D linear_sampler;
layout(set = 1, binding = 1) uniform sampler2D nearest_sampler;
layout(rgba32f, set = 0, binding = 0) uniform image2D color_image;
// Our push constant.
// Must be aligned to 16 bytes, just like the push constant we passed from the script.
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	float k, r_threshold;
} params;

// The code we want to execute in each invocation.
void main() {

	ivec2 uv_unorm = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);
	float k = params.k;
	if (k == 0.0) {return;}
	if (uv_unorm.x >= size.x || uv_unorm.y >= size.y) {
		return;
	}
	vec2 uv = vec2(uv_unorm ) / params.raster_size;
	vec2 center = vec2(0.5, 0.5);
vec2 displace = normalize(uv - center) * k ;
vec4 color = texture(nearest_sampler, uv - displace);
//compilessssssssssssssssssss
   imageStore(color_image, uv_unorm, color);

}