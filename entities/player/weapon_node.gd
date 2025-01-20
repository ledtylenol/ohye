@tool
extends Node3D
class_name WeaponNode
@export_range(0.0, 1.0) var relative_thres: float = 0.5
@export var camera_node: Camera3D
@export var player: Player
var knife_sc = ResourceLoader.load("res://entities/knife/knife.tscn")
var cam_tf: Transform3D:
	get:
		return camera_node.global_transform
var heat: = 0.0
var cooldown:
	get:
		return get_parent().cooldown
@export var knife: Node3D
@export var kn_off: Node3D
@export var target: Node3D

@export var offset: Vector3
@export var shoot_offset: Vector3
@export var tween_amt: = 0.5
var real_offset: = Vector3.ZERO
@onready var rot_offset = knife.quaternion
@onready var shoot_dynams: SecondOrderDynamics = $ShootDynams
@onready var sod: SecondOrderDynamics = $SecondOrderDynamics
@onready var rot_order: SecondOrderDynamics = $RotOrder
@onready var plane: MeshInstance3D = $knife / KnifeOffset / Plane
@onready var cylinder: MeshInstance3D = $knife / KnifeOffset / Cylinder

@export_range(0.0, 1.0) var dissolve: = 0.0:
	set(value):
		plane.set_instance_shader_parameter("dissolve", value)
		cylinder.set_instance_shader_parameter("dissolve", value)
		dissolve = value
var tweened_dissolve = 0.0
var move_tween: Tween
func _ready() -> void :
	sod.init(knife.global_position)
	rot_order.initq(knife.quaternion)
	shoot_dynams.init(real_offset)
func _process(delta: float) -> void :
	if Engine.is_editor_hint():
		return
	tweened_dissolve = 0.0 if heat == 0 else 1.0
	var weight: = 5.0 if tweened_dissolve < dissolve else 15.0
	dissolve = M.smooth_nudgef(dissolve, tweened_dissolve, weight, delta)
	heat = maxf(0.0, heat - delta)
	if heat > cooldown * relative_thres:
		real_offset = shoot_offset
	else:
		real_offset = Vector3.ZERO
	var b: Basis = target.global_basis
	knife.global_position = sod.update(knife.global_position, target.global_position + b * offset, delta)[0]
	knife.quaternion = rot_order.update_q(knife.quaternion, target.quaternion * rot_offset, delta)[0]
	kn_off.position = shoot_dynams.update(kn_off.position, target.basis * real_offset, delta)[0]
	shoot_dynams._f = 1.0 / cooldown
func shoot() -> void :
	$Throw.play()
	heat = cooldown
	var cont = knife_sc.instantiate()
	cont.transform = knife.global_transform.rotated_local(Vector3.UP, PI / 2).translated_local(Vector3.FORWARD * 0.1)
	cont.up_dir = player.normal
	cont.velocity = player.velocity
	get_tree().current_scene.add_child(cont)

func reset_sods() -> void :
	rot_order.initq(target.quaternion * rot_offset)
	sod.init(target.global_position + target.global_basis * offset)
	shoot_dynams.init(target.basis * real_offset)
