extends Area3D
class_name Hurtbox

@export var health_component: HealthComponent

var has_collision_child := false

signal hit(who: Hitbox, how_much: int)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not has_collision_child:
			for child in get_children():
				if child is CollisionShape3D:
					has_collision_child = true
					break
		if not has_collision_child:
			var shape = CollisionShape3D.new()
			add_child(shape)
			shape.owner = get_tree().edited_scene_root

			has_collision_child = true
		return
func _on_area_entered(area: Area3D) -> void:
	if area is Hitbox:
		hit.emit(area as Hitbox, area.damage)
