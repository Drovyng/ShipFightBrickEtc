extends SubViewport
class_name Game

static var _prefab_brick = preload("res://brick.tscn")
static var _prefab_bullet = preload("res://bullet.tscn")

@export var parent: SubViewportContainer
@export var player: Sprite2D
@export var bonus_health: Sprite2D
var player_pos: int = 32
var bricks: Array[Brick] = []

@export var live_num: Sprite2D
@export var score_num: Array[Sprite2D]

var spawn_timer: int = Brick.MOVE_TIMER * 5
var score: int = 0
var bonus_health_timer: int = 0

var shoot_side: bool = false
var shoot_timer: int = 0

var player_damage_timer: int = 0
var player_lives: int = 5

static var INSTANCE: Game

func _ready() -> void:
	INSTANCE = self
	live_num.frame = player_lives
	for i in 4:
		spawn_bricks(i)

func damage():
	if player_lives <= 0: return
	if player_damage_timer <= 0:
		player_lives -= 1
		player_damage_timer = 65
		live_num.frame = player_lives
		if player_lives == 0:
			get_child(1).visible = true
			for i in (get_child_count() - 2):
				var child = get_child(i + 2)
				if !(child is Sprite2D) || child.hframes < 5 || child.name == "Live Number":
					child.visible = false
			var offset = 38 - ((score_num.size() - 1) * 4 + 3) / 2
			for i in score_num.size():
				score_num[score_num.size() - 1 - i].position = Vector2(offset + 4 * i + 2, 49)
	
func add_score(value: int):
	if player_lives <= 0: return
	if score / 100 != (score + value) / 100:
		player_lives = mini(player_lives + 2, 10)
		player_damage_timer = 0
		bonus_health.visible = true
		bonus_health_timer = 65
		damage()
	score += value
	var numCount = 0
	var scoreBetween = score
	while scoreBetween != 0:
		numCount += 1
		scoreBetween /= 10
	if score_num.size() < numCount:
		var new_num = score_num[score_num.size() - 1].duplicate()
		add_child(new_num)
		move_child(new_num, 2)
		new_num.position.x -= 4
		score_num.append(new_num)
	scoreBetween = score
	var index = 0
	while scoreBetween != 0:
		score_num[index].frame = scoreBetween % 10
		index += 1
		scoreBetween /= 10

func check_player_damage(rect: Rect2i) -> bool:
	if Rect2i(player_pos + 1, 70, 14, 5).intersects(rect):
		damage()
		return true
	if Rect2i(player_pos + 4, 67, 8, 3).intersects(rect):
		damage()
		return true
	if Rect2i(player_pos + 6, 63, 4, 4).intersects(rect):
		damage()
		return true
	return false

func _physics_process(delta: float) -> void:
	var screenSize = parent.get_viewport_rect().size
	parent.scale = (minf(screenSize.x, screenSize.y) / 80.0) * Vector2.ONE
	if player_lives <= 0:
		if Input.is_action_just_pressed("shoot"):
			get_tree().reload_current_scene()
		return
	
	if player_damage_timer > 0: player_damage_timer -= 1
	player.modulate = Color.WHITE if (player_damage_timer / 4 % 2 == 0) else Color.TRANSPARENT
	if bonus_health_timer > 0:
		bonus_health_timer -= 1
		if bonus_health_timer == 0:
			bonus_health.visible = false
	if shoot_timer > 0: shoot_timer -= 1
	
	if randi_range(0, 2) > 0 && player.modulate.a > 0.5:
		var bullet = spawn_bullet(Vector2(player_pos + 7 + spawn_timer % 2, 76), true)
		bullet.modulate = Color.YELLOW if randi_range(0, 1) == 0 else Color.RED
	
	spawn_timer -= 1
	if spawn_timer <= 0:
		spawn_timer = Brick.MOVE_TIMER * 5
		spawn_bricks(0)
	
	if Input.is_action_pressed("left"):
		player_pos -= 1
	if Input.is_action_pressed("right"):
		player_pos += 1
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot_side = !shoot_side
		spawn_bullet(Vector2i(player_pos + (3 if shoot_side else 12), 67), false)
		shoot_timer = 10
		
	player_pos = clampi(player_pos, 0, 64)
	player.position.x = player_pos

func spawn_bullet(pos: Vector2i, enemy: bool) -> Bullet:
	if player_lives <= 0: return
	var bullet = _prefab_bullet.instantiate() as Bullet
	bullet.enemy = enemy
	bullet.position = pos
	add_child(bullet)
	return bullet

func spawn_bricks(offset: int):
	if player_lives <= 0: return
	for i in 9:
		var brick = _prefab_brick.instantiate() as Brick
		brick.position = Vector2(i * 9, -4 + offset * 6)
		bricks.append(brick)
		add_child(brick)
