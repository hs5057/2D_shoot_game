extends Path2D
class_name Base_Grenade

@onready var grenade_path_follow: PathFollow2D = %GrenadePathFollow
@onready var attack_area: Area2D = %AttackArea
@onready var grenade_sprite: Sprite2D = %Sprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var timer: Timer = $Timer
@onready var grenade_explosion_effect: Node2D = %GrenadeExplosionEffect
@onready var audio_player: AudioPlayerComponent = %AudioPlayerComponent
@onready var audio_player_boom: AudioPlayerComponent = %AudioPlayerBoom

@export var grenade_explosion_effect_scene: PackedScene

var player_node:CharacterBody2D
var tar_pos: Vector2
var value = 6.0 # 初始值  
var temp_value
var decrement_rate = 0.6 # 每秒减少的速率 
var label_position: Vector2

var is_over: bool = false
signal path_over
signal hit_target

func _ready() -> void:
	player_node = Game.player
	temp_value = value
	timer.timeout.connect(_on_timer_timeout)
	
	attack_area.area_entered.connect(_on_attack_area_area_entered)


func _physics_process(delta: float) -> void:

	if tar_pos.x > 0 and tar_pos.y > 0:
			var outX = tar_pos.x / 2
			var outY = -(tar_pos.x / 2)
			
			grenade_sprite.set_rotation(90.0)

			curve.set_point_out(0,Vector2(outX,outY))

			curve.set_point_position(1,tar_pos)
			curve.set_point_in(1,Vector2.ZERO)
			
	elif tar_pos.x < 0 and tar_pos.y > 0:
		var outX = tar_pos.x / 2
		var outY = tar_pos.x / 2
		
		grenade_sprite.set_rotation(-5.0)

		curve.set_point_out(0,Vector2(outX,outY))

		curve.set_point_position(1,tar_pos)
		curve.set_point_in(1,Vector2.ZERO)
		
	elif tar_pos.x < 0 and tar_pos.y < 0:
		var outX = 0
		var outY = tar_pos.y / 2
		var inX = -(tar_pos.x / 2)
		var inY = tar_pos.x / 2
		
		grenade_sprite.set_rotation(-5.0)

		curve.set_point_out(0,Vector2(outX,outY))

		curve.set_point_position(1,tar_pos)
		curve.set_point_in(1,Vector2(inX,inY))
		
	elif tar_pos.x > 0 and tar_pos.y < 0:
		var outX = 0
		var outY = tar_pos.y / 2
		var inX = -tar_pos.x / 2
		var inY = -tar_pos.x / 2
		
		grenade_sprite.set_rotation(90.0)

		
		curve.set_point_out(0,Vector2(outX,outY))

		curve.set_point_position(1,tar_pos)
		curve.set_point_in(1,Vector2(inX,inY))
	
	# 还没有达到终点的时候
	if grenade_path_follow.get_progress_ratio() < 1:  
		if grenade_path_follow.progress < curve.get_baked_length() / 1.8 :
				grenade_path_follow.progress += temp_value
				temp_value -= 0.01
		elif grenade_path_follow.progress >= curve.get_baked_length() / 1.8 and grenade_path_follow.progress < curve.get_baked_length() / 1.4:
			grenade_path_follow.progress += temp_value
			temp_value -= 0.05
		elif grenade_path_follow.progress >= curve.get_baked_length() / 1.4 :
			grenade_path_follow.progress += value + 1
	# 达到终点的时候
	elif grenade_path_follow.get_progress_ratio() == 1:  
		if !is_over:
			is_over = true
			path_over.emit()
			grenade_fall(grenade_sprite.global_position)
			timer.start()


func set_path_tar_pos(mouse_position: Vector2, player_global_position: Vector2):
	tar_pos = mouse_position - player_global_position


# 落地后模拟在地面反弹的效果
func grenade_fall(grenade_sprite_position:Vector2) -> void:
	# 获取投掷方向（从玩家到手雷落点）
	var dir = (grenade_sprite_position - player_node.global_position).normalized()
	
	# 计算滑动参数
	var slide_distance = 20.0
	var target_position = grenade_sprite.global_position + dir * slide_distance
	var target_rotation = dir.angle()
	
	# 重置碰撞体（避免滑动时穿模）
	collision_shape_2d.set_deferred("disabled", true)
	audio_player.play_random()
	
	# 创建动画序列
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 主滑动阶段
	tween.parallel().tween_property(grenade_sprite, "global_position", target_position, 0.3)
	tween.parallel().tween_property(grenade_sprite, "rotation", target_rotation + deg_to_rad(30), 0.3)
	
	# 模拟地面反弹
	tween.parallel().tween_property(grenade_sprite, "global_position", target_position + Vector2(0, -5), 0.1)
	tween.parallel().tween_property(grenade_sprite, "rotation", target_rotation + deg_to_rad(10), 0.1)
	
	# 最终稳定
	tween.parallel().tween_property(grenade_sprite, "global_position", target_position, 0.1)
	tween.parallel().tween_property(grenade_sprite, "rotation", target_rotation, 0.1)


# 开始爆炸
func start_explosion() -> void:
	# 实例化爆炸效果
	var grenade_explosion_effect_instance = grenade_explosion_effect_scene.instantiate()
	grenade_explosion_effect.add_child(grenade_explosion_effect_instance)
	
	# 打开攻击区域检测
	attack_area.call_deferred("set_monitoring",true)
	collision_shape_2d.call_deferred("set_disabled",false)
	audio_player_boom.play_random()
	await get_tree().create_timer(0.1).timeout
	# 关闭攻击区域检测
	attack_area.call_deferred("set_monitoring",false)
	collision_shape_2d.call_deferred("set_disabled",true)


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.owner is BaseEnemy:
		Game.damage(Game.player , area.owner)


func _on_timer_timeout() -> void:
	start_explosion()
	
	var tween = create_tween()
	tween.tween_property(self,"modulate:a", 0, 1)
	await tween.finished
	tween.kill()
	await get_tree().create_timer(2.0).timeout
	self.queue_free()
