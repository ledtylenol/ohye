extends Projectile
class_name BasicProjectile

func _ready() -> void:
	velocity = dir

func move(dt: float) -> void:
	velocity = dir * velocity.length()
	position += velocity * dt
