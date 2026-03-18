extends Sprite2D
class_name Bullet

var enemy: bool = false

func _physics_process(delta: float) -> void:
	position.y += 1 if enemy else -2
	if position.y >= 80 or position.y < 0:
		queue_free()
	if enemy:
		if Game.INSTANCE.check_player_damage(Rect2i(Vector2i(position), Vector2i.ONE)):
			queue_free()
		return
	for brick in Game.INSTANCE.bricks:
		var pos = Vector2i(position)
		var rect = Rect2i(Vector2i(brick.position), Vector2i(8, 3))
		if rect.has_point(pos):
			if brick.damage():
				enemy = true
				return
			queue_free()
			return
		rect.position.x -= 1
		rect.size = Vector2i(10, 2)
		if rect.has_point(pos):
			if brick.damage():
				enemy = true
				return
			queue_free()
			return
