extends Node3D
class_name Hands



@export var hand1_sod: SecondOrderDynamics
@export var hand2_sod: SecondOrderDynamics

@export var hand1_target: Marker3D
@export var hand2_target: Marker3D
@export var hand1: Node3D
@export var hand2: Node3D


func _ready() -> void:
	hand1_sod.init(hand1.global_position)
	hand2_sod.init(hand2.global_position)


func _process(delta: float) -> void:
	hand1.global_position = hand1_sod.update(hand1.global_position, hand1_target.global_position, delta)[0]
	hand2.global_position = hand2_sod.update(hand2.global_position, hand2_target.global_position, delta)[0]
