extends RefCounted
class_name Constants
enum Ground {
	DIRT = 0,
	STONE = 1,
	METAL = 2,
	TILE = 3
}

static func enum_to_string(x: Ground) -> String:
	match x:
		Ground.DIRT: return "Dirt"
		Ground.METAL: return "Metal"
		Ground.TILE: return "Tile"
		_: return "Stone"
