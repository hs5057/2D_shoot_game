extends Node

const HIT_LABEL = preload("res://ui/hit_label.tscn") # 伤害飘字

var map: Node2D # 游戏场景节点
var player : Player # 玩家节点
var current_weapon : BaseWeapon # 当前武器
var current_experience : float
var pause_count: int = 0
var is_crtical_strike: bool =false

signal on_game_start() # 游戏开始信号


# 伤害计算
# origin -> 原始 ， target -> 目标
func damage(origin:Node2D , target:Node2D) -> void:
	
	if origin is Player: # 玩家对怪物造成伤害
		if target is BaseEnemy:
			 # 基础伤害计算
			var base_damage = (PlayerManager.player_data.basic_damage + \
								Game.current_weapon.damage) * \
								PlayerManager.player_data.basic_damage_multiple
			# 暴击判断
			var is_critical = randf() <= PlayerManager.player_data.critical_rate
			var final_damage = base_damage * (PlayerManager.player_data.critical_damage_multiple if is_critical else 1.0)
			
			# 传递暴击状态
			var damage_text = "-%d" % final_damage
			show_label(target, damage_text, is_critical)  # 修改show_label参数
			
			target.enemy_data.current_hp -= round(final_damage)
			PlayerManager.player_data.is_critical = is_critical  # 记录暴击状态

	
	if origin is BaseEnemy: # 怪物对玩家造成伤害
		if target is Player:
			PlayerManager.player_data.current_hp -= origin.enemy_data.damage


# 伤害飘字
func show_label(origin:Node2D, text:String, is_critical:bool = false) -> void:
	var hit_label_instance = HIT_LABEL.instantiate() as Node2D
	hit_label_instance.global_position = origin.global_position
	map.add_child(hit_label_instance)
	hit_label_instance.set_text(text, is_critical)


# 相机震动
func camera_offset(offset,time) -> void:
	
	# 如果是暴击，增强震动
	if PlayerManager.player_data.is_critical:
		offset *= 2.0  # 震动幅度加倍
		time *= 0.7    # 震动时间加快
		
	var tween = create_tween()
	tween.tween_property(player.camera, "offset", Vector2.ZERO, time).from(offset)
