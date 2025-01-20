#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba32f, set = 0, binding = 0) uniform restrict readonly image2D input_image;
layout(rgba32f, set = 1, binding = 0) uniform restrict writeonly image2D output_image;

layout(push_constant, std430) uniform Params {
    vec2 image_size;
    vec2 reserved;
} params;

void main() {
    ivec2 iuv = ivec2(gl_GlobalInvocationID.xy);

    if ((iuv.x >= params.image_size.x ||iuv.y >= params.image_size.y )) {return;}

    vec4 color = imageLoad(input_image, iuv);
    imageStore(output_image, iuv, color );
}