extends Node

const HIT_LABEL = preload("res://ui/hit_label.tscn")
var map: Node2D # 游戏场景节点
var player : Player # 玩家节点
var current_weapon : BaseWeapon # 当前武器

signal on_game_start() # 游戏开始信号


# 伤害计算
# origin -> 原始 ， target -> 目标
func damage(origin:Node2D , target:Node2D) -> void:
	if origin is Player: # 玩家对怪物造成伤害
		if target is BaseEnemy:
			target.enemy_data.current_hp -= PlayerManager.player_data.damage + Game.current_weapon.damage
	
	if origin is BaseEnemy: # 怪物对玩家造成伤害
		if target is Player:
			PlayerManager.player_data.current_hp -= origin.enemy_data.damage


# 伤害飘字
func show_label(origin:Node2D, text:String) -> void:
	var hit_label_instance = HIT_LABEL.instantiate() as Node2D
	hit_label_instance.global_position = origin.global_position
	map.add_child(hit_label_instance)
	hit_label_instance.set_text(text)


# 相机震动
func camera_offset(offset,time) -> void:
	var tween = create_tween()
	tween.tween_property(player.camera, "offset", Vector2.ZERO, time).from(offset)
