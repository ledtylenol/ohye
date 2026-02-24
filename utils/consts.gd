extends RefCounted
class_name Constants
enum Ground {
	DIRT,
	STONE,
	METAL,
	
}

static func enum_to_string(x: Ground) -> String:
	match x:
		Ground.DIRT: return "Dirt"
		Ground.METAL: return "Metal"
		_: return "Stone"
