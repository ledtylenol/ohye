shader_type spatial;
render_mode vertex_lighting, skip_vertex_transform,
			specular_schlick_ggx, diffuse_lambert_wrap;

uniform sampler2D albedo: hint_default_black, filter_nearest;
uniform sampler2D specular: hint_default_black, filter_nearest;
uniform sampler2D emission: hint_default_black, filter_nearest;

// The "jumpiness" of vertices.
uniform float jitter: hint_range(0.0, 1.0) = 0.5;

// If disabled, jitter will not affect the Z coordinate
// of the vertex.
uniform bool jitter_z_coordinate = true;

// If disabled, makes vertices further away from the camera
// less jittery.
uniform bool jitter_depth_independent = true;

// Enables the PS1 texture warping.
uniform bool affine_texture_mapping = true;

// Control the amount of distortion on the texture warping
uniform float affine_texture_intensity: hint_range(-2.0, 0.0) = -2.0;

// Any alpha value below this will not be rendered.
uniform float alpha_scissor: hint_range(0.0, 1.0) = 1.0;

// Color to overlay on top of the albedo texture.
uniform vec4 albedo_color: source_color = vec4(1.0);

// Emission color.
uniform vec4 emission_color: source_color = vec4(1.0);

// Texture tiling.
uniform vec2 texture_size = vec2(1.0);

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float z_orig = VERTEX.z;
	float i = (1.0 - jitter) * min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 2.0;

	if (jitter_depth_independent) {
		float w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
		VERTEX = round(VERTEX / w * i) / i * w;
	} else {
		VERTEX = round(VERTEX * i) / i;
	}

	if (!jitter_z_coordinate) {
		VERTEX.z = z_orig;
	}

	if (affine_texture_mapping) {
		UV.x *= (1.0 + (VERTEX.z * affine_texture_intensity));
        UV.y *= (1.0 + (VERTEX.z * affine_texture_intensity));
	}
}
