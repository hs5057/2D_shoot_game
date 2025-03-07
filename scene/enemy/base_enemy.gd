extends CharacterBody2D
class_name BaseEnemy

enum State {
	IDLE,
	MOVE,
	ATK,
	DEATH,
	HIT
}

@export var speed : float = 25.0 # 移动速度
@export var gold_found : int = 15 # 金币掉落几率
@onready var anim: AnimatedSprite2D = %AnimatedSprite2D
@onready var body: Node2D = $Body
@onready var atk_timer: Timer = $AtkTimer
@onready var atk_area: Area2D = %AtkArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = $Shadow
@onready var hit_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hurt_area: Area2D = %HurtArea


const COIN_SCENE = preload("res://scene/coin.tscn")

var current_state = State.IDLE # 当前状态
var current_player = null # 当前目标玩家
var can_attack : bool = true # 是否可以攻击
var enemy_data : EnemyData # 敌人属性
var movement_delta
var _tick : int = 0 # 用于优化寻找玩家坐标的频率，不让每个敌人在同一帧去寻找刷新


func _ready() -> void:
	_tick = randi_range(30,90)
	
	#nav.max_speed = speed
	EnemyManager.enemies.append(self)
	enemy_data = EnemyData.new() # 直接创建，后续会动态创建
	enemy_data.on_death.connect(on_death)
	enemy_data.on_hit.connect(on_hit)
	
	atk_area.body_entered.connect(_on_atk_area_body_entered)
	atk_area.body_exited.connect(_on_atk_area_body_exited)
	anim.frame_changed.connect(_on_animated_sprite_2d_frame_changed)
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)


func _process(_delta: float) -> void:
	# 用于优化寻找玩家坐标的频率，不让每个敌人在同一帧去寻找刷新
	if Engine.get_process_frames() % _tick == 0:
		set_movement_target(Game.player.global_position)


func _physics_process(_delta: float) -> void:
	if current_state == State.DEATH \
	or current_state == State.ATK \
	or current_state == State.HIT:
		return

	if NavigationServer2D.map_get_iteration_id(nav.get_navigation_map()) == 0:
		return
	if nav.is_navigation_finished():
		return
	
	movement_delta = speed
	var next_path_position: Vector2 = nav.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta
	if nav.avoidance_enabled:
		nav.set_velocity(new_velocity)
	
	
	move_and_slide()
	
	change_anim()


func set_movement_target(movement_target: Vector2):
	nav.set_target_position(movement_target)


func change_anim():
	if velocity == Vector2.ZERO:
		anim.play("idle")
		current_state = State.IDLE
	else:
		anim.play("move")
		current_state = State.MOVE
		body.scale.x = -1 if !is_facing_target() and velocity.x < 0 else 1


func attack() -> void:
	if can_attack and current_player:
		atk_timer.start()
		can_attack = false
		anim.play("attack")
		current_state = State.ATK
	else:
		current_state = State.MOVE


func _on_atk_area_body_entered(_body: Node2D) -> void:
	if _body is Player and current_state != State.DEATH:
		current_state = State.ATK
		current_player = _body
		anim.play("attack")


func _on_atk_area_body_exited(_body: Node2D) -> void:
	if _body is Player and _body == current_player:
		current_player = null


func _on_animated_sprite_2d_frame_changed() -> void:
	if current_state == State.ATK and anim.animation == "attack":
		if current_player and anim.frame == 2:
			Game.damage(self , current_player)


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == State.ATK and anim.animation == "attack":
		if current_player and PlayerManager.is_death() == false:
			anim.play("attack")
		else:
			current_state = State.IDLE


func _on_atk_timer_timeout() -> void:
	can_attack = true


func on_death() -> void:
	if current_state == State.DEATH: 
		return

	collision_shape.set_deferred("disabled",true)
	hurt_area.set_deferred("monitoring",false)
	hurt_area.set_deferred("monitorable",false)
	atk_area.set_deferred("monitoring",false)
	atk_area.set_deferred("monitorable",false)
	current_state = State.DEATH
	anim.play("death")
	shadow.hide()
	# 掉落金币逻辑
	if randi() % 100 + 1 <= gold_found:  # 例如 gold_found=10 表示10%几率
		call_deferred("spawn_coin")
	await anim.animation_finished
	self.call_deferred("queue_free")


# 生成金币
func spawn_coin() -> void:
	if COIN_SCENE:
		var coin = COIN_SCENE.instantiate()
		coin.global_position = global_position
		Game.map.items.add_child(coin)  # 将金币添加到当前场景


func on_hit(_damage) -> void:
	hit_audio.play()
	current_state = State.HIT
	#Game.show_label(self,"-%s" %_damage)
	anim.play("hit")
	await anim.animation_finished
	current_state = State.IDLE


func _exit_tree() -> void:
	EnemyManager.enemies.erase(self)
	EnemyManager.on_enemy_death.emit()
	EnemyManager.check_enemies()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if PlayerManager.is_death():
		velocity = Vector2.ZERO
		anim.play("idle")
		current_state = State.IDLE
	else:
		velocity = safe_velocity * speed * 50


# 是否朝向玩家
func is_facing_target():
	var dir_to_target = (Game.player.global_position - global_position).normalized()
	var facing_dir = transform.x.normalized()
	var dot = facing_dir.dot(dir_to_target)
	return dot >= (1 - 0.7)
