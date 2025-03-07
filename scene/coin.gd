extends Area2D

@onready var audio_player_component: AudioPlayerComponent = $AudioPlayerComponent
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var add_count: int = 1


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position:y", (position.y + 10), 0.22)
	tween.parallel().tween_property(self, "modulate:a", 100, 0.22)
	tween.tween_property(self, "position:y", (position.y + 7), 0.12)
	tween.tween_property(self, "position:y", (position.y + 10), 0.1)


# 解决刚进去就离开拾取范围时，会出现经验球动了一下，又不动了的情况
func disable_collision():
	collision_shape_2d.disabled = true


func collect():
	PlayerManager.emit_experience_collected(add_count)
	queue_free()


func tween_collect(percent: float, start_position: Vector2):
	var _player = Game.player
	if _player == null:
		return
	
	# 全局位置等于起始位置(采集前经验球的位置)	到玩家点的全局位置
	global_position = start_position.lerp(_player.global_position, percent)
	var direction_from_start = _player.global_position - start_position
	
	# 旋转金币,更平滑的旋转
	var target_rotation = direction_from_start.angle() + rad_to_deg(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))
	

func _on_area_entered(area:Area2D) -> void:
	if area.owner is not Player:
		return
	
	# 调用这个方法，但是在下一个空闲帧时调用
	Callable(disable_collision).call_deferred()
	$Shadow.hide()
	var tween = create_tween()
	# 如果 parallel 为 true，那么在这个方法之后追加的 Tweener 将默认同时执行，而不是顺序执行。
	tween.set_parallel()
	
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, .7)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_QUINT)
	
	# .chain()用于在使用 true 调用 set_parallel() 后，将两个 Tweener 串联。
	tween.chain()
	
	tween.tween_callback(collect)
	
	# 播放拾取音效
	audio_player_component.play_random()
