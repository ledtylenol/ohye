extends Resource
class_name ItemData

enum Category {
	PASSIVE,
	SINGLE_USE,
	CONSUMABLE
}

@export var id := 0
@export var texture: Texture
@export var category: Category
@export var max_use_count := 0
var uses_left := max_use_count

signal expired
