extends Resource
class_name ProjectileProperty

func generate(_parent: Node) -> ProjectileComponent:
	return ProjectileComponent.new()
