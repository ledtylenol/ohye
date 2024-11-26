extends Area2D
class_name CameraNode

@export var zoom := 1.0
@export var target_node: Node2D

func _ready() -> void:
	collision_layer = 0b100000000
	if not target_node: target_node = self
