extends Sprite2D
class_name Brick

static var MOVE_TIMER: int = 70

var type: int = 0
var health: int = 2
var timer: int = MOVE_TIMER


func _ready() -> void:
	type = randi_range(0, 6)
	if type == 0: modulate = Color.AQUA
	elif type == 1: modulate = Color.YELLOW
	elif type == 2: modulate = Color.GREEN
	elif type == 3: 
		modulate = Color.MAGENTA
		health = 4

func _physics_process(delta: float) -> void:
	if health > 0:
		timer -= 1
		if timer <= 0:
			timer = MOVE_TIMER
			position.y += 1
			if type == 0 && position.y > -3:
				Game.INSTANCE.spawn_bullet(Vector2i(position) + Vector2i(randi_range(4,5), 3), true)
			if position.y >= 60:
				var timer = Game.INSTANCE.player_damage_timer
				Game.INSTANCE.player_damage_timer = 0
				Game.INSTANCE.damage()
				Game.INSTANCE.player_damage_timer = timer
				health = -100
				return
				
	else:
		if type != 2 || position.y > 80 || health < -2: 
			Game.INSTANCE.bricks.remove_at(Game.INSTANCE.bricks.find(self))
			queue_free()
			if type == 2: Game.INSTANCE.add_score(2)
			return
		position.y += 1
		Game.INSTANCE.check_player_damage(Rect2i(Vector2i(position), Vector2i(8, 3)))


func damage() -> bool:
	health -= 1
	if health == 0:
		Game.INSTANCE.add_score(1)
	return type == 1
