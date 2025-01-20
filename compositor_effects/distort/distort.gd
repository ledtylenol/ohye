@tool
extends CompositorEffect
class_name DistortEffect

@export var generate: bool:
	set(value):
		regenerate_shaders()
@export_range(-1.0, 1.0)var k:= 0.0
var rd: RenderingDevice
var shader: RID
var shader_copy: RID
var pipeline: RID
var pipeline_copy: RID
var sampler_linear: RID
var sampler_nearest: RID
var context : StringName = "PreviousFrame"
var texture : StringName = "texture"
func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	generate_samplers()


func generate_samplers() -> void:
	var samp := RDSamplerState.new()
	samp.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	samp.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	samp.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	samp.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_REPEAT
	samp.use_anisotropy = true
	samp.mip_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_linear = rd.sampler_create(samp)
	var sampn := RDSamplerState.new()
	sampn.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_MIRRORED_REPEAT
	sampn.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_MIRRORED_REPEAT
	sampler_nearest = rd.sampler_create(sampn)
	samp.use_anisotropy = true

# System notifications, we want to react on the notification that
# alerts us we are about to be destroyed.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and self:
		reset_stuff()

func reset_stuff() -> void:
	print("reset")
	if shader.is_valid():
		# Freeing our shader will also free any dependents such as the pipeline!
		rd.free_rid(shader)
	if sampler_linear.is_valid():
		rd.free_rid(sampler_linear)
	if sampler_nearest.is_valid():
		rd.free_rid(sampler_nearest)
	if shader_copy.is_valid():
		rd.free_rid(shader_copy)
	if pipeline.is_valid():
		rd.free_rid(pipeline)
	if pipeline_copy.is_valid():
		rd.free_rid(pipeline_copy)
func regenerate_shaders() -> void:
	reset_stuff()
	generate_samplers()
	_check_shader()
#region Code in this region runs on the rendering thread.
# Check if our shader has changed and needs to be recompiled.
func _initialize_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		return

	# Compile our shader.
	var shader_file := load("res://compositor_effects/copy_screen.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()

	shader_copy = rd.shader_create_from_spirv(shader_spirv)
	if shader_copy.is_valid():
		pipeline_copy = rd.compute_pipeline_create(shader_copy)


func _check_shader() -> bool:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		return false
	if shader.is_valid() and shader_copy.is_valid() and pipeline.is_valid() and pipeline_copy.is_valid():
		return true
	# Compile our shader.
	var shader_file := load("res://compositor_effects/distort/distort.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()

	shader = rd.shader_create_from_spirv(shader_spirv)
	if shader.is_valid():
		pipeline = rd.compute_pipeline_create(shader)

	_initialize_compute()
	return pipeline.is_valid() && pipeline_copy.is_valid()


# Called by the rendering thread every frame.
func _render_callback(p_effect_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:

	if rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and _check_shader():
		# Get our render scene buffers object, this gives us access to our render buffers.
		# Note that implementation differs per renderer hence the need for the cast.
		var render_scene_buffers := p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			# Get our render size, this is the 3D render resolution!
			var size: Vector2i = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			# We can use a compute shader here.
			@warning_ignore("integer_division")
			var x_groups := (size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups := (size.y - 1) / 8 + 1
			var z_groups := 1

			# Create push constant.
			# Must be aligned to 16 bytes and be in the same order as defined in the shader.
			var push_constant := PackedFloat32Array([
				size.x,
				size.y,
				k,
				0,
			])
			var push_constant_copy := PackedFloat32Array([
				size.x,
				size.y,
				k,
				0,
			])
			if !render_scene_buffers.has_texture(context, texture):
				var usage_bits : int = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT \
				| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
				| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
				#render_scene_buffers.create_texture(context, texture, RenderingDevice.DATA_FORMAT_R16_UNORM, usage_bits, RenderingDevice.TEXTURE_SAMPLES_1, size, 1, 1, true)
				render_scene_buffers.create_texture(context, texture, RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT, usage_bits, RenderingDevice.TEXTURE_SAMPLES_1, size, 1, 1, true)
				print("recreate")
			# Loop through views just in case we're doing stereo rendering. No extra cost if this is mono.
			var view_count: int = render_scene_buffers.get_view_count()
			
			for view in view_count:
				# Get the RID for our color image, we will be reading from and writing to it.
				var input_image: RID = render_scene_buffers.get_color_layer(view)
				var previous_texture_image = render_scene_buffers.get_texture(context, texture)

				# Create a uniform set, this will be cached, the cache will be cleared if our viewports configuration is changed.
				var uniform1 := RDUniform.new()
				uniform1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform1.binding = 0
				uniform1.add_id(input_image)
				var uniform2 := RDUniform.new()
				uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform2.binding = 0
				uniform2.add_id(previous_texture_image)
				var uniform_set := UniformSetCacheRD.get_cache(shader_copy, 0, [uniform1])
				var uniform_set_2 := UniformSetCacheRD.get_cache(shader_copy, 1, [uniform2])
				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline_copy)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set_2, 1)
				rd.compute_list_set_push_constant(compute_list, push_constant_copy.to_byte_array(), push_constant_copy.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()
				var uniform_set_new := UniformSetCacheRD.get_cache(shader, 0, [uniform1])
				var uniform3 := RDUniform.new()
				uniform3.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				uniform3.binding = 0
				uniform3.add_id(sampler_linear)
				uniform3.add_id(previous_texture_image)
				var uniform4 := RDUniform.new()
				uniform4.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
				uniform4.binding = 1
				uniform4.add_id(sampler_nearest)
				uniform4.add_id(previous_texture_image)
				
				var uniform_set_3 := UniformSetCacheRD.get_cache(shader, 1, [uniform3, uniform4])
				compute_list = rd.compute_list_begin()
				
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set_new, 0)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set_3, 1)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()


#endregion
