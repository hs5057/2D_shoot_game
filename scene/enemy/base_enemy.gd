extends CharacterBody2D
class_name BaseEnemy

enum State {
	IDLE,
	MOVE,
	ATK,
	DEATH
}

@export var speed : float = 25.0 # 移动速度

@onready var anim: AnimatedSprite2D = %AnimatedSprite2D
@onready var body: Node2D = $Body
@onready var atk_timer: Timer = $AtkTimer
@onready var atk_area: Area2D = %AtkArea

var current_state = State.IDLE # 当前状态
var current_player = null # 当前目标玩家
var can_attack : bool = true # 是否可以击
var enemy_data : EnemyData # 敌人属性


func _ready() -> void:
	enemy_data = EnemyData.new() # 直接创建，后续会动态创建
	atk_area.body_entered.connect(_on_atk_area_body_entered)
	atk_area.body_exited.connect(_on_atk_area_body_exited)
	anim.frame_changed.connect(_on_animated_sprite_2d_frame_changed)
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)


func _physics_process(delta: float) -> void:
	
	if current_state == State.DEATH or current_state == State.ATK:
		return
	
	if PlayerManager.is_death():
		velocity = Vector2.ZERO
		anim.play("idle")
		current_state = State.IDLE
	else:
		velocity = global_position.direction_to(Game.player.global_position) * speed
	
	move_and_slide()
	
	change_anim()


func change_anim():
	if velocity == Vector2.ZERO:
		anim.play("idle")
		current_state = State.IDLE
	else:
		anim.play("move")
		current_state = State.MOVE
		body.scale.x = -1 if velocity.x < 0 else 1


func attack() -> void:
	if can_attack and current_player:
		atk_timer.start()
		can_attack = false
		anim.play("attack")
		current_state = State.ATK
	else:
		current_state = State.MOVE


func _on_atk_area_body_entered(body: Node2D) -> void:
	if body is Player:
		current_state = State.ATK
		current_player = body
		anim.play("attack")


func _on_atk_area_body_exited(body: Node2D) -> void:
	if body is Player and body == current_player:
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
